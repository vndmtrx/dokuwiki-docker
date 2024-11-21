#!/usr/bin/env bash

set -uo pipefail

CONF_DIR="/dokuwiki/conf"
LOCAL_FILE="$CONF_DIR/local.php"
ACL_FILE="$CONF_DIR/acl.auth.php"
USERS_FILE="$CONF_DIR/users.auth.php"
INSTALL_FILE="/var/www/html/install.php"
FORCE_CONF="${DOKUWIKI_FORCE_CONF:-0}"

# Check if any DOKUWIKI_ variable exists
has_dokuwiki_vars() {
    printenv | grep -q "^DOKUWIKI_" && return 0
    return 1
}

create_local_file() {
    local file="$1"
    {
        echo "<?php"
        echo "// DokuWiki configuration file"
        echo "// Generated automatically"
        echo
    } > "$file"
}

update_config() {
    local key="$1"
    local value="$2"
    
    [ ! -f "$LOCAL_FILE" ] && create_local_file "$LOCAL_FILE"
    
    if grep -q "^\$conf\['${key}'\]" "$LOCAL_FILE"; then
        sed -i "s|\$conf\['${key}'\] *= *.*|\$conf['${key}'] = ${value};|" "$LOCAL_FILE"
    else
        echo "\$conf['${key}'] = ${value};" >> "$LOCAL_FILE"
    fi
}

setup_acl_policy() {
    local policy="${DOKUWIKI_ACL_POLICY:-open}"
    case "$policy" in
        open)    echo "*               @ALL          16" > "$ACL_FILE" ;;
        public)  { 
            echo "*               @ALL          1"
            echo "*               @user         8"
        } > "$ACL_FILE" ;;
        closed)  echo "*               @user         15" > "$ACL_FILE" ;;
        *)       echo "*               @ALL          16" > "$ACL_FILE" ;;
    esac
}

process_basic_configs() {
    local configs=(
        "DOKUWIKI_TITLE|title"
        "DOKUWIKI_LANG|lang"
        "DOKUWIKI_LICENSE|license"
        "DOKUWIKI_TAGLINE|tagline"
        "DOKUWIKI_BASEURL|baseurl"
        "DOKUWIKI_USEACL|useacl"
        "DOKUWIKI_DISABLEACTIONS|disableactions"
        "DOKUWIKI_AUTHTYPE|authtype"
        "DOKUWIKI_DEFAULTGROUP|defaultgroup"
        "DOKUWIKI_DATEFORMAT|dformat"
        "DOKUWIKI_USEREWRITE|userewrite"
    )

    for config in "${configs[@]}"; do
        local env_var=${config%|*}
        local key=${config#*|}
        [ -n "${!env_var:-}" ] && {
            update_config "$key" "'${!env_var}'"
        }
    done
}

setup_superadmin() {
    [ -n "${DOKUWIKI_SUPERUSER:-}" ] || return 1
    [ -n "${DOKUWIKI_SUPERPASS:-}" ] || return 1
    [ -n "${DOKUWIKI_FULLNAME:-}" ] || return 1
    [ -n "${DOKUWIKI_EMAIL:-}" ] || return 1

    grep -q "^\$conf\['superuser'\]" "$LOCAL_FILE" || update_config "superuser" "'@admin'"

    local hashed_password=$(php -r "echo password_hash('${DOKUWIKI_SUPERPASS}', PASSWORD_BCRYPT);")
    local user_line="${DOKUWIKI_SUPERUSER}:${hashed_password}:${DOKUWIKI_FULLNAME}:${DOKUWIKI_EMAIL}:admin,user"

    echo "$user_line" > "$USERS_FILE"
    return 0
}

initialize_dokuwiki() {
    if [ -z "$(ls -A /dokuwiki)" ]; then
        if [ ! -L "/var/www/html/conf" ]; then
            mv /var/www/html/conf /dokuwiki/
            ln -sf /dokuwiki/conf /var/www/html/conf
        fi
        if [ ! -L "/var/www/html/data" ]; then
            mv /var/www/html/data /dokuwiki/
            ln -sf /dokuwiki/data /var/www/html/data
        fi
        if [ ! -L "/var/www/html/lib/plugins" ]; then
            mv /var/www/html/lib/plugins /dokuwiki/plugins
            ln -sf /dokuwiki/plugins /var/www/html/lib/plugins
        fi
        if [ ! -L "/var/www/html/lib/tpl" ]; then
            mv /var/www/html/lib/tpl /dokuwiki/tpl
            ln -sf /dokuwiki/tpl /var/www/html/lib/tpl
        fi
        chown -R www-data:www-data /dokuwiki
    fi
}

# Main configuration process
if has_dokuwiki_vars; then
    process_basic_configs
    setup_acl_policy
    setup_superadmin
    [ -f "$INSTALL_FILE" ] && rm "$INSTALL_FILE"
fi

initialize_dokuwiki

exec apache2-foreground