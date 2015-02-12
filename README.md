================
Python Installer
================

Python Installer is a **BASH** script used to install **Python** from source 
in **Ubuntu** or **CentOS**. Since this script will go to download official
**Python** source package, please make sure your network is alive. It requires 
wget utility is installed in your **Ubuntu** box. Actually, wget should be default 
installed in **Ubuntu** or **CentOS**.

Additionally, there is PIP installer script to bootstrap pip installation in Python2
as pip doesn't exist in Python2 default installation.


Installation
============

You actually don't make any installation. Just put this script somewhere and 
run it.


Dependencies
============

BASH, wget utility. Of course, you must have root permission.


Usage
=====
```
./python_installer.sh PYTHON_VERSION PREFIX

./pip_installer.sh [PYTHON_VERSION] PREFIX
```
E.g.

```
./python_installer.sh 2.7.8 /opt/python

./pip_installer.sh 2.7.8 /opt/python
```


