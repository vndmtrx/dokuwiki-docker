# 📚 DokuWiki Docker Image

A secure, rootless Docker image for DokuWiki with persistent storage support.

## ✨ Features

- 🐳 Based on official PHP 8.3 Apache image
- 🔒 Runs as non-root user (www-data)
- 📁 Persistent storage for:
  - Configuration files
  - Wiki data and pages
  - Plugins
  - Templates
  - Cache

## 🚀 Quick Start

### Using Docker Run
```bash
# Create persistent volume
docker volume create dokuwiki_data

# Run container
docker run -d \
  --name dokuwiki \
  -p 8080:80 \
  -v dokuwiki_data:/dokuwiki \
  --user www-data \
  vndmtrx/dokuwiki:latest
```

### Using Docker Compose
```bash
# Create persistent volume
docker volume create dokuwiki_data

# Start services
docker compose up -d
```

## 📁 Volume Structure

The `/dokuwiki` volume contains:
- `conf/`: Configuration files
- `data/`: Wiki data and pages
- `plugins/`: DokuWiki plugins
- `tpl/`: Templates

## 🛠️ Configuration

After starting the container, access:
```
http://localhost:8080/install.php
```

## 🔒 Security

- Runs as non-root user (www-data)
- No new privileges allowed
- Minimal base image and dependencies

## 📜 License

[GNU Affero General Public License v3.0](https://www.gnu.org/licenses/agpl-3.0.en.html)

## 🔗 Links

- [Docker Hub](https://hub.docker.com/r/vndmtrx/dokuwiki)
- [GitHub Repository](https://github.com/vndmtrx/dokuwiki-docker)