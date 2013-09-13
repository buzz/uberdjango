#!/bin/bash

if [ $# -ne 1 ]
then
  echo "Usage: `basename $0` DJANGO_PROJECT_NAME"
  exit -1
fi

project=$1

# fcgi wrapper
cat <<EOF >~/fcgi-bin/${project}
#!/usr/bin/env python2.7
import sys, os

HOME = os.path.expanduser('~')
ACTIVATE_THIS = '%s/venv/bin/activate_this.py' % HOME
DJANGO_PROJECT = '%s/${project}' % HOME
logfile = open('%s/fcgi-error.log' % HOME, 'a')

try:
    # Setup env
    execfile(ACTIVATE_THIS, dict(__file__ = ACTIVATE_THIS))
    sys.path.insert(0, DJANGO_PROJECT)
    os.chdir(DJANGO_PROJECT)
    os.environ['DJANGO_SETTINGS_MODULE'] = 'core.settings'

    # Start
    from django.core.servers.fastcgi import runfastcgi
    runfastcgi(method='threaded', daemonize='false')
except:
    import traceback
    traceback.print_exc(file=logfile)
EOF
chmod 755 ~/fcgi-bin/${project}

# apache rewrite rules
cat <<EOF >~/html/.htaccess
RewriteEngine on
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*)$ /fcgi-bin/${project}/\$1 [QSA,L]
EOF

pushd ~
easy_install virtualenv
virtualenv -p `which python2.7` venv
source venv/bin/activate

echo "source venv/bin/activate" >> .bashrc
echo "alias manage='python ~/${project}/manage.py'" >> .bashrc

# install django
pip install django
pip install south
pip install flup

# install ipython for proper "$ manage shell"
pip install readline
pip install ipython

# copy static admin files
mkdir -p ~/html/static
cp -a ~/venv/lib/python2.7/site-packages/django/contrib/admin/static/admin ~/html/static/

# init django project
popd
cp -R djangoproj ~/${project}
pushd ~/${project}
python manage.py syncdb --noinput
pwd=`openssl passwd "$RANDOM" | cut -c1-8`
export DJANGO_SETTINGS_MODULE="core.settings"
echo "from django.contrib.auth import models as auth_models; auth_models.User.objects.create_superuser('admin', 'admin@example.com', '${pwd}')" | python

echo "************************************************"
echo "Django project ${project} is up 'n running..."
echo "Login as admin, password: ${pwd}"
echo "Surf to http://$(whoami).$(hostname)/admin"
echo "************************************************"
