# 🚀 ERPNext Installer for 🐧 Ubuntu 22.xx / 24.xx

A streamlined, automated shell script to install **ERPNext v15** on **Ubuntu 24.xx** or **Ubuntu 22.xx**. This script handles everything — from system dependencies to setting up your ERPNext site — with minimal manual steps.

---

## 📚 Table of Contents

1. [✨ Features](#-features)
2. [✅ Requirements](#-requirements)
3. [📖 Usage](#-usage)
4. [🧩 ERPNext Multi-App Installer](#-erpnext-multi-app-installer)
5. [📜 License](#-license)

---

## ✨ Features  <a name="features"></a>

- ⚡ **One-Line Installation**  
  Fully automated setup of ERPNext and its dependencies.

- 🧠 **Minimal Input**  
  Just a few prompts — reduces manual error and saves time.

- 🛠️ **System Configuration**  
  Installs and configures Node.js, Redis, MariaDB, Nginx, Yarn, wkhtmltopdf, and more.

- 📦 **Bench & Frappe Setup**  
  Prepares the latest stable version of Bench and ERPNext (v15).

- 🏗️ **New Site Creation**  
  Automatically creates a fresh ERPNext site with the database and admin login.

---

## ✅ Requirements  <a name="requirements"></a>

- 🐧 **Operating System**: Ubuntu 24.xx LTS OR Ubuntu 22.xx LTS
- 👤 **Non-Root User**: You must use a sudo-enabled user (not root)

> **Update your system before installation:**
```bash
sudo apt update && sudo apt upgrade -y
```

```bash
- **Operating System**: Ubuntu 24.xx  OR Ubuntu 22.xx
- **Non-Root User**: You should be logged in as a user with `sudo` privileges.

> **Note**: The script automatically installs any missing dependencies. However, ensure your system is up to date by running:
> ```bash
> sudo apt update && sudo apt upgrade -y
> ```
```
---

## 📖 Usage  <a name="usage"></a>
```bash
1. **Clone the repository**:
   ```bash
   git clone https://github.com/aenigma-lab/erpnext-installer.git
   cd erpnext-installer
2. **Grant executable permissions**:
```bash
   sudo chmod +x erpnext-installer.sh
```

**Run the installer**:
```bash
./erpnext-installer.sh
```
## 🧩 ERPNext Multi-App Installer (`erpnext_app_installation_script.sh`)  <a name="erpnext-multi-app-installer"></a>

Do you manage **multiple custom apps**? This script lets you install and link them to your ERPNext site with ease.

---

## 🛠 How to Use

```bash
sudo chmod +x erpnext_app_installation_script.sh
./erpnext_app_installation_script.sh
```

## 📜 License  <a name="license"></a>
• This project is licensed under the MIT License. You’re free to modify and distribute this software as per the license conditions.

## 🧪 Tested On

    ✅ Ubuntu 24.04 LTS  AND uBUNTU 22.04 LTS (Fresh Install)

    ✅ ERPNext v15.53+

    ✅ MariaDB 10.6 / 10.11

## 👤 Author

**Shubham Mishra**  
[GitHub: @Aenigma-Lab](https://github.com/Aenigma-Lab)

