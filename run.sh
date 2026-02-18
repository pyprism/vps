#!/bin/bash
# =============================================================================
# VPS Ansible Runner Script
# =============================================================================
# Usage:
#   ./run.sh setup     - Run full VPS setup, use -k for password prompt, -i for SSH key, -v for verbose
#   ./run.sh vnc       - Install VNC with LXDE
#   ./run.sh <role>    - Run a specific role
#   ./run.sh --help    - Show help
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

CONFIG_FILE="config.yml"
INVENTORY_FILE="inventory"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored message
print_msg() {
    echo -e "${2}${1}${NC}"
}

# Show help
show_help() {
    echo "VPS Ansible Setup"
    echo ""
    echo "Usage: ./run.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  setup          Run full VPS setup with all enabled components"
    echo "  vnc            Install VNC with LXDE desktop environment"
    echo "  backup         Backup all databases to local machine"
    echo "  check          Run in check mode (dry run)"
    echo "  <role>         Run a specific role (docker, nginx, nodejs, etc.)"
    echo ""
    echo "Options:"
    echo "  -k, --ask-pass    Prompt for SSH password"
    echo "  -i, --key <path>  Path to SSH private key"
    echo "  -v, --verbose     Run with verbose output"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Available roles:"
    echo "  common, security, user, docker, nginx, nodejs, python,"
    echo "  postgresql, redis, database (mysql), zsh, crowdsec, tailscale, vnc"
    echo ""
    echo "Configuration:"
    echo "  Edit config.yml to customize your setup"
    echo ""
    echo "Examples:"
    echo "  ./run.sh setup              # Full setup (uses default SSH key)"
    echo "  ./run.sh setup -k           # Full setup with password prompt"
    echo "  ./run.sh setup -i ~/.ssh/id_rsa  # Full setup with specific key"
    echo "  ./run.sh vnc                # Install VNC only"
    echo "  ./run.sh backup             # Backup all databases"
    echo "  ./run.sh docker             # Install Docker only"
    echo "  ./run.sh setup -v           # Full setup with verbose output"
}

# Check if config.yml exists
check_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        print_msg "Error: config.yml not found!" "$RED"
        print_msg "Please copy config.yml.example to config.yml and configure it." "$YELLOW"
        exit 1
    fi
}

# Parse config.yml and generate inventory
generate_inventory() {
    local vps_host=$(grep "^vps_host:" "$CONFIG_FILE" | awk '{print $2}' | tr -d '"' | tr -d "'")
    local vps_port=$(grep "^vps_ssh_port:" "$CONFIG_FILE" | awk '{print $2}' | tr -d '"' | tr -d "'")
    local ansible_user=$(grep "^ansible_user:" "$CONFIG_FILE" | awk '{print $2}' | tr -d '"' | tr -d "'")
    local python_interpreter=$(grep "^ansible_python_interpreter:" "$CONFIG_FILE" | awk '{print $2}' | tr -d '"' | tr -d "'")
    local local_python=$(grep "^ansible_playbook_python:" "$CONFIG_FILE" | awk '{print $2}' | tr -d '"' | tr -d "'")

    if [ -z "$vps_host" ] || [ "$vps_host" == "your-vps-ip-or-hostname" ]; then
        print_msg "Error: Please configure vps_host in config.yml" "$RED"
        exit 1
    fi

    vps_port=${vps_port:-22}
    ansible_user=${ansible_user:-root}
    python_interpreter=${python_interpreter:-/usr/bin/python3}
    local_python=${local_python:-/usr/bin/python3}

    cat > "$INVENTORY_FILE" << EOF
[vps]
$vps_host ansible_port=$vps_port ansible_user=$ansible_user ansible_python_interpreter=$python_interpreter

[local]
127.0.0.1 ansible_connection=local ansible_python_interpreter=$local_python
EOF

    print_msg "Generated inventory for: $vps_host" "$GREEN"
}

# Check if Ansible is installed
check_ansible() {
    if ! command -v ansible-playbook &> /dev/null; then
        print_msg "Ansible is not installed. Installing..." "$YELLOW"
        if command -v brew &> /dev/null; then
            brew install ansible
        elif command -v pip3 &> /dev/null; then
            pip3 install ansible
        else
            print_msg "Error: Please install Ansible manually" "$RED"
            exit 1
        fi
    fi
}

# Install required Ansible collections
install_collections() {
    print_msg "Installing required Ansible collections..." "$BLUE"
    ansible-galaxy collection install community.general community.mysql community.crypto --force-with-deps 2>/dev/null || true
}

# Run a specific role
run_role() {
    local role_name="$1"
    local extra_args="${@:2}"

    print_msg "Running role: $role_name" "$BLUE"

    # Create a temporary playbook for the role
    local temp_playbook=$(mktemp)
    cat > "$temp_playbook" << EOF
---
- name: Run $role_name role
  hosts: vps
  become: true
  vars_files:
    - config.yml

  pre_tasks:
    - name: Update apt cache
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600

  roles:
    - role: $role_name
EOF

    ansible-playbook -i "$INVENTORY_FILE" "$temp_playbook" -e "@$CONFIG_FILE" $extra_args
    rm -f "$temp_playbook"
}

# Run main setup
run_setup() {
    local extra_args="$@"
    print_msg "Running full VPS setup..." "$BLUE"
    ansible-playbook -i "$INVENTORY_FILE" playbooks/setup.yml -e "@$CONFIG_FILE" $extra_args
}

# Run VNC setup
run_vnc() {
    local extra_args="$@"
    print_msg "Installing VNC with LXDE..." "$BLUE"
    ansible-playbook -i "$INVENTORY_FILE" playbooks/vnc.yml -e "@$CONFIG_FILE" $extra_args
}

# Run database backup
run_backup() {
    local extra_args="$@"
    print_msg "Backing up databases..." "$BLUE"
    # Don't pass config.yml as extra vars to avoid ansible_python_interpreter conflicts
    # The inventory file already contains the necessary connection parameters
    ansible-playbook -i "$INVENTORY_FILE" playbooks/backup.yml $extra_args
}

# Main
main() {
    local command=""
    local extra_args=""
    local verbose=""
    local ssh_args=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                verbose="-vvv"
                shift
                ;;
            -k|--ask-pass)
                ssh_args="$ssh_args --ask-pass"
                shift
                ;;
            -i|--key)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    ssh_args="$ssh_args --private-key=$2"
                    shift 2
                else
                    print_msg "Error: --key requires a path argument" "$RED"
                    exit 1
                fi
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            --check)
                extra_args="$extra_args --check"
                shift
                ;;
            -*)
                print_msg "Unknown option: $1" "$RED"
                show_help
                exit 1
                ;;
            *)
                if [ -z "$command" ]; then
                    command="$1"
                fi
                shift
                ;;
        esac
    done

    # Default command
    command="${command:-help}"
    extra_args="$extra_args $verbose $ssh_args"

    case $command in
        help|--help|-h)
            show_help
            exit 0
            ;;
        setup)
            check_config
            check_ansible
            install_collections
            generate_inventory
            run_setup $extra_args
            ;;
        vnc)
            check_config
            check_ansible
            install_collections
            generate_inventory
            run_vnc $extra_args
            ;;
        backup)
            check_config
            check_ansible
            install_collections
            generate_inventory
            run_backup $extra_args
            ;;
        check)
            check_config
            check_ansible
            install_collections
            generate_inventory
            run_setup "$extra_args --check"
            ;;
        common|security|user|docker|nginx|nodejs|python|postgresql|redis|database|zsh|crowdsec|tailscale)
            check_config
            check_ansible
            install_collections
            generate_inventory
            run_role "$command" $extra_args
            ;;
        *)
            print_msg "Unknown command: $command" "$RED"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
