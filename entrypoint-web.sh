#!/bin/bash

echo "Now in entrypoint.sh (web) for Firefly III Data Importer"
echo "Script:            3.0 (2025-01-11)"
echo "User:              '$(whoami)'"
echo "Group:             $(id -g -n)"
echo "Working dir:       $(pwd)"
echo "Base build number: $BASE_IMAGE_BUILD"
echo "Base build date:   $BASE_IMAGE_DATE"
echo "Build number:      $(cat /var/www/counter-main.txt)"
echo "Build date:        $(cat /var/www/build-date-main.txt)"

# https://github.com/docker-library/wordpress/blob/master/docker-entrypoint.sh
# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		echo "set $var from $fileVar"
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

# envs that can be appended with _FILE
envs=(
	FIREFLY_III_URL
	VANITY_URL
	FIREFLY_III_ACCESS_TOKEN
	FIREFLY_III_CLIENT_ID
	NORDIGEN_ID
	NORDIGEN_KEY
	SPECTRE_APP_ID
	SPECTRE_SECRET
	AUTO_IMPORT_SECRET
	IMPORT_DIR_WHITELIST
	JSON_CONFIGURATION_DIR
	MAIL_DESTINATION
	MAIL_FROM_ADDRESS
	MAIL_HOST
	MAIL_PORT
	MAIL_USERNAME
	MAIL_PASSWORD
	MAIL_ENCRYPTION
	MAILGUN_DOMAIN
	MAILGUN_SECRET
	MAILGUN_ENDPOINT
	POSTMARK_TOKEN
)

echo "Now parsing _FILE variables."
for e in "${envs[@]}"; do
  file_env "$e"
done
echo "done!"

# set docker var.
export IS_DOCKER=true


# remove any lingering files that may break upgrades:
rm -f $FIREFLY_III_PATH/storage/framework/cache/data/*
rm -f $FIREFLY_III_PATH/storage/logs/*.log
rm -f $FIREFLY_III_PATH/storage/logs/laravel.log

composer dump-autoload > /dev/null 2>&1
php artisan package:discover > /dev/null 2>&1
php artisan cache:clear > /dev/null 2>&1
php artisan config:cache > /dev/null 2>&1
php artisan importer:version

if [ "$WEB_SERVER" == "false" ]; then
	echo "--------------------------------------------------------"
	echo "WEB_SERVER=false no longer works on this image."
	echo "Please use fireflyiii/data-importer:latest-cli instead"
	echo "--------------------------------------------------------"
	exit 1
fi
