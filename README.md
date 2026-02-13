# Lando WordPress Development Environment Setup

A powerful bash script to automate the creation of local WordPress development environments using Lando.

## Overview

`lando-ns.sh` is an automated setup script that:

- Creates isolated WordPress development environments using Lando
- Configures customizable PHP and MySQL versions
- Automatically installs WordPress with default credentials
- Supports bulk plugin installation from Git repositories
- Includes Redis, PHPMyAdmin services out of the box
- Provides both interactive and non-interactive (CLI argument) configuration modes

## System Requirements

### Operating Systems

- Linux (Ubuntu 18.04+, Debian, etc.)
- macOS (Intel and Apple Silicon)
- Windows (via WSL 2)

### Hardware

- Docker support (Docker Desktop, OrbStack, Colima, etc.)
- At least 4GB RAM available for containers

## Prerequisites & Dependencies

The script requires the following tools to be installed and available in your system PATH:

| Dependency | Purpose                               | Installation                                              |
| ---------- | ------------------------------------- | --------------------------------------------------------- |
| **Lando**  | Container orchestration for WordPress | https://docs.lando.dev/getting-started/installation.html  |
| **Docker** | Container runtime                     | https://docs.docker.com/get-docker/                       |
| **Git**    | Plugin cloning from repositories      | `brew install git` (macOS) or `apt install git` (Linux)   |
| **wget**   | Downloading configuration files       | `brew install wget` (macOS) or `apt install wget` (Linux) |
| **tar**    | Archive extraction                    | Pre-installed on most systems                             |
| **sed**    | Text stream processing                | Pre-installed on most systems                             |
| **ruby**   | Configuration file patching           | `brew install ruby` (macOS) or `apt install ruby` (Linux) |
| **php**    | PHP verification                      | `brew install php` (macOS) or `apt install php` (Linux)   |

### Quick Installation (macOS with Homebrew)

```bash
brew install lando docker git wget ruby php
```

### Quick Installation (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install git wget ruby php-cli docker.io
# Install Lando from: https://docs.lando.dev/getting-started/installation.html
```

## Installation

1. **Clone or download the script:**

   ```bash
   git clone <repository-url>
   cd lando-sh
   ```

2. **Make the script executable:**

   ```bash
   chmod +x lando-ns.sh
   ```

3. **Verify Docker is running:**
   ```bash
   docker info
   ```

## Usage

### Basic Usage (Interactive Mode)

Run the script with a site name to start interactive configuration:

```bash
./lando-ns.sh my-site
```

The script will then prompt you to:

1. Select PHP version (default: 8.2)
2. Select MySQL version (default: 8.0)
3. Configure post revisions limit (optional)

### Non-Interactive Mode (CLI Arguments)

Specify all configuration via command-line arguments:

```bash
./lando-ns.sh my-site --php 8.3 --mysql 8.0 --revisions 5
```

### Command Syntax

```bash
./lando-ns.sh <site-name> [OPTIONS]
```

### Available Options

| Option                | Default | Description                                     |
| --------------------- | ------- | ----------------------------------------------- |
| `-h, --help`          | —       | Display help message and exit                   |
| `--php VERSION`       | 8.2     | Set PHP version (e.g., 7.4, 8.0, 8.1, 8.2, 8.3) |
| `--mysql VERSION`     | 8.0     | Set MySQL version (e.g., 5.7, 8.0)              |
| `--plugins FILE`      | —       | File with Git plugin URLs (one per line)        |
| `--plugin URL`        | —       | Add a Git plugin URL (repeatable)               |
| `--skip-docker-check` | false   | Skip Docker verification                        |
| `--revisions N`       | 10      | Set post revisions limit (0 = unlimited)        |

## Usage Examples

### Example 1: Basic Interactive Setup

```bash
./lando-ns.sh my-wordpress-site
```

### Example 2: Non-Interactive Setup

```bash
./lando-ns.sh my-site --php 8.3 --mysql 8.0 --revisions 5
```

### Example 3: Install Plugins from URLs

```bash
./lando-ns.sh my-site \
  --php 8.2 \
  --mysql 8.0 \
  --plugin https://github.com/wpackagist-mirror/advanced-custom-fields.git \
  --plugin https://github.com/wpackagist-mirror/gravityforms.git
```

### Example 4: Install Plugins from File

Create a `plugins.txt` file:

```plaintext
https://github.com/wpackagist-mirror/advanced-custom-fields.git
https://github.com/wpackagist-mirror/gravityforms.git
# Comments and blank lines are ignored
https://github.com/wpackagist-mirror/elementor.git
```

Then run:

```bash
./lando-ns.sh my-site --php 8.2 --plugins plugins.txt
```

### Example 5: Skip Docker Verification

```bash
./lando-ns.sh my-site --skip-docker-check
```

## Included Services

After setup, your WordPress environment includes:

- **WordPress**: Full WordPress installation with WP-CLI
- **Nginx**: Web server
- **MySQL/MariaDB**: Database server
- **PHP**: Application runtime
- **Redis**: In-memory cache (optional usage)
- **PHPMyAdmin**: Database management UI
- **Mailhog**: Email testing service

## Default Credentials

Once setup is complete, you can access WordPress with:

- **URL**: `https://<site-name>.lndo.site`
- **Admin Username**: `admin`
- **Admin Password**: `admin`

## Useful Commands

Navigate to your site directory:

```bash
cd <site-name>
```

### Essential Commands

```bash
# View site information and service URLs
lando info

# Navigate to WordPress
cd <site-name>/wordpress

# Run WP-CLI commands
lando wp plugin list
lando wp user list
lando wp option get siteurl

# Stop environment (without destroying data)
lando stop

# Start environment
lando start

# View logs
lando logs

# SSH into the app container
lando ssh

# Rebuild environment (if issues occur)
lando rebuild -y
```

### Database Access

**PHPMyAdmin** URL is shown after `lando info` command.

Default credentials:

- **User**: `root`
- **Password**: `lando`

## Directory Structure

After running the script, you'll have:

```plaintext
my-site/
├── .lando/
│   └── php.wsl.ini          # PHP configuration
├── .lando.yml               # Lando configuration
├── wordpress/               # WordPress root directory
│   ├── wp-admin/
│   ├── wp-content/
│   ├── wp-includes/
│   ├── wp-config.php
│   └── index.php
└── .lando.log              # Lando logs
```

## Troubleshooting

### Docker Not Running

```bash
# Error: "Docker is not running"
# Solution: Start Docker Desktop or Docker daemon
docker run hello-world
```

### Permission Issues

```bash
# Error: "Permission denied" on files
# Solution: Rebuild the environment
cd my-site && lando rebuild -y
```

### WP-CLI Not Available

```bash
# Error: "WP-CLI is not available"
# Solution: Rebuild with Lando
cd my-site && lando rebuild -y
```

### Stuck on "Starting Lando"

```bash
# Solution: Increase Docker's resource limits
# Docker Desktop: Preferences → Resources → Disk Image Size (50GB minimum recommended)
# Then rebuild: cd my-site && lando rebuild -y
```

### WordPress Installation Failed

```bash
# Solution: Manually install WordPress via WP-CLI
cd my-site
lando wp core install \
  --url=https://my-site.lndo.site \
  --title="My Site" \
  --admin_user=admin \
  --admin_email=admin@lndo.site \
  --admin_password=admin \
  --allow-root \
  --path=/app/wordpress
```

### Port Already in Use

```bash
# Error: "Port 3306 (or other) already in use"
# Solution: Stop other services or use different site name
lando destroy  # Destroy conflicting environment
# Or create new site with different name
```

## Environment Variables

The script automatically sets:

- `LANDO_FILE_PERMISSION_FIX`: Enhanced file permissions for host-container compatibility
- `LANDO_HOST_IP`: Docker host IP for Xdebug
- `XDEBUG_CONFIG`: Xdebug configuration for remote debugging

## Advanced Features

### Post Revisions Limiting

Control WordPress post revision storage to manage database size:

```bash
./lando-ns.sh my-site --revisions 3  # Keep only 3 revisions
./lando-ns.sh my-site --revisions 0  # Keep unlimited revisions
```

### Multiple Plugin Installation

Combine multiple plugin installation methods:

```bash
./lando-ns.sh my-site \
  --plugin https://github.com/wpackagist-mirror/acf.git \
  --plugin https://github.com/wpackagist-mirror/elementor.git \
  --plugins additional-plugins.txt
```

## Cleanup & Removal

To completely remove an environment:

```bash
cd my-site
lando destroy -y  # Removes all containers and volumes
cd ..
rm -rf my-site    # Remove the directory
```

## Performance Tips

1. **Exclude directories from Docker mounts** in Docker Desktop settings to improve performance
2. **Use volume mounts** for large directories like node_modules
3. **Keep revisions limited** to reduce database size
4. **Use Redis** for caching frequently accessed data

## License

See LICENSE file in the repository.

## Support & Issues

For issues or feature requests, please open an issue in the repository or contact the author.

---

**Author**: Victor Larodiel
**Version**: 1.0
**Last Updated**: 2026-02-13
