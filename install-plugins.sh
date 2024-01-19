#!/bin/bash
WORDPRESS_PATH="/var/www/html"
COMMAND="sudo -u www-data wp --path=${WORDPRESS_PATH}"
echo "${WORDPRESS_PATH}"
echo "Installing plugins and themes"

# Remove Hello Dolly
if ${COMMAND} plugin is-installed hello; then
  echo "Removing hello dolly"
  ${COMMAND} plugin delete hello
fi

# Remove Askimet Anti-Spam
if ${COMMAND} plugin is-installed akismet; then
  echo "Removing Askimet Anti-Spam"
  ${COMMAND} plugin delete akismet
fi

# if [ $(${COMMAND} plugin is-installed cookie-notice) ]; then
#   echo "Update cookie notice plugin in order to sho information regarding cookies"
#   ${COMMAND} plugin update cookie-notice --activate
# else
#   echo "Install cookie notice plugin in order to sho information regarding cookies"
#   ${COMMAND} plugin install cookie-notice --activate
# fi

# Install plugins in the "plugins" folder, do not activate them
PLUGINS=""
if [ -n "$(ls -A /plugins/ 2>/dev/null)" ]
then
  for f in /plugins/*.zip; do
    echo "Marked $f for install"
    PLUGINS="$PLUGINS $f"
  done
  echo "Installing plugins..."
  ${COMMAND} plugin install --force ${PLUGINS}
fi