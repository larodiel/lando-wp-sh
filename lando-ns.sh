#!/bin/bash

# ============================================================================
# Lando WordPress Development Environment Setup Script
# ============================================================================
# This script automates the creation of WordPress environments using Lando
# Author: Victor Larodiel
# Version: 1.0
# ============================================================================

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================================================
# Funções Auxiliares
# ============================================================================

usage() {
    echo -e "${GREEN}Usage: $0 <site-name> [OPTIONS]${NC}"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  --php VERSION           Set PHP version (default: 8.2, interactive if not set)"
    echo "  --mysql VERSION         Set MySQL version (default: 8.0, interactive if not set)"
    echo "  --plugins FILE          File with Git plugin URLs (one per line)"
    echo "  --plugin URL            Add a Git plugin URL (repeatable)"
    echo "  --skip-docker-check     Skip Docker verification"
    echo "  --revisions N           Set post revisions limit (default: 10, interactive if not set)"
    echo ""
    echo "This script sets up a WordPress development environment with Lando."
    echo "A new directory named <site-name> will be created in the current directory."
    echo ""
    echo "If PHP, MySQL, or revisions are not specified via arguments, the script will"
    echo "prompt you to select them interactively."
    echo ""
    echo "Example (non-interactive):"
    echo "  $0 my-site --php 8.3 --mysql 8.0 --plugins plugins.txt --revisions 5"
    echo ""
    echo "Example (interactive):"
    echo "  $0 my-site"
    exit 0
}

print_header() {
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BLUE}$1${NC}"
    echo -e "${CYAN}  ╚════════════════════════════════════════════════════════════╝${NC}\n"
}

print_step() {
    echo -e "${YELLOW}▸ $1...${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ Error: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ Warning: $1${NC}"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 não está instalado. Por favor, instale antes de continuar."
        exit 1
    fi
}

# ============================================================================
# Dependency Validation
# ============================================================================

check_dependencies() {
    print_step "Checking dependencies"

    local missing_deps=()

    for cmd in lando wget tar sed ruby php; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "The following dependencies are missing: ${missing_deps[*]}"
        echo "Please install them before continuing."
        exit 1
    fi

    print_success "All dependencies are installed"
}

# ============================================================================
# Argument Processing
# ============================================================================

slug=""
PHP_VERSION="8.2"
MYSQL_VERSION="8.0"
PLUGINS_FILE=""
PLUGIN_URLS=()
SKIP_DOCKER_CHECK=false
REVISION_LIMIT="10"

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        --php)
            PHP_VERSION="$2"
            shift 2
            ;;
        --mysql)
            MYSQL_VERSION="$2"
            shift 2
            ;;
        --plugins)
            PLUGINS_FILE="$2"
            shift 2
            ;;
        --plugin)
            PLUGIN_URLS+=("$2")
            shift 2
            ;;
        --skip-docker-check)
            SKIP_DOCKER_CHECK=true
            shift
            ;;
        --revisions)
            REVISION_LIMIT="$2"
            shift 2
            ;;
        *)
            if [ -z "$slug" ]; then
                slug="$1"
            else
                print_error "Unknown option or too many arguments: $1"
                usage
            fi
            shift
            ;;
    esac
done

# ============================================================================
# Initial Validations
# ============================================================================

if [ -z "$slug" ]; then
    print_error "The <site-name> argument is required"
    usage
fi

# Validate plugins file if provided
if [ -n "$PLUGINS_FILE" ] && [ ! -f "$PLUGINS_FILE" ]; then
    print_error "Plugins file not found: $PLUGINS_FILE"
    exit 1
fi

SITE_BASE_DIR="$PWD"
SITE_PATH="$SITE_BASE_DIR/$slug"

# Sanitize slug for domain use
slug_sanitized=$(printf '%s' "$slug" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9-]+/-/g; s/^-+//; s/-+$//; s/-+/-/g')
if [ -z "$slug_sanitized" ]; then
    print_error "Site name results in an empty domain after sanitization"
    exit 1
fi
SITE_DOMAIN="${slug_sanitized}.lndo.site"

# ============================================================================
# Main Script Start
# ============================================================================

print_header "LANDO WORDPRESS SETUP - $slug_sanitized"

check_dependencies

# Check if Docker is running
if [ "$SKIP_DOCKER_CHECK" = false ]; then
    print_step "Checking Docker"
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    print_success "Docker is running"
fi

# Check if directory already exists
if [ -d "$SITE_PATH" ]; then
    print_error "Directory '$SITE_PATH' already exists"
    exit 1
fi

# ============================================================================
# Interactive Configuration (if not provided via arguments)
# ============================================================================

# PHP Version Selection (interactive if not set via --php)
if [ "$PHP_VERSION" = "8.2" ]; then
    echo ""
    printf "${YELLOW}Select PHP version for Lando (e.g., 7.4, 8.0, 8.1, 8.2, 8.3): ${NC}"
    read -p "PHP Version [8.2]: " USER_PHP_VERSION
    PHP_VERSION=${USER_PHP_VERSION:-8.2}
fi
echo -e "${GREEN}Using PHP version: $PHP_VERSION${NC}"

# MySQL Version Selection (interactive if not set via --mysql)
if [ "$MYSQL_VERSION" = "8.0" ]; then
    echo ""
    printf "${YELLOW}Select MySQL version for Lando (e.g., 5.7, 8.0): ${NC}"
    read -p "MySQL Version [8.0]: " USER_MYSQL_VERSION
    MYSQL_VERSION=${USER_MYSQL_VERSION:-8.0}
fi
echo -e "${GREEN}Using MySQL version: $MYSQL_VERSION${NC}"

# Post Revisions Configuration (interactive if not set via --revisions)
if [ "$REVISION_LIMIT" = "10" ]; then
    echo ""
    read -p "Do you want to set a WordPress post revisions limit? (yes/no) [yes]: " REVISION_ANSWER
    REVISION_ANSWER=${REVISION_ANSWER:-yes}
    if [[ "$REVISION_ANSWER" =~ ^[Yy] ]]; then
        read -p "Enter the number of post revisions to keep (e.g., 5, 10, 0 for unlimited) [10]: " USER_REVISION_LIMIT
        REVISION_LIMIT=${USER_REVISION_LIMIT:-10}
    else
        REVISION_LIMIT=""
    fi
fi

if [ -n "$REVISION_LIMIT" ]; then
    echo -e "${GREEN}Post revisions limit set to: $REVISION_LIMIT${NC}"
fi

echo ""

# ============================================================================
# Directory Structure Creation
# ============================================================================

print_step "Creating directory structure"
mkdir -p "$SITE_PATH/.lando"
print_success "Directories created"

# ============================================================================
# Configuration Files Download
# ============================================================================

print_step "Downloading Lando configuration files"

if ! wget -q https://github.com/borkweb/windows-dev-environment/raw/main/lando/.lando/php.wsl.ini -P "$SITE_PATH/.lando"; then
    print_error "Failed to download php.wsl.ini"
    exit 1
fi

lando version --component @lando/wordpress > /dev/null 2>&1
if [ $? -ne 0 ]; then
    lando plugin-add @lando/wordpress
    if [ $? -ne 0 ]; then
        print_error "Failed to add @lando/wordpress plugin"
        exit 1
    fi
fi

cd "$SITE_PATH" || exit 1

# Download/extract WordPress on host to avoid container write issues on /app
if ! wget -q https://wordpress.org/latest.tar.gz -O "$SITE_PATH/latest.tar.gz"; then
    print_error "Failed to download WordPress archive on host"
    exit 1
fi

if ! tar -xzf "$SITE_PATH/latest.tar.gz" -C "$SITE_PATH"; then
    print_error "Failed to extract WordPress archive on host"
    exit 1
fi

rm -f "$SITE_PATH/latest.tar.gz"



if ! lando init \
    --source cwd \
    --recipe wordpress \
    --webroot wordpress \
    --name "$slug_sanitized" \
    --option php="$PHP_VERSION" \
    --option database="mysql:$MYSQL_VERSION" \
    --option xdebug="debug" \
    --option via="nginx"; then
    print_error "Lando init failed"
    exit 1
fi

# Patch .lando.yml for better host-container compatibility and add Redis/Mailhog/PhpMyAdmin services
print_step "Patching .lando.yml permission compatibility"
ruby - "$SITE_PATH/.lando.yml" <<'RUBY'
require 'yaml'
file = ARGV[0]
config = YAML.load_file(file)
config['services'] ||= {}

# Appserver configuration for better host-container file permission compatibility
config['services']['appserver'] ||= {}
config['services']['appserver']['overrides'] ||= {}
config['services']['appserver']['overrides']['environment'] ||= {}
config['services']['appserver']['overrides']['environment']['LANDO_FILE_PERMISSION_FIX'] = true
config['services']['appserver']['overrides']['environment']['LANDO_HOST_IP'] = 'host.docker.internal'
config['services']['appserver']['overrides']['environment']['XDEBUG_CONFIG'] = 'client_host=host.docker.internal'

# Add Redis service
config['services']['redis'] ||= {}
config['services']['redis']['type'] = 'redis'
config['services']['redis']['portforward'] = true

# Add PHPMyAdmin service
config['services']['phpmyadmin'] ||= {}
config['services']['phpmyadmin']['type'] = 'phpmyadmin'

yaml = YAML.dump(config)
# Ensure list items under hogfrom are indented under the key.
yaml.gsub!(/^(\s*hogfrom:\s*)\n(\s*)- /, "\\1\n\\2  - ")
File.write(file, yaml)
RUBY
print_success ".lando.yml patched"

# Start it up
print_step "Starting Lando (this may take a few minutes on first run)"
if ! lando start; then
    print_warning "Lando returned warnings/errors. Verifying whether appserver is actually running..."
    if lando ssh -s appserver -c "php -v" > /dev/null 2>&1; then
        print_warning "Lando appserver is reachable despite startup warnings. Continuing."
    else
        print_error "Lando failed to start"
        exit 1
    fi
fi

cd $SITE_PATH/wordpress

# Verify WP-CLI is available
print_step "Verifying WP-CLI installation"
if ! lando wp cli version; then
    print_error "WP-CLI is not available. Try rebuilding: cd $SITE_PATH && lando rebuild -y"
    exit 1
fi
print_success "WP-CLI is working"

# ============================================================================
# wp-config.php Configuration
# ============================================================================

print_step "Downloading wp-config.php $SITE_PATH/wordpress"
if ! wget -q https://github.com/borkweb/windows-dev-environment/raw/main/lando/wp/wp-config.php -P "$SITE_PATH/wordpress"; then
    print_error "Failed to download wp-config.php"
    exit 1
fi
chmod 644 "$SITE_PATH/wordpress/wp-config.php"
print_success "wp-config.php downloaded"

# Install WordPress
print_step "Installing WordPress"
if ! lando wp core install \
    --url="https://$slug_sanitized.lndo.site/" \
    --title="My First WordPress App" \
    --admin_user=admin \
    --admin_password=admin \
    --admin_email="admin@$slug_sanitized.lndo.site" \
    --allow-root \
    --path=/app/wordpress; then
        print_error "Failed to install WordPress via WP-CLI"
        exit 1
fi
print_success "WordPress installed successfully"

print_success "Configuration files downloaded"

# Configure revisions limit
if [ -n "$REVISION_LIMIT" ]; then
    print_step "Configuring revisions limit to $REVISION_LIMIT"
    ruby - "$SITE_PATH/wordpress/wp-config.php" "$REVISION_LIMIT" <<'RUBY'
file, limit = ARGV
content = File.read(file)
define_line = "define( 'WP_POST_REVISIONS', #{limit} );\n"

if content.match?(/define\( 'WP_POST_REVISIONS',/)
    content.gsub!(/define\( 'WP_POST_REVISIONS', .*?\);\s*\n/, define_line)
else
    content.sub!(/\$table_prefix = 'wp_';/) { "#{define_line}#{$&}" }
end

File.write(file, content)
RUBY
    print_success "Revisions limit configured"
fi

# ============================================================================
# Default Plugins Cleanup
# ============================================================================

print_step "Removing default plugins (Hello Dolly and Akismet)"
rm -f "$SITE_PATH/wordpress/wp-content/plugins/hello.php"
rm -rf "$SITE_PATH/wordpress/wp-content/plugins/akismet"
print_success "Default plugins removed"

# ============================================================================
# Git Plugins Download
# ============================================================================

install_plugin_from_url() {
    local plugin_url="$1"
    # Ignore empty lines and comments
    [[ -z "$plugin_url" || "$plugin_url" =~ ^[[:space:]]*# ]] && return 0

    # Remove whitespace
    plugin_url=$(echo "$plugin_url" | xargs)
    [ -z "$plugin_url" ] && return 0

    # Extract plugin name from URL
    local plugin_name
    plugin_name=$(basename "$plugin_url" .git)

    print_step "Downloading plugin: $plugin_name"

    local plugin_path="$SITE_PATH/wordpress/wp-content/plugins/$plugin_name"

    if [ -d "$plugin_path" ]; then
        print_warning "Plugin $plugin_name already exists, skipping..."
        return 0
    fi

    if git clone "$plugin_url" "$plugin_path" > /dev/null 2>&1; then
        # Remove .git directory to save space
        rm -rf "$plugin_path/.git"
        print_success "Plugin $plugin_name installed"
    else
        print_error "Failed to clone plugin from $plugin_url"
    fi
}

if [ -n "$PLUGINS_FILE" ] || [ ${#PLUGIN_URLS[@]} -gt 0 ]; then
    print_header "INSTALLING PLUGINS VIA GIT"

    for plugin_url in "${PLUGIN_URLS[@]}"; do
        install_plugin_from_url "$plugin_url"
    done

    if [ -n "$PLUGINS_FILE" ]; then
        while IFS= read -r plugin_url || [ -n "$plugin_url" ]; do
            install_plugin_from_url "$plugin_url"
        done < "$PLUGINS_FILE"
    fi
fi

# ============================================================================
# Final Message
# ============================================================================

print_header "SETUP COMPLETE!"

echo -e "${GREEN}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}│${NC}  ${CYAN}Your WordPress environment is ready!${NC}"
echo -e "${GREEN}├─────────────────────────────────────────────────────────────┤${NC}"
echo -e "${GREEN}│${NC}  ${YELLOW}URL:${NC}          https://$SITE_DOMAIN"
echo -e "${GREEN}│${NC}  ${YELLOW}Username:${NC}     admin"
echo -e "${GREEN}│${NC}  ${YELLOW}Password:${NC}     admin"
echo -e "${GREEN}│${NC}  ${YELLOW}PHP:${NC}          $PHP_VERSION"
echo -e "${GREEN}│${NC}  ${YELLOW}MySQL:${NC}        $MYSQL_VERSION"
echo -e "${GREEN}│${NC}  ${YELLOW}Directory:${NC}    $SITE_PATH"
echo -e "${GREEN}└─────────────────────────────────────────────────────────────┘${NC}"

echo -e "\n${CYAN}Useful commands:${NC}"
echo -e "  ${YELLOW}cd $SITE_PATH${NC}           - Navigate to site directory"
echo -e "  ${YELLOW}lando stop${NC}              - Stop the environment"
echo -e "  ${YELLOW}lando start${NC}             - Start the environment"
echo -e "  ${YELLOW}lando wp${NC}                - Run WP-CLI commands"
echo -e "  ${YELLOW}lando info${NC}              - View environment information"
echo -e "  ${YELLOW}lando logs${NC}              - View environment logs"
printf "  %slando rebuild%s           - Rebuild the environment (if issues occur)\n" "${YELLOW}" "${NC}"

echo -e "\n${CYAN}Additional services:${NC}"
echo -e "  ${YELLOW}lando info${NC}              - View all service URLs and ports"
echo -e "  phpMyAdmin and Mailhog URLs will be shown in the output above"

echo -e "\n${YELLOW}⚠ Troubleshooting:${NC}"
echo -e "  If you encounter permission or file access issues:"
echo -e "  ${YELLOW}cd $SITE_PATH && lando rebuild -y${NC}"
echo -e "  "
echo -e "  If WordPress is not installed:"
echo -e "  ${YELLOW}cd $SITE_PATH && lando wp core install --url=https://$SITE_DOMAIN --title=\"My Site\" --admin_user=admin --admin_email=admin@lndo.site --admin_password=password --allow-root --path=/app/wordpress${NC}"

echo -e "\n${GREEN}Happy coding! 🚀${NC}\n"