# 📚 DokuWiki Docker Image

A secure, rootless Docker image for DokuWiki with persistent storage support.

## ✨ Features

- 🐳 Based on official PHP 8.3 Apache image
- 🔒 Runs as non-root user (www-data)
- ⚙️ Full environment variable configuration
- 📁 Persistent storage for configuration, data, plugins and templates

## 🚀 Quick Start

### Using Docker Run
```bash
# Create persistent volume
docker volume create dokuwiki_data

# Run container with basic configuration
docker run -d \
  --name dokuwiki \
  -p 8080:80 \
  -v dokuwiki_data:/dokuwiki \
  -e DOKUWIKI_TITLE="My Wiki" \
  -e DOKUWIKI_SUPERUSER=admin \
  -e DOKUWIKI_SUPERPASS=mysecurepass \
  -e DOKUWIKI_FULLNAME="Wiki Admin" \
  -e DOKUWIKI_EMAIL=admin@example.com \
  --user www-data \
  vndmtrx/dokuwiki:latest
```

### Using Docker Compose
Check the docker-compose.yml file in the repository for a complete example with all available options.

## 🔧 Environment Variables

### Basic Configuration
| Variable | Install.php Equivalent | Description |
|----------|----------------------|-------------|
| TZ | - | Container timezone |
| DOKUWIKI_FORCE_CONF | - | Force configuration override |
| DOKUWIKI_TITLE | Wiki Name | Site title |
| DOKUWIKI_TAGLINE | Tag Line | Site description |
| DOKUWIKI_LANG | Language | Interface language |
| DOKUWIKI_LICENSE | License | Content license |
| DOKUWIKI_BASEURL | Base URL | Wiki URL |
| DOKUWIKI_DATEFORMAT | - | Date format |
| DOKUWIKI_USEREWRITE | - | Enable URL rewriting |

### User Management
| Variable | Install.php Equivalent | Description |
|----------|----------------------|-------------|
| DOKUWIKI_SUPERUSER | Superuser | Admin username |
| DOKUWIKI_SUPERPASS | Password | Admin password |
| DOKUWIKI_FULLNAME | Real Name | Admin full name |
| DOKUWIKI_EMAIL | E-Mail | Admin email |

### Access Control
| Variable | Install.php Equivalent | Description | Default |
|----------|----------------------|-------------|---------|
| DOKUWIKI_USEACL | Use ACL | Enable access control | - |
| DOKUWIKI_AUTHTYPE | Authentication Backend | Auth mechanism | - |
| DOKUWIKI_DEFAULTGROUP | Initial Group | Default group for new users | - |
| DOKUWIKI_DISABLEACTIONS | Disabled Actions | Disabled features | - |
| DOKUWIKI_ACL_POLICY | Initial ACL policy | Access policy (open/public/closed) | open |

### Important Notes About Installation

If environment variables are provided:
- The wiki will be pre-configured with these settings
- The install.php file will be automatically removed for security
- No manual configuration will be needed

If no environment variables are set:
- The install.php wizard will be available at first access
- Manual configuration will be required through the web interface
- The install.php will remain until manual configuration is completed

## 📁 Volume Structure

The `/dokuwiki` volume contains:
- `conf/`: Configuration files
- `data/`: Wiki data and pages
- `plugins/`: DokuWiki plugins
- `tpl/`: Templates

## 🔒 Security

- Runs as non-root user (www-data)
- No new privileges allowed
- Minimal base image and dependencies
- Automatic removal of install.php after configuration when using environment variables

## 📜 Licenses

[GNU Affero General Public License v3.0](https://www.gnu.org/licenses/agpl-3.0.en.html)

This project builds upon other open source software:

- **DokuWiki**: [GNU General Public License v2.0](https://github.com/dokuwiki/dokuwiki/blob/master/LICENSE)
- **PHP**: [PHP License v3.01](https://www.php.net/license/3_01.txt)

## 🔗 Links

- [Docker Hub](https://hub.docker.com/r/vndmtrx/dokuwiki)
- [GitHub Repository](https://github.com/vndmtrx/dokuwiki-docker)