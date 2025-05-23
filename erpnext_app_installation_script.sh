#!/bin/bash

# Function to show spinner animation

spinner() {
    local pid=$1
    local delay=0.2
    local frames=("⠋" "⠙" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local frame_count=${#frames[@]}
    local i=0

    echo -n " "
    while kill -0 $pid 2>/dev/null; do
        printf "\r%s " "${frames[i]}"
        i=$(( (i + 1) % frame_count ))
        sleep $delay
    done
    printf "\r✓ Done!  \n"
}

# Ask user for bench name and site name
read -p "Enter your bench directory name: " BENCH_NAME
read -p "Enter your site name (e.g., pspl.com): " SITE_NAME

# Go to bench directory
cd "$BENCH_NAME" || { echo "Bench directory not found! Exiting."; exit 1; }

# Function to start bench
start_bench() {
    echo -n "     Starting bench...          "
    nohup bench start > bench.log 2>&1 &
    local bench_pid=$!
    ( sleep 10 ) & spinner $!
    echo "Bench started (PID: $bench_pid)."
}

# Function to stop bench
stop_bench() {
    echo -n "        Stopping bench...          "
    pkill -f "frappe.utils" >/dev/null 2>&1
    ( sleep 5 ) & spinner $!
    echo "Bench stopped."
}

# Declare apps (name, branch, repo)
apps=(
    "erpnext_telegram_integration master https://github.com/yrestom/erpnext_telegram.git"
    "helpdesk version-14 https://github.com/frappe/helpdesk.git"
    "hrms version-15 https://github.com/frappe/hrms.git"
    "india_compliance version-15 https://github.com/resilient-tech/india-compliance.git"
    "pl_accounts version-15 https://github.com/precihole/pl_accounts.git"
    "preciholesports main https://github.com/precihole/preciholesports.git"
    "shift_rotation master https://github.com/precihole/shift_rotation.git"
    "tidraw_whiteboard develop https://github.com/NagariaHussain/tldraw_whiteboard.git"
    "wiki version-15 https://github.com/frappe/wiki.git"
    "design version-14 https://github.com/precihole/design.git"
    "bank_api_integration version-15 https://github.com/aerele/bank_api_integration.git"
    "insights main https://github.com/frappe/insights.git"
)

# Track installed apps
installed_apps=()

# Process each app
for app_entry in "${apps[@]}"; do
    read -r app_name branch repo <<< "$app_entry"

    read -p "Do you want to install app '$app_name'? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
        echo "Skipping $app_name..."
        continue
    fi

    # Start bench before app installation
    start_bench

    # bench get-app with animation
    echo -n "Getting app $app_name..."
    if [[ -n "$branch" ]]; then
        ( bench get-app "$app_name" --branch "$branch" "$repo" ) & spinner $!
    else
        ( bench get-app "$app_name" "$repo" ) & spinner $!
    fi

    # bench install-app with animation
    echo -n "Installing app $app_name on site $SITE_NAME..."
    ( bench --site "$SITE_NAME" install-app "$app_name" ) & spinner $!

    # Stop bench after app installation
    stop_bench

    # Add to installed list
    installed_apps+=("$app_name")
done

# Print installed apps
echo ""
echo "✅ Apps installed:"
for app in "${installed_apps[@]}"; do
    echo "- $app"
done

