# **e-Monitoring System Setup Guide**

This guide provides technical instructions for configuring the local development environment (`DEV`) and preparing the configuration for deployment (`PROD`) for the **e-Monitoring System**.

---

## **Architecture & System Requirements**

- **Core Engine:** PHP 7.4 – 8.x
- **Database Target:** MySQL 8.0+ / MariaDB 10.4+ (`e_monitoring`)
- **Frontend Stack:** Pure HTML5, CSS3, JavaScript
- **Architecture:** Modular MVC / Front-Controller layout with a custom `.env` runtime parser
- **Default Timezone:** `Asia/Manila` (`UTC+8`)
- **Max Payload Limit:** `20MB`
- **Session Strategy:** Encrypted dynamic sessions (`dev_e_monitoring_session` / `e_monitoring_session`)
- **Web Server:** Apache 2.4+ (XAMPP) with URL rewrite (`mod_rewrite`) enabled

---

## **Environment Configuration (`/.env`)**

Create a file named `.env` in the root directory of your project (`C:\xampp\htdocs\dev_e_monitoring\.env`) and copy the baseline configuration below:

```ini
# ======================================================================
# e-Monitoring System
# Location: /.env
# ======================================================================

# SYSTEM ACCESS NAME
SYSTEM_ACCESS_NAME = "e-Monitoring System"

# ----------------------------------------------------------------------
# SYSTEM_FLAG toggles global diagnostic layers. Options: DEV | PROD
# DEV  - Enables local subfolder setups, verbose error printing, and diagnostic logs
# PROD - Disables onscreen error outputs, enables secure system silence
SYSTEM_FLAG = DEV

# ----------------------------------------------------------------------
# FILE VERSION
FILE_VERSION = 1.0.0

# ----------------------------------------------------------------------
# PERSISTENCE STORAGE ENGINE CREDENTIALS
DB_HOST = 127.0.0.1
DB_PORT = 3306
DB_USER = root
DB_PASS = 
DB_NAME = e_monitoring

# ----------------------------------------------------------------------
# SYSTEM RUNTIME & SECURITY
APP_TIMEZONE = Asia/Manila
MAX_PAYLOAD_LIMIT = 20M

# ----------------------------------------------------------------------
# NETWORK REWRITE & LOCAL SUBFOLDER OFFSETS

# DEVELOPMENT DOMAIN ANCHORS
LOCAL_SUBFOLDER = dev_e_monitoring
API_LOCAL_SUBFOLDER = ''

# PRODUCTION DOMAIN ANCHORS
PRODUCTION_DOMAIN = 
API_PRODUCTION_DOMAIN = 

# Session Cookie Identity Name Configuration
SESSION_NAME = dev_e_monitoring_session

# ----------------------------------------------------------------------
# SMTP SECURE MAIL
SMTP_USER = 
SMTP_PASS =


## **Local Initialization & Installation**
* **Directory Setup**: Place the repository under your local server root matching LOCAL_SUBFOLDER:
    * XAMPP: C:/xampp/htdocs/dev_e_monitoring
    * WAMP: C:/wamp64/www/dev_e_monitoring
    * LAMP: /var/www/html/dev_e_monitoring
    * MAMP: /Applications/MAMP/htdocs/dev_e_monitoring

* **Database Setup**:
    1. Open your database management tool (phpMyAdmin, DBeaver, MySQL Workbench).
    2. Create the target schema:
    ```sql
    CREATE DATABASE e_monitoring CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    ```
    3. Import your database SQL seed directly into `e_monitoring`.