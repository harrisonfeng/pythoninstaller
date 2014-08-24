#!/bin/bash
#
# Python Installer
#
# Copyright (C) 2013 Harrison Feng <feng.harrison@gmail.com>
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
#
# Python Installer is a BASH script used to install Python from source in Ubuntu
# box. Since this script will go to download official Python source package, 
# please make sure your network is alive. It requires wget utility is installed
# in your Ubuntu box. Actually, wget should be default installed in Ubuntu box.
#
#
# @author Harrison Feng <feng.harrison@gmail.com>
# @file python_installer.sh

PYTHON_INSTALLER_VERSION=0.1.1

NO_ARGS=5
FILE_NOT_EXISTS=505
ERROR_DOWNLOAD=404


LATEST_PYTHON_VERSIONS_STABLE='2.7.5 3.2.5 3.3.2 3.3.3 3.3.4'
URL_PREFIX='http://www.python.org/ftp/python'

PYTHON_VERSION=$1
WORKSPACE=${PWD}
PYTHON_SRC_DIR=Python-${PYTHON_VERSION}
PYTHON_SRC_PKG_NAME=Python-${PYTHON_VERSION}.tgz
TARGET_INSTALL_DIR=/opt/python${PYTHON_VERSION}
PYTHON_BIN_NAME=`echo "python${PYTHON_VERSION}" | cut -d\. -f1-2`
PYTHON_BIN_PATH=${TARGET_INSTALL_DIR}/bin/${PYTHON_BIN_NAME}
PYTHON_SRC_PKG_URL=${URL_PREFIX}/${PYTHON_VERSION}/${PYTHON_SRC_PKG_NAME}

usage() {
   echo
   echo "Usage:                          " 
   echo "./`basename $0` <python-version>"
   echo "For example:                    " 
   echo "./`basename $0` 3.3.2           "
   echo 
}

if [ -z $1 ]; then
   usage
   exit ${NO_ARGS}
fi

echo
echo "************************ Python Installer *******************************"
echo "Python Source Package:    ${PYTHON_SRC_PKG_URL}"
echo "Python Install Directory: ${TARGET_INSTALL_DIR}"
echo "Python Bin Directory:     ${TARGET_INSTALL_DIR}/bin"
echo "Python Bin Path:          ${PYTHON_BIN_PATH}"
echo "Python Startup Path:      /usr/local/bin/python${PYTHON_VERSION}"
echo "*************************************************************************"

installDeps() {
   echo
   echo "=================================================================="
   echo "Start to install dependencies, make sure you have root permission."
   echo "=================================================================="
   echo
   apt-get --version
   if [ "$?" -ne "0" ]; then
      INST_CMD="yum install -y openssl-devel bzip2-devel expat-devel gdbm-devel readline-devel sqlite-devel"
   else
      INST_CMD="apt-get install -y build-essential libncursesw5-dev libreadline6-dev libssl-dev libgdbm-dev libc6-dev libsqlite3-dev tk-dev bzip2 libbz2-dev"
   fi
   sudo ${INST_CMD}
}
                       
getPySrc() {
   echo "Start to download python source now..."
   echo
   wget ${PYTHON_SRC_PKG_URL}
   if [ "$?" -ne "0" ]; then
      exit ${ERROR_DOWNLOAD}
   fi
}

buildPy() {
   if [ -f ${PYTHON_SRC_PKG_NAME} ]; then
      tar xvf ${PYTHON_SRC_PKG_NAME}
   else
      exit ${FILE_NOT_EXISTS}
   fi
   cd ${PYTHON_SRC_DIR}
   ./configure --prefix=${TARGET_INSTALL_DIR}
   echo
   echo "=============================================="
   echo "Start to build Python ${PYTHON_VERSION} now..."
   echo "=============================================="
   echo
   make
   sudo make install
   echo
}

cleanBuildStuff() {
   cd ${WORKSPACE}
   sudo rm -rf ${PYTHON_SRC_DIR}
   sudo rm -rf ${PYTHON_SRC_PKG_NAME} 
}

# Start installation process
installDeps
if [ $? -eq "0" ]; then
   getPySrc
   buildPy
   if [ -f ${PYTHON_BIN_PATH} ]; then
      sudo ln -s ${PYTHON_BIN_PATH} /usr/local/bin/python${PYTHON_VERSION}
      echo "==========================================================="
      echo "Create symblink /usr/local/bin/python${PYTHON_VERSION}"
      echo "==========================================================="
      echo "*********************** Congrats! *********************************"
      echo "Your python interpreter ${PYTHON_VERSION} is installed successfully"
      echo "*******************************************************************"
   else
      echo "${PYTHON_BIN_PATH} doesn't exist."
   fi
   cleanBuildStuff
   echo 
   echo
else
   echo "Failed to install dependencies, please re-run script to install."
   exit 1
fi
