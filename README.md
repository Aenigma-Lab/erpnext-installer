# erpnext-installer

This repository contains an automated installation script for ERPNext, designed to simplify the setup process on Ubuntu 22.04. The script installs all necessary dependencies, configures the database, and sets up a new ERPNext site with minimal user input.

## Requirements

- **Operating System**: Ubuntu 22.04
- **Sudo Privileges**: A non-root user with sudo access

## ERPNext Version

- This script installs **ERPNext version 15**.

## Usage

1. Clone the repository:
```bash
   git clone https://github.com/aenigma-lab/erpnext-installer.git
   cd erpnext-installer
```
2. Give Executable permission to repository:
```bash
   sudo chmod +x erpnext-installer.sh
```
3. Execute file:
```bash
   ./erpnext-installer-v2.sh
