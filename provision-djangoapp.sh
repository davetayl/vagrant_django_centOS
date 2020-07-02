# provision-djangoapp.sh
set -e # Stop script execution on any error
echo ""; echo "---- Provisioning Environment ----"

# Install tools
echo "- Installing Tools -"
dnf -yqe 3 install net-tools bind-utils python3 httpd

# Configure firewall
echo "- Update Firewall -"
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# Set up Django
echo "---- Setting up Django ----"

# Create django folders
mkdir /opt/django
mkdir /opt/django/media
mkdir /opt/django/static

# setup project
cd /opt/django
pip install virtualenv django
chown -R /opt/django apache:apache

# Setup apache server
echo "---- Setting up Apache Server ----"
cat > /etc/httpd/conf.d/django.cont << EOF
<VirtualHost *:80>
	WSGIScriptAlias / /opt/django/django/wsgi.py
	WSGIPythonPath /opt/django/
	Alias /robots.txt /opt/django/static/robots.txt
	Alias /favicon.ico /opt/django/static/favicon.ico

	Alias /media/ /opt/django/media/
	Alias /static/ /opt/django/static/

	<Directory /opt/django/>
	<Files wsgi.py>
		Order deny,allow
		Allow from all
	</Files>
	</Directory>
    ErrorLog /var/log/httpd/django-error.log
    CustomLog /var/log/httpd/django-access.log combined
</VirtualHost>

EOF

systemctl enable --now httpd.service
systemctl status httpd.service
