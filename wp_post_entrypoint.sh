#!/bin/bash

WORDPRESS_PATH="/var/www/html"
COMMAND="sudo -u www-data wp --path=${WORDPRESS_PATH}"

WORDPRESS_URL=$(php -r "echo preg_replace('#^http?://|\"|\'#', '', rtrim('${WORDPRESS_URL}','/'));")
#Generate default user
if [ ! $(${COMMAND} core is-installed) ]; then
 echo "Generating a default user."
 ${COMMAND} --admin_user="${WORDPRESS_ADMIN_USERNAME}" --admin_password="${WORDPRESS_ADMIN_PASSWORD}" --admin_email="${WORDPRESS_ADMIN_EMAIL}" --title="${WORDPRESS_TITLE}" --url="${WORDPRESS_URL}" core install
fi

echo "Adding ${WORDPRESS_LANG} and enabling it"
${COMMAND} language core install ${WORDPRESS_LANG}
${COMMAND} site switch-language ${WORDPRESS_LANG}

# echo "Updating existing plugins and themes"   # Do not update plugins and themes, as it could break things
# ${COMMAND} plugin update-all                  # Do it manually in WordPress
# ${COMMAND} theme update-all

echo "Fixing Permissions"
chown www-data:www-data -R .
find ${WORDPRESS_PATH} -iname "*.php" | xargs chmod +x

site_url=$(${COMMAND} option get siteurl)
echo "Your site will be served via: "${site_url}

#Installing 3rd party plugins
/usr/local/bin/install-plugins.sh
