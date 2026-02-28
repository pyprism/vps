#!/bin/bash

# This script fetches the latest Cloudflare IP ranges and updates the Nginx configuration snippet accordingly.

# Configuration
CLOUDFLARE_FILE="/etc/nginx/snippets/cloudflare-realip.conf"
NGINX_CONF_TEST="nginx -t"

# Fetch latest IPs from Cloudflare
CF_IPV4=$(curl -s https://www.cloudflare.com/ips-v4)
CF_IPV6=$(curl -s https://www.cloudflare.com/ips-v6)

# Start building the snippet content
{
    echo "# Updated on $(date)"
    echo "# Cloudflare IPv4"
    for ip in $CF_IPV4; do
        echo "set_real_ip_from $ip;"
    done

    echo -e "\n# Cloudflare IPv6"
    for ip in $CF_IPV6; do
        echo "set_real_ip_from $ip;"
    done

    echo -e "\nreal_ip_header CF-Connecting-IP;"
} > "${CLOUDFLARE_FILE}.tmp"

# Check if the temporary file is valid Nginx syntax
if $NGINX_CONF_TEST > /dev/null 2>&1; then
    mv "${CLOUDFLARE_FILE}.tmp" "$CLOUDFLARE_FILE"
    systemctl reload nginx
    echo "Cloudflare IPs updated and Nginx reloaded."
else
    echo "Error: Generated snippet caused Nginx config failure. Rollback initiated."
    rm "${CLOUDFLARE_FILE}.tmp"
    exit 1
fi