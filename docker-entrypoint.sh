#!/bin/bash
# https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

WORDPRESS_PATH="/var/www/html"
COMMAND="sudo -u www-data wp --path=${WORDPRESS_PATH}"

if [[ "$1" == apache2* ]] || [ "$1" == php-fpm ]; then
	if ! [ -e index.php -a -e wp-includes/version.php ]; then
		echo >&2 "WordPress not found in $PWD - copying now..."
		if [ "$(ls -A)" ]; then
			echo >&2 "WARNING: $PWD is not empty - press Ctrl+C now if this is an error!"
			( set -x; ls -A; sleep 10 )
		fi
		tar cf - --one-file-system -C /usr/src/wordpress . | tar xf -
		echo >&2 "Complete! WordPress has been successfully copied to $PWD"

		if [ ! -e .htaccess ]; then
			# NOTE: The "Indexes" option is disabled in the php:apache base image
			cat > .htaccess <<-'EOF'
				# BEGIN WordPress
				<IfModule mod_rewrite.c>
				RewriteEngine On
				RewriteBase /
				RewriteRule ^index\.php$ - [L]
				RewriteCond %{REQUEST_FILENAME} !-f
				RewriteCond %{REQUEST_FILENAME} !-d
				RewriteRule . /index.php [L]
				</IfModule>
				# END WordPress
			EOF
			chown www-data:www-data .htaccess
		fi
	fi

	rm -rf ${WORDPRESS_PATH}/wp-config-docker.php

	# Remove wp-config.php if flag RESET_WPCONFIG is set to 1
	if [[ "${RESET_DB}" == 1 ]]; then
		echo "Removing wp-config because RESET_WPCONFIG is set"
		if [[ -f "${WORDPRESS_PATH}/wp-config.php" ]]; then
			rm -rf ${WORDPRESS_PATH}/wp-config.php
		else
			echo "No wp-config.php found, skipping"
		fi
	fi

	# Create default wp-config.php using passed flags
	echo "Creating default wp-config.php"
	if [[ -f "${WORDPRESS_PATH}/wp-config.php" ]]; then
		echo "wp-config.php exist, skipping. Set RESET_WPCONFIG to 1 if you want to automatically recreate it!"
	else
		${COMMAND} core config --dbhost=${WORDPRESS_DB_HOST} --dbuser=${WORDPRESS_DB_USER} --dbpass=${WORDPRESS_DB_PASSWORD} --dbname=${WORDPRESS_DB_NAME}  --dbprefix=${WORDPRESS_PREFIX} 
	fi

	# Reset database if flag RESET_DB is set to 1
	if [[ "${RESET_DB}" == 1 ]]; then
		echo "Dropping DB because RESET_DB is set"
		if [[ -f "${WORDPRESS_PATH}/wp-config.php" ]]; then
			${COMMAND} db drop --yes
		else
			echo "No wp-config.php found, skipping"
		fi
	fi

	echo "Creating db"
	if ${COMMAND} db check; then
		echo "Database exist, skipping. Set RESET_DB to 1 if you want to automatically recreate it!"
	else
	echo "${WORDPRESS_DB_HOST}"
		${COMMAND} db create
	fi

	# now that we're definitely done writing configuration, let's clear out the relevant envrionment variables (so that stray "phpinfo()" calls don't leak secrets from our code)
	for e in "${envs[@]}"; do
		unset "$e"
	done
fi

/usr/local/bin/wp_post_entrypoint

exec "$@"
