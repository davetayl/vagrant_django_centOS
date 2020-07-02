# provision-djangoapp.sh
#!/usr/bin/env bash

# Configure script
set -e # Stop script execution on any error
echo ""; echo "-----------------------------------------"

# Configure variables
MYHOST=djangoapp
TESTPOINT=google.com
echo "- Variables set -"

# Test internet connectivity
ping -q -c5 $TESTPOINT > /dev/null 2>&1
 
if [ $? -eq 0 ]
then
	echo "- Internet Ok -"	
else
	echo "- Internet failed -"
fi

# Set system name
echo "- Set name to $MYHOST -"
hostnamectl set-hostname $MYHOST
cat >> /etc/hosts <<EOF
10.0.2.15	$MYHOST $MYHOST.localdomain
EOF

# Sync clock
echo "- Sync Clock -"
ntpdate 0.au.pool.ntp.org

# Base OS update
echo "- Update OS -"
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
dnf -yqe 3 update > /dev/null

# Install tools
echo "- Installing Tools -"
dnf -yqe 3 install net-tools bind-utils python3 httpd

# Configure firewall
echo "- Update Firewall -"
firewall-cmd --permanent --add-service=httpd
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# Create django folder
mkdir /opt/django

# setup project
cd /opt/django
pip install virtualenv

