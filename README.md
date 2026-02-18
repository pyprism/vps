# VPS Ansible Setup

A modular, extensible Ansible-based solution for setting up Debian/Ubuntu VPS servers.

## Features

- **Single Configuration File**: Edit only `config.yml` before running
- **Modular Roles**: Each component is a separate, reusable role
- **Flexible Installation**: Enable/disable components via flags
- **Secure by Default**: UFW firewall, SSH hardening, CrowdSec protection
- **Modern Stack**: Docker, Node.js, Python, PostgreSQL, Redis, Nginx

## Quick Start

1. **Configure your VPS settings**:
   ```bash
   cp config.yml.example config.yml
   # Edit config.yml with your VPS details
   nano config.yml
   ```

2. **Run the setup**:
   ```bash
   ./run.sh setup -k
   ```

3. **Optional: Install VNC desktop**:
   ```bash
   ./run.sh vnc
   ```

## Configuration

Edit `config.yml` to customize your setup. This is the **only file** you need to edit.

### Key Settings

| Setting | Description |
|---------|-------------|
| `vps_host` | Your VPS IP or hostname |
| `new_username` | Username for the new user |
| `new_user_password` | Password for the new user |
| `ssh_port` | SSH port (default: 22) |
| `install_*` | Enable/disable components |

### Installation Flags

```yaml
install_common_packages: true
install_nodejs: true
install_nginx: true
install_python: true
install_postgresql: true
install_redis: true
install_docker: true
install_zsh: true
install_crowdsec: true
install_tailscale: true
install_homebrew: true
install_mysql: false  # Set to true if needed
```

## Usage

### Full Setup
```bash
./run.sh setup -k
```

### Install Specific Component
```bash
./run.sh docker    # Install Docker only
./run.sh nginx     # Install Nginx only
./run.sh nodejs    # Install Node.js only
```

### Install VNC Desktop
```bash
./run.sh vnc
```

### Backup Databases
```bash
./run.sh backup    # Backup all MySQL and PostgreSQL databases to local machine
```

#### Restore from backup

##### MySQL/MariaDB
```bash
# Decompress and restore
gunzip < backup/2026-02-17/mysql_dbname_*.sql.gz | mysql -u root -p dbname

# Or in one command
gunzip < backup/2026-02-17/mysql_dbname_*.sql.gz | mysql -u root -p dbname
```

##### PostgreSQL
```bash
# Decompress and restore
gunzip < backup/2026-02-17/postgresql_dbname_*.sql.gz | psql -U postgres dbname

# Or create database first if needed
createdb dbname
gunzip < backup/2026-02-17/postgresql_dbname_*.sql.gz | psql -U postgres dbname
```


### Dry Run (Check Mode)
```bash
./run.sh check
```

### Verbose Output
```bash
./run.sh setup -v
```

## Available Roles

| Role | Description |
|------|-------------|
| `common` | Essential packages, timezone, locale |
| `security` | SSH hardening, UFW firewall |
| `user` | Create user, sudo access, Homebrew |
| `docker` | Docker CE and Docker Compose |
| `nodejs` | Node.js via NodeSource |
| `python` | Python 3.x with pip |
| `nginx` | Nginx with SSL configuration |
| `postgresql` | PostgreSQL database |
| `redis` | Redis server |
| `database` | MySQL/MariaDB |
| `zsh` | Zsh with Oh My Zsh |
| `crowdsec` | CrowdSec security |
| `tailscale` | Tailscale VPN |
| `vnc` | TightVNC with LXDE desktop |

## Directory Structure

```
ansible/
├── config.yml           # Main configuration (EDIT THIS)
├── run.sh               # Runner script
├── ansible.cfg          # Ansible configuration
├── inventory            # Generated inventory
├── playbooks/
│   ├── setup.yml        # Main setup playbook
│   └── vnc.yml          # VNC installation playbook
└── roles/
    ├── common/
    ├── security/
    ├── user/
    ├── docker/
    ├── nodejs/
    ├── python/
    ├── nginx/
    ├── postgresql/
    ├── redis/
    ├── database/
    ├── zsh/
    ├── crowdsec/
    ├── tailscale/
    └── vnc/
```

## VNC Access

After installing VNC, connect securely via SSH tunnel:

1. Create SSH tunnel from your local machine:
   ```bash
   ssh -L 5901:localhost:5901 user@your-vps -p 22
   ```

2. Connect with VNC client to:
   ```
   localhost:5901
   ```
   note: or use tailscale to connect vnc

## Adding New Roles

1. Create role directory:
   ```bash
   mkdir -p roles/newrole/{tasks,handlers,defaults}
   ```

2. Create `roles/newrole/tasks/main.yml`

3. Add to `playbooks/setup.yml` if needed

4. Add to `run.sh` command list

## Requirements

- Ansible 2.9+ on your local machine
- Fresh Debian 11+ or Ubuntu 20.04+ VPS
- SSH access to VPS (root or sudo user)

## License

MIT

