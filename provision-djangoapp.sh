# provision-djangoapp.sh

set -e # Stop script execution on any error
echo ""; echo "---- Provisioning Environment ----"

# Install tools
echo "- Installing Tools -"
dnf -yqe 3 install net-tools bind-utils tree python3 python3-mod_wsgi httpd

# Configure firewall
echo "- Update Firewall -"
systemctl enable --now firewalld.service
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# Set up Django
echo "---- Setting up Django ----"
useradd django
# Create django folders
mkdir /opt/django_site

# setup project
cd /opt/django_site
pip3 -q install virtualenv
python3 -m virtualenv venv
source ./venv/bin/activate
pip3 -q install django
django-admin startproject django_site
sed -i 's/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \[\"127.0.0.1\"\]/g' /opt/django_site/django_site/django_site/settings.py

cat >> /opt/django_site/django_site/django_site/settings.py <<EOF
STATIC_ROOT = "/opt/django_site/django_site/static/"
EOF

mkdir /opt/django_site/django_site/media
mkdir /opt/django_site/django_site/static
chown -R apache:apache /opt/django_site

python /opt/django_site/django_site/manage.py makemigrations
python /opt/django_site/django_site/manage.py migrate
python /opt/django_site/django_site/manage.py collectstatic --noinput

# Insert admin user
echo "from django.contrib.auth.models import User; User.objects.filter(username='admin').delete(); User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python /opt/django_site/django_site/manage.py shell

# Setup apache server
echo "---- Setting up Apache Server ----"
cat > /etc/httpd/conf.d/django_site.conf <<EOF
WSGIScriptAlias / /path/to/mysite.com/mysite/wsgi.py
WSGIPythonHome /opt/django_site/venv
WSGIPythonPath /opt/django_site/django_site

<VirtualHost *:80>
        DocumentRoot /opt/django_site

        Alias /static /opt/django_site/django_site/static/
        <Directory "/opt/django_site/django_site/static/">
                Options FollowSymLinks
                Order allow,deny
                Allow from all
                Require all granted
        </Directory>

        Alias /media /opt/django_site/django_site/media/
        <Directory "/opt/django_site/django_site/media/">
                Options FollowSymLinks
                Order allow,deny
                Allow from all
                Require all granted
        </Directory>

                WSGIScriptAlias / /opt/django_site/django_site/django_site/wsgi.py
                ErrorLog /var/log/httpd/django_site-error.log
                CustomLog /var/log/httpd/django_site-access.log combined

        <Directory /opt/django_site/django_site>
                <Files wsgi.py>
                        Require all granted
                </Files>
        </Directory>
</VirtualHost>
EOF

systemctl enable --now httpd.service


echo "---- Environment setup complete ----"; echo ""
echo "------------------------------------------"
echo " With great power, comes great opportunity"
echo "------------------------------------------"
