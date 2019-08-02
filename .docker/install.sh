# Install apache, wget and other OS support for images.
apt-get update;
apt-get install -y --no-install-recommends apache2 wget libjpeg62-turbo-dev libpng-dev libfreetype6-dev libzip-dev;

# Integrate mailhog for self-SMTP email testing
wget -O /usr/bin/mhsendmail 'https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64';
chmod 0755 /usr/bin/mhsendmail;
echo 'sendmail_path = "/usr/bin/mhsendmail --smtp-addr=mailhog:1025"' > /usr/local/etc/php/php.ini;

# Clean the system
apt-get purge -y wget;
apt-get autoremove -y;
apt-get clean;
rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/*;

# Enable Apache2 Modules
a2enmod actions proxy_fcgi rewrite ssl;
chmod 6444 /var/log/apache2;
chown -R www-data:www-data /var/www/html;

# Configure PHP extensions
docker-php-ext-configure gd --with-gd --with-jpeg-dir=/usr/include --with-png-dir=/usr/include  --with-freetype-dir=/usr/include;
docker-php-ext-configure zip --with-libzip;
docker-php-ext-install pdo_mysql mysqli gd zip;

# Copy Apache2 config and restart apache
cp -r .docker/apache2/ /etc/;
service apache2 restart;
rm -rf /var/www/html/.docker/;