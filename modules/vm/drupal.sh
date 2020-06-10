sudo apt update
sudo apt-get install php php-curl php-gd php-sqlite3
mkdir /tmp/drupal/ && cd /tmp/drupal/

echo "Downloading Drupal"
wget https://www.drupal.org/download-latest/tar.gz
tar -zxvf *.gz
sudo chown -R www-data:www-data /tmp/drupal/
sudo chmod -R 755 /tmp/drupal/

echo "Installing Apache"
yes | sudo apt install apache2 libapache2-mod-php
sudo systemctl start apache2.service
sudo systemctl enable apache2.service

echo "Install PHP 7.2 and Related Modules"
yes | sudo apt-get install software-properties-common
yes | sudo add-apt-repository ppa:ondrej/php
yes | sudo add-apt-repository ppa:ondrej/apache2
sudo apt update
yes | sudo apt install php7.2 libapache2-mod-php7.2 php7.2-common php7.2-mbstring php7.2-xmlrpc php7.2-soap php7.2-gd php7.2-xml php7.2-intl php7.2-mysql php7.2-cli php7.2-zip php7.2-curl

echo "Installing MySQL"
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server mysql-client
sudo systemctl start mysql.service
sudo systemctl enable mysql.service

echo "MySQL Secure Installation"
sudo mysql -u root -proot <<-EOF
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;
EOF
sudo systemctl restart mysql

echo "Create Drupal Database"
sudo mysql -u root -proot
CREATE DATABASE drupaldb;
CREATE USER 'drupaluser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON drupal.* TO 'drupaluser'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;

echo "Configure Apache2 Drupal Site"
echo '<VirtualHost *:80>
      DocumentRoot /tmp/drupal/
      ServerAdmin admin@mydrupal.com
      ServerName mydrupal.com
      ServerAlias www.mydrupal.com
      <Directory /tmp/drupal/>
            Options Indexes FollowSymLinks MultiViews
            AllowOverride ALL
            Order allow,deny
            Allow from all
            Require all granted
      </Directory>
      ErrorLog /var/log/apache2/error.log
      ServerSignature Off
      CustomLog /var/log/apache2/access.log combined
      <Directory /tmp/drupal/>
            RewriteEngine on
            RewriteBase /
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteRule ^(.*)$ index.php?q=$1 [L,QSA]
      </Directory>
</VirtualHost>' > /tmp/drupal.conf
sudo mv /tmp/drupal.conf /etc/apache2/sites-available/drupal.conf

echo "Enable the Drupal Site"
sudo a2ensite drupal.conf
sudo a2enmod rewrite
sudo a2enmod env
sudo a2enmod dir
sudo a2enmod mime
sudo systemctl restart apache2.service

echo "Generate self sign certificate"
yes | sudo add-apt-repository ppa:certbot/certbot
sudo add-apt-repository universe
sudo apt-get update
yes | sudo apt-get install python3-certbot-apache
sudo certbot --apache --non-interactive --agree-tos -m admin@mydrupal.com -d mydrupal.com -d www.mydrupal.com

echo '<IfModule mod_ssl.c>
<VirtualHost *:443>
      ServerAdmin admin@mydrupal.com
      DocumentRoot /tmp/drupal/
      ServerName mydrupal.com
      ServerAlias www.mydrupal.com
      <Directory /tmp/drupal/>
            Options Indexes FollowSymLinks MultiViews
            AllowOverride ALL
            Order allow,deny
            Allow from all
            Require all granted
      </Directory>
      ErrorLog /var/log/apache2/error.log
      ServerSignature Off
      CustomLog /var/log/apache2/access.log combined
      <Directory /tmp/drupal/>
            RewriteEngine on
            RewriteBase /
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteRule ^(.*)$ index.php?q=$1 [L,QSA]
      </Directory>
SSLCertificateFile /etc/letsencrypt/live/mydrupal.com/fullchain.pem
SSLCertificateKeyFile /etc/letsencrypt/live/mydrupal.com/privkey.pem
Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>
</IfModule>' > /tmp/mydrupal.com-le-ssl.conf
sudo mv /tmp/mydrupal.com-le-ssl.conf /etc/apache2/sites-available/mydrupal.com-le-ssl.conf

echo "Setting autorenewal for certificates"
sudo certbot renew --dry-run
sudo crontab -e
0 1 * * * /usr/bin/certbot renew & > /dev/null
