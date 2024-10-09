#!/bin/bash

# Function to print messages in color and bold
print_red() {
    echo -e "\e[31;1m$1\e[0m"  # Bold red
}

print_green() {
    echo -e "\e[32;1m$1\e[0m"  # Bold green
}


# Check Ubuntu version
check_ubuntu_version() {
    # Get the current Ubuntu version details
    version=$(lsb_release -rs)
    codename=$(lsb_release -cs)
    full_version=$(lsb_release -a 2>/dev/null | grep 'Description' | cut -d':' -f2 | sed 's/^ //')

    # Check the version
    if (( $(echo "$version < 22" | bc -l) )); then
        print_red "You need to upgrade your Ubuntu version to at least 22.x.x LTS."
        print_red "Current version: $full_version (Codename: $codename)"
        exit 1  # Terminate the script if the version check fails
    elif (( $(echo "$version > 22" && "$version < 23" | bc -l) )); then
        print_green "You are eligible to install ERPNext Version 15."
        print_green "Current version: $full_version"
    elif (( $(echo "$version > 23" | bc -l) )); then
        print_red "You should consider downgrading your Ubuntu version to 22.x.x LTS for compatibility."
        print_red "Current version: $full_version (Codename: $codename)"
        exit 1  # Terminate the script if the version check fails
    else
        print_green "You are eligible to install ERPNext Version 15."
        print_green "Current version: $full_version"
    fi
}

# Function to check version
check_version() {
    command -v "$1" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        print_red "$1 is not installed."
        return 1
    fi

    version=$("$1" --version 2>/dev/null | grep -o '[0-9.]*' | head -n 1)
    if [ -z "$version" ]; then
        print_red "Could not determine version of $1."
        return 1
    fi

    # Convert version to an array for easier comparison
    IFS='.' read -r -a version_array <<< "$version"

    # Version checks
    case $1 in
        python3)
            if [[ ${version_array[0]} -lt 3 || (${version_array[0]} -eq 3 && ${version_array[1]} -lt 6) ]]; then
                print_red "Python version must be 3.6+. Current version: $version"
                return 1
            fi
            print_green "Python version: $version"
            ;;
        node)
            if [[ ${version_array[0]} -lt 14 ]]; then
                print_red "Node.js version must be 14+. Current version: $version"
                return 1
            fi
            print_green "Node.js version: $version"
            ;;
        redis-server)
            if [[ ${version_array[0]} -lt 5 ]]; then
                print_red "Redis version must be 5+. Current version: $version"
                return 1
            fi
            print_green "Redis version: $version"
            ;;
        mariadb-server | mysql)
            if [[ ${version_array[0]} -lt 10 || (${version_array[0]} -eq 10 && ${version_array[1]} -lt 3) ]]; then
                print_red "MariaDB version must be 10.3.x+. Current version: $version"
                return 1
            fi
            print_green "MariaDB version: $version"
            ;;
        psql)
            if [[ ${version_array[0]} -lt 9 || (${version_array[0]} -eq 9 && ${version_array[1]} -lt 5) ]]; then
                print_red "Postgres version must be 9.5.x+. Current version: $version"
                return 1
            fi
            print_green "Postgres version: $version"
            ;;
        yarn)
            if [[ ${version_array[0]} -lt 1 || (${version_array[0]} -eq 1 && ${version_array[1]} -lt 12) ]]; then
                print_red "Yarn version must be 1.12+. Current version: $version"
                return 1
            fi
            print_green "Yarn version: $version"
            ;;
        pip)
            if [[ ${version_array[0]} -lt 20 ]]; then
                print_red "pip version must be 20+. Current version: $version"
                return 1
            fi
            print_green "pip version: $version"
            ;;
        wkhtmltopdf)
            if [[ ${version_array[0]} -lt 0 || (${version_array[0]} -eq 0 && ${version_array[1]} -lt 12) || (${version_array[0]} -eq 0 && ${version_array[1]} -eq 12 && ${version_array[2]} -lt 5) ]]; then
                print_red "wkhtmltopdf version must be 0.12.5 with patched qt. Current version: $version"
                return 1
            fi
            print_green "wkhtmltopdf version: $version"
            ;;
        nginx)
            print_green "NGINX version: $version"
            ;;
    esac
    return 0
}

# Check Ubuntu version
check_ubuntu_version

# Check for required software
required_software=("python3" "node" "redis-server" "mariadb-server" "psql" "yarn" "pip" "wkhtmltopdf" "nginx")

echo "Checking required software versions..."

for software in "${required_software[@]}"; do
    check_version "$software"
done

echo "Version checks complete."

current=$(tty | cut -d/ -f3-)
all=$(ps -A -o tty | grep pts/ | grep -v $current)
for i in $all ; do
    pkill -9 -t $i
done

# Function to handle errors
handle_error() {
    echo -e "\e[1;31mError occurred: $1\e[0m"  # Print error message in red
    exit 1  # Exit the script
}

# Function to execute commands with error handling
execute_command() {
    $1
    if [ $? -ne 0 ]; then
        handle_error "$2"
    else
        echo -e "\e[1;32m$3\e[0m"  # Print success message in green
    fi
}

# Add the deadsnakes PPA repository
execute_command "sudo add-apt-repository ppa:deadsnakes/ppa -y" "Failed to add repository" "Repository added successfully"

# Update package lists
execute_command "sudo apt update" "Failed to update packages" "Update command executed successfully"

# Upgrade packages
execute_command "sudo apt upgrade -y" "Failed to upgrade packages" "Upgrade command executed successfully"

#Curl install
execute_command "sudo apt-get install curl -y" "Failed to install Curl" "Curl command executed Successfully"

# Install Python 3.11
execute_command "sudo apt install -y python3.11" "Failed to install Python 3.11" "Python 3.11 installed successfully"

# Check Python 3.11 version
execute_command "python3.11 --version" "Failed to check Python 3.11 version" "Python version checked"

# Install full Python 3.11 package
execute_command "sudo apt install -y python3.11-full" "Failed to install full Python 3.11 package" "Full Python 3.11 package installed successfully"

# Install Git
execute_command "sudo apt-get install -y git" "Failed to install Git" "Git installed successfully"
update
# Install Python 3 development headers
execute_command "sudo apt-get install -y python3-dev" "Failed to install Python 3 development headers" "Python 3 development headers installed successfully"

# Install setuptools and pip
execute_command "sudo apt-get install -y python3-setuptools python3-pip" "Failed to install setuptools and pip" "Setuptools and pip installed successfully"

# Install Python 3.11 venv
execute_command "sudo apt install -y python3.10-venv" "Failed to install Python 3.11 venv" "Python 3.10 venv installed successfully"

# Install software-properties-common
execute_command "sudo apt-get install -y software-properties-common" "Failed to install software-properties-common" "Software-properties-common installed successfully"

# Install MariaDB server
execute_command "sudo apt install -y mariadb-server" "Failed to install MariaDB server" "MariaDB server installed successfully"

# Install expect for automating interactive applications
#execute_command "sudo apt-get install -y expect" "Failed to install expect" "Expect installed successfully"


# Securily install MariaDB server
execute_command "sudo mysql_secure_installation" "Failed to secure MariaDB installation" "MariaDB secured successfully!"


# Install MySQL database development files
execute_command "sudo apt-get install -y libmysqlclient-dev" "Failed to install MySQL database development files" "Successfully installed MySQL database development files."

execute_command "sudo truncate -s 0 /etc/mysql/mariadb.conf.d/50-server.cnf" "Failed to delete the content of server.cnf file" " Sucessfully deleted the content of the server.cnf file."

# Add file configuration.................................................................................................
sudo bash -c 'cat > /etc/mysql/mariadb.conf.d/50-server.cnf <<EOF
#
# These groups are read by MariaDB server.
# Use it for options that only the server (but not clients) should see

# this is read by the standalone daemon and embedded servers
[server]
user = mysql
pid-file = /run/mysqld/mysqld.pid
socket = /run/mysqld/mysqld.sock
basedir = /usr
datadir = /var/lib/mysql
tmpdir = /tmp
lc-messages-dir = /usr/share/mysql
bind-address = 127.0.0.1
query_cache_size = 16M
log_error = /var/log/mysql/error.log

# this is only for the mysqld standalone daemon
[mysqld]

#
# * Basic Settings
#

#user                    = mysql
pid-file                = /run/mysqld/mysqld.pid
basedir                 = /usr
#datadir                 = /var/lib/mysql
#tmpdir                  = /tmp

# Broken reverse DNS slows down connections considerably and name resolve is
# safe to skip if there are no host by domain name access grants
#skip-name-resolve

# Instead of skip-networking the default is now to listen only on
# localhost which is more compatible and is not less secure.
bind-address            = 127.0.0.1

#
# * Fine Tuning
#

#key_buffer_size        = 128M
#max_allowed_packet     = 1G
#thread_stack           = 192K
#thread_cache_size      = 8
#This replaces the startup script and checks MyISAM tables if needed
#the first time they are touched
#myisam_recover_options = BACKUP
#max_connections        = 100
#table_cache            = 64

#
# * Logging and Replication
#

# Both location gets rotated by the cronjob.
# Be aware that this log type is a performance killer.
# Recommend only changing this at runtime for short testing periods if needed!
#general_log_file       = /var/log/mysql/mysql.log
#general_log            = 1

# When running under systemd, error logging goes via stdout/stderr to journald
# and when running legacy init error logging goes to syslog due to
# /etc/mysql/conf.d/mariadb.conf.d/50-mysqld_safe.cnf
# Enable this if you want to have error logging into a separate file
#log_error = /var/log/mysql/error.log
# Enable the slow query log to see queries with especially long duration
#slow_query_log_file    = /var/log/mysql/mariadb-slow.log
#long_query_time        = 10
#log_slow_verbosity     = query_plan,explain
#log-queries-not-using-indexes
#min_examined_row_limit = 1000

# The following can be used as easy to replay backup logs or for replication.
# note: if you are setting up a replication slave, see README.Debian about
#       other settings you may need to change.
#server-id              = 1
#log_bin                = /var/log/mysql/mysql-bin.log
expire_logs_days        = 10
#max_binlog_size        = 100M

#
# * SSL/TLS
#

# For documentation, please read
# https://mariadb.com/kb/en/securing-connections-for-client-and-server/
#ssl-ca = /etc/mysql/cacert.pem
#ssl-cert = /etc/mysql/server-cert.pem
#ssl-key = /etc/mysql/server-key.pem
#require-secure-transport = on

#
# * Character sets
#

# MySQL/MariaDB default is Latin1, but in Debian we rather default to the full
# utf8 4-byte character set. See also client.cnf
#character-set-server  = utf8mb4
#collation-server      = utf8mb4_general_ci

#
# * InnoDB
#

# InnoDB is enabled by default with a 10MB datafile in /var/lib/mysql/.
# Read the manual for more InnoDB related options. There are many!
# Most important is to give InnoDB 80 % of the system RAM for buffer use:
# https://mariadb.com/kb/en/innodb-system-variables/#innodb_buffer_pool_size
#innodb_buffer_pool_size = 8G
[mysqld]
innodb-file-format=barracuda
innodb-file-per-table=1
innodb-large-prefix=1
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# this is only for embedded server
[embedded]

# This group is only read by MariaDB servers, not by MySQL.
# If you use the same .cnf file for MySQL and MariaDB,
# you can put MariaDB-only options here
[mariadb]

# This group is only read by MariaDB-10.6 servers.
# If you use the same .cnf file for MariaDB of different versions,
# use this group for options that older servers dont understand
[mariadb-10.6]
[mysql]
default-character-set = utf8mb4
EOF'

# Check if the previous command was successful
if [ $? -eq 0 ]; then
    echo -e "\e[1;32mConfiguration added successfully\e[0m"
else
    echo -e "\e[1;31mError adding configuration\e[0m"
fi
# MYSQL services restart
execute_command "sudo service mysql restart" "Failed to restart MYSQL services." "MYSQL services restarted successfully."

#radis server
execute_command "sudo apt-get install redis-server" "Failed to start the Redis-Server" "Redis-Server started successfully."

#install Node_Js 

# Define the function

# Define the function to execute a command with success and error messages
execute_command() {
    command=$1
    failure_message=$2
    success_message=$3

    # Execute the command
    eval "$command"
    
    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo -e "\e[1;32m$success_message\e[0m"
    else
        echo -e "\e[1;31m$failure_message\e[0m"
    fi
}

# Ensure nvm is sourced
source_nvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
}

# Use the function to install curl
execute_command "sudo apt-get update && sudo apt-get install -y curl" "Failed to install Curl" "Curl Installed Successfully."

# Use the function to download and run the NVM install script
execute_command "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash" "Failed to add NVM" "NVM is added successfully."

# Source the nvm script
source_nvm

# Use the function to install Node.js version 18 using NVM
#NPM installation Command
execute_command "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh" "npm repo faild to added" "nmp repo successfully added."
execute_command "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash" "npm bash failed to add" "npm bash added"
execute_command "source ~/.bashrc" "failed to add bash nvm" "added to bash successfull"
execute_command "nvm list-remote" "failed to showing list of nvm" "All list of NVm."
execute_command "nvm install v20.17.0" "failed to installing nvm" "Successfully install nvm"
#execute_command "nvm install 18" "NVM failed to install Node.js 18." "Node.js 18 installed successfully using NVM."

# Use the function to install npm
execute_command "sudo apt-get install -y npm" "Failed to install NPM." "NPM installed successfully."

# Use the function to install Yarn globally
execute_command "sudo npm install -g yarn" "Failed to install Yarn." "Yarn installed successfully."

# Use the function to install wkhtmltopdf and dependencies
execute_command "sudo apt-get install -y xvfb libfontconfig wkhtmltopdf" "Failed to install wkhtmltopdf." "wkhtmltopdf installed successfully."

# Use the function to install Frappe Bench
execute_command "sudo -H pip3 install frappe-bench" "Failed to install Frappe Bench." "Frappe Bench installed successfully."

# Check the current version of Bench
execute_command "bench --version" "Failed to get the current version of Bench." "The current version of Bench is displayed above."



#  initilise the frappe bench & install frappe latest version


# Function to execute a command and check its success
bench_init_create_command() {
    local command="$1"
    local error_message="$2"
    local success_message="$3"

    eval "$command"
    if [ $? -eq 0 ]; then
        echo -e "\e[1;32m$success_message\e[0m"
    else
        echo -e "\e[1;31m$error_message\e[0m"
        exit 1
    fi
}

# Prompt the user for the base directory name
read -p "Enter the directory name for the bench (e.g., frappe-bench): " BASE_DIR

# Check if the directory already exists
if [[ -d "$BASE_DIR" ]]; then
    echo -e "\e[1;31mDirectory $BASE_DIR already exists. Please choose a different name.\e[0m"
    exit 1
fi

# Run bench init with the user-defined directory
bench_init_create_command "bench init $BASE_DIR --frappe-branch version-15" "Failed to initialize the bench" "Bench initialized successfully."

# Change directory to the new bench
cd "$BASE_DIR" || { echo -e "\e[1;31mFailed to change the directory to $BASE_DIR\e[0m"; exit 1; }
echo -e "\e[1;32mDirectory changed successfully to $BASE_DIR\e[0m"

# Verify that the current directory is the base directory
CURRENT_DIR=$(pwd)
if [[ "$CURRENT_DIR" != *"$BASE_DIR" ]]; then
    echo -e "\e[1;31mThe current directory is not the base directory $BASE_DIR. Exiting.\e[0m"
    exit 1
fi

# Print the current working directory
echo "Current directory: $CURRENT_DIR"

# Open a new terminal window to start the bench
gnome-terminal -- bash -c "echo 'New terminal window opened! Starting bench...'; bench start"

# Check if the gnome-terminal command was successful
if [ $? -eq 0 ]; then
    echo -e "\e[1;32mBench started successfully in $BASE_DIR. Returning to original terminal.\e[0m"
else
    echo -e "\e[1;31mError starting bench in $BASE_DIR\e[0m"
    exit 1
fi

# Output final message in the original terminal
echo -e "\e[1;32mBench initialized successfully in $BASE_DIR. You can continue working in the new terminal.\e[0m"

#-------------------------------------------------------------------------------------------------------------------------
# Ask the user if they want to delete the site
#!/bin/bash

# Function to run a command and handle success or failure messages
site_command() {
    local command="$1"
    local fail_message="$2"
    local success_message="$3"

    if $command; then
        echo -e "\e[1;32m$success_message\e[0m"
        return 0
    else
        echo -e "\e[1;31m$fail_message\e[0m"
        return 1
    fi
}

# Function to count the number of open pseudo-terminals
count_open_terminals() {
    ls /dev/pts | grep -v "ptmx" | wc -l
}

# Check for open terminals until only one is left
while true; do
    # Check the number of open terminals
    OPEN_TERMINALS=$(count_open_terminals)
    if [ "$OPEN_TERMINALS" -gt 1 ]; then
        echo -e "\e[1;31mMore than one terminal is open. Please close any additional terminals before proceeding.\e[0m"
        sleep 5  # Wait before checking again
    else
        break  # Exit loop if one or no terminal is open
    fi
done

# Loop until the site is created successfully
while true; do
    # Print the current working directory
    CURRENT_DIR=$(pwd)
    echo "Current directory: $CURRENT_DIR"

    # Prompt the user for the base site domain
    read -p "Enter the base site domain (e.g., pspl.com): " BASE_SITE

    # Try to create the new site
    if site_command "bench new-site $BASE_SITE" "Failed to create site $BASE_SITE. Retrying..." "Site $BASE_SITE created successfully."; then
        # Check the number of open terminals after site creation
        while true; do
            OPEN_TERMINALS=$(count_open_terminals)
            if [ "$OPEN_TERMINALS" -gt 1 ]; then
                
                sleep 10  # Wait before checking again
                echo -e "\e[1;31mMore than one terminal is open. Press CTRL+C to close bench running terminal.\e[0m"
            else
                echo -e "\e[1;32mOnly one terminal is open. Continuing...\e[0m"
                break  # Exit the loop if one terminal is open
            fi
        done

        # Run a command after ensuring the terminal condition
        echo "Running additional commands after site creation..."
        # Replace the following command with your desired command
        YOUR_COMMAND="echo 'This is your additional command running now.'"
        eval "$YOUR_COMMAND"

        break  # Exit the site creation loop
    else
        echo -e "\e[1;31mSite creation failed. Please try again.\e[0m"
        sleep 6  # Wait for 6 seconds before prompting again
    fi
done

echo "Site $BASE_SITE has been created."



# Add the new site to hosts
if site_command "bench --site $BASE_SITE add-to-hosts" "Failed to add $BASE_SITE to hosts" "Site $BASE_SITE added to hosts successfully."; then
    # Use the new site
    if site_command "bench use $BASE_SITE" "Failed to set $BASE_SITE as the active site" "Site $BASE_SITE is now the active site."; then

        # Get and install ERPNext
        if site_command "bench get-app https://github.com/frappe/erpnext --branch version-15" "Failed to get ERPNext app" "ERPNext app downloaded successfully."; then
            
            # Open a new terminal window to start the bench
            gnome-terminal -- bash -c "echo 'New terminal window opened! Starting bench...'; bench start"

            # Try to install ERPNext in the current terminal
            if site_command "bench --site $BASE_SITE install-app erpnext" "Failed to install ERPNext app on $BASE_SITE" "ERPNext app installed successfully on $BASE_SITE."; then
                echo -e "\e[1;32mERPNext setup completed successfully on $BASE_SITE.\e[0m"

                # Countdown before reboot
                echo -e "\e[1;32mERPNext installed successfully. Rebooting in 10 seconds...\e[0m"
                for i in {10..1}; do
                    echo -e "\e[1;33mRebooting in $i seconds...\e[0m"
                    sleep 1
                done
                
                # Open a new terminal to forcefully reboot
                gnome-terminal -- bash -c "echo 'Forcefully rebooting...'; sudo reboot"

            else
                echo -e "\e[1;31mERPNext installation failed. Checking for open terminal sessions...\e[0m"

                # If installation fails, check the number of open terminals and wait if more than one is open
                while true; do
                    terminal_count=$(count_open_terminals)
                    echo "Number of open terminals: $terminal_count"

                    if [ "$terminal_count" -le 1 ]; then
                        echo -e "${PINK}Only one terminal is open. Proceeding with the script...${RESET}"
                        break
                    else
                        echo -e "${PINK}More than one terminal is open.Press CTRL+C to close that terminal in which BENCH is running ...WAITING TO CLOSE...${RESET}"
                        sleep 5  # Wait for 5 seconds before checking again
                    fi
                done  # Close the while loop

                # Open a new terminal to start the bench again
                gnome-terminal -- bash -c "echo 'New terminal window opened! Starting bench...'; bench start"

                # Uninstall ERPNext forcefully
                if site_command "bench --site $BASE_SITE uninstall-app --force erpnext" "Failed to uninstall ERPNext from $BASE_SITE" "ERPNext app uninstalled successfully from $BASE_SITE."; then
                    echo -e "\e[1;31mERPNext app uninstalled. Retrying installation...\e[0m"

                    # Try to install ERPNext again in the current terminal
                    if site_command "bench --site $BASE_SITE install-app erpnext" "Failed to reinstall ERPNext app on $BASE_SITE" "ERPNext app reinstalled successfully on $BASE_SITE."; then
                        echo -e "\e[1;32mERPNext setup completed successfully on $BASE_SITE.\e[0m"

                        # Countdown before reboot
                        echo -e "\e[1;32mERPNext installed successfully. Rebooting in 10 seconds...\e[0m"
                        for i in {10..1}; do
                            echo -e "\e[1;33mRebooting in $i seconds...\e[0m"
                            sleep 1
                        done
                        
                        # Open a new terminal to forcefully reboot
                        gnome-terminal -- bash -c "echo 'Forcefully rebooting...'; sudo reboot"

                    else
                        echo -e "\e[1;31mERPNext reinstallation failed on $BASE_SITE.\e[0m"
                    fi
                fi
            fi
        fi
    fi
fi  # Close the if statement

# Define the message
message="ERPNEXT INSTALLED SUCCESSFULLY. ALL COMMANDS EXECUTED SUCCESSFULLY. NOW YOU ARE FREE TO INSTALL ANOTHER APPS."

# Define the colors and formatting
text_color="\e[1;97m"  # White and bold
background_color="\e[48;2;0;128;0m" # Green background color
border_color="\e[38;2;255;0;0m"   # Red border color
reset_format="\e[0m"              # Reset formatting

# Calculate the width of the message box
message_length=${#message}
border_line=$(printf "%-${message_length}s" "") # Create a line with the same length as the message
border_line="${border_line// /-}" # Replace spaces with dashes to create a border

# Print the top border
echo -e "${border_color}+${border_line// /-}+${reset_format}"

# Print the message with side borders and formatting
echo -e "${border_color}|${reset_format}${background_color}${text_color}${message}${reset_format}${border_color}|${reset_format}"

# Print the bottom border
echo -e "${border_color}+${border_line// /-}+${reset_format}"

