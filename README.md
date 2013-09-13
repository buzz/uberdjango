# Description

Creates an empty Django project in an [uberspace](http://uberspace.de/).

## Features

* virtualenv
* Django Admin enabled
* nice URLs (rewrite)
* ipython

# Usage

* Create an account at uberspace and login:

```
$ ssh USERNAME@HOST.uberspace.de
```

* Clone the uberdjango repository into your uberspace:

```
$ git clone https://github.com/buzz/uberdjango.git
$ cd uberdjango
```

* Run the setup script:

```
./setup.sh DJANGOPROJECT
```

`DJANGOPROJECT` will be your Django project name (only numbers, letters and underscores). Surf to `http://USERNAME.HOST.uberspace.de/admin`, login and change your admin password.

Happy coding :)
