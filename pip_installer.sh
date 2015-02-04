#!/bin/bash
#
# Pip Installer
#
# Copyright (C) 2014 Harrison Feng <feng.harrison@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see [http://www.gnu.org/licenses/].
#
# Generally, py26 and py27 don't ship with pip, setuptools and 
# virtualenv default. This script is used to install pip in 
# py26/py27, then upgrade setuptools. Of course, virtualenv will 
# be in place.
#
# Usage:
#
#    # make sure you have root permission
#    git clone https://github.com/harrisonfeng/pythoninstaller.git
#    cd pythoninstaller
#    ./pip_installer.sh
# 

VERSION=0.1.2

PYTHON_VERSION=$1
INSTALL_DIR_PREFIX=$2
# dirs for use-installed python
PYTHON_BIN_DIR=${INSTALL_DIR_PREFIX}/python${PYTHON_VERSION}/bin
# paths for binaries
PYTHON_BIN=${PYTHON_BIN_DIR}/python
PIP_BIN=${PYTHON_BIN_DIR}/pip
VIRTUALENV_BIN=${PYTHON_BIN_DIR}/virtualenv

function usage {
    echo 
    echo  "./pip_installer [python_version]"
    echo 
    echo  "If python_version is missing, install pip \ 
    for default python installation"
    echo
    }

if [ -z ${PYTHON_VERSION} ]; then
    echo 
    echo "python_version is missing,\ 
    install pip for default python installation"
    echo
    PYTHON_BIN=`which python`
fi 
#
# Dist identification functions
#

function is_fedora {
    [ -f /usr/bin/yum ] && cat /etc/*release | grep -q -e "Fedora"
}

function is_rhel6 {

    [ -f /usr/bin/yum ] && \
        cat /etc/*release | grep -q -e "Red Hat" -e "CentOS" && \
        cat /etc/*release | grep -q 'release 6'
}

function is_rhel7 {
    [ -f /usr/bin/yum ] && \
        cat /etc/*release | grep -q -e "Red Hat" -e "CentOS" && \
        cat /etc/*release | grep -q 'release 7'
}

function is_ubuntu {
    [ -f /usr/bin/apt-get ]
}

function setup_pip {
    # Install pip using get-pip
    local GET_PIP_URL=https://bootstrap.pypa.io/get-pip.py
    local ret=1

    if [ -f ./get-pip.py ]; then
        ret=0
    elif type curl >/dev/null 2>&1; then
        curl -O ${GET_PIP_URL}
        ret=$?
    elif type wget >/dev/null 2>&1; then
        wget ${GET_PIP_URL}
        ret=$?
    fi

    if [ $ret -ne 0 ]; then
        echo "Failed to get get-pip.py"
        exit 1
    fi

    if is_rhel6; then
        echo
        echo "Your system is `cat /etc/centos-release`"
        echo "Clean up your old setuptools..."
        yum erase -y python-setuptools
        rm -rf /usr/lib/python2.6/site-packages/setuptools*
        echo "================ cleanup ends ================"
        echo
    fi

    # install pip
    sudo ${PYTHON_BIN} get-pip.py
}


if [ -z ${PYTHON_VERSION} ]; then
    echo
    echo "python_version is missing,\
    install pip for default python installation"
    echo
    PYTHON_BIN=`which python`
fi

setup_pip

if [ -z ${PYTHON_VERSION} ]; then
    PIP_BIN=`which pip`
fi

echo "Upgrading setuptools..."
sudo ${PIP_BIN} install --upgrade setuptools

echo "Installing virtualenv ..."
sudo ${PIP_BIN} install --upgrade virtualenv

rm -rf get-pip.py
