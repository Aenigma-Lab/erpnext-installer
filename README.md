# ERPNext Installer 🚀

A streamlined, automated installation script for ERPNext on **Ubuntu 24.xx**. This script handles all necessary dependencies, configures the database, and sets up a brand new ERPNext site with minimal user input.

---

## Table of Contents
1. [Features](#features)
2. [Requirements](#requirements)
3. [Usage](#usage)
4. [Troubleshooting](#troubleshooting)
5. [Contributing](#contributing)
6. [License](#license)

---

## Features ✨

- **One-Line Installation**: Simplifies setting up ERPNext by automating the entire process.
- **Minimal Input**: Only essential prompts to reduce time and errors.
- **System Setup**: Installs and configures all dependencies (Node, Redis, MariaDB, etc.).
- **ERPNext Version 15**: Installs the latest stable version (v15).

---

## Requirements ✅

- **Operating System**: Ubuntu 24.xx  
- **Non-Root User**: You should be logged in as a user with `sudo` privileges.

> **Note**: The script automatically installs any missing dependencies. However, ensure your system is up to date by running:
> ```bash
> sudo apt update && sudo apt upgrade -y
> ```

---

## Usage 📖

1. **Clone the repository**:
   ```bash
   git clone https://github.com/aenigma-lab/erpnext-installer.git
   cd erpnext-installer
2. **Grant executable permissions**:
```bash
   sudo chmod +x erpnext-installer.sh
```
3. **Run the installer**:
```bash
./erpnext-installer.sh
```
## License 📜
• This project is licensed under the MIT License. You’re free to modify and distribute this software as per the license conditions.

