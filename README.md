A collection of simple scripts to help automate Nessus licensing and service management.

## 📦 Installation

```bash
git clone https://github.com/securiben/newsus.git
cd newsus
chmod +x *.sh
```

## 🚀 Usage

### 1. Grab License Key

Extracts or retrieves a Nessus license key.

```bash
./GrabLicenseKey.sh
```

### 2. Activate Nessus License (Python Script)

```bash
python3 nessuslicense.py
```

### 3. Nessus Service Helper

Start, stop, or restart Nessus services.

```bash
./nessus.sh start
./nessus.sh stop
./nessus.sh restart
```

## 📁 File Description

* **GrabLicenseKey.sh** — Shell script to retrieve or parse license keys.
* **nessuslicense.py** — Python-based license activation helper.
* **nessus.sh** — Simple Nessus service management tool.

## 📝 Notes

* Make sure you have the required permissions to run the scripts.
* Run all commands as root or using `sudo`.

## ✔️ Tested On

* Ubuntu 20.04
* Ubuntu 22.04
