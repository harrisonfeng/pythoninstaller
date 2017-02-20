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

PYTHON_INSTALLER_VERSION=0.1.4

# Color Definition
TXTRESET='\e[0m'
TXTRED='\e[0;31m'
TXTGREEN='\e[0;32m'
TXTBLUE='\e[0;34m'
TXTPURPLE='\e[0;35m'

BTXTRED='\e[1;31m'
BTXTGREEN='\e[1;32m'
BTXTBLUE='\e[1;34m'

# Args
PYTHON_VERSION=$1
INSTALL_DIR_PREFIX=$2

# Error code
NO_ARGS=5
ERRORS=444
FILE_NOT_EXISTS=505
ERROR_DOWNLOAD=404

LATEST_PYTHON_VERSIONS_STABLE='2.7.13 3.6.0'
PYTHON_SRC_URL_PREFIX='http://www.python.org/ftp/python'
# If the user doesn't give it, we will use it.
DEFAULT_INSTALL_DIR_PREFIX=/opt/python
PYTHON_VERSION_MAJOR=`echo ${PYTHON_VERSION} | cut -d. -f1`


function usage() {
   echo -e "${BTXTRED}
**********************************************************************

Usage:
./`basename $0` <PYTHON_VERSION> [INSTALL_DIR_PREFIX]
For example:
./`basename $0` 3.6.0 /opt/python

**********************************************************************
${TXTRESET}\n"
}


function check_parameters() {
    if [ -z ${PYTHON_VERSION} ]; then
        usage
        exit ${NO_ARGS}
    fi
    if [ -z ${INSTALL_DIR_PREFIX} ]; then
        INSTALL_DIR_PREFIX=${DEFAULT_INSTALL_DIR_PREFIX}
    fi
}


function prepare_environment() {
    WORKSPACE=${PWD}
    PYTHON_VERSION_SHORT=`echo ${PYTHON_VERSION} | cut -d "." -f -2`
    PYTHON_SRC_DIR=Python-${PYTHON_VERSION}
    PYTHON_SRC_PKG_NAME=Python-${PYTHON_VERSION}.tgz
    TARGET_INSTALL_DIR=${INSTALL_DIR_PREFIX}/python${PYTHON_VERSION}
    PYTHON_BIN_NAME=`echo "python${PYTHON_VERSION}" | cut -d\. -f1-2`
    PYTHON_BIN_PATH=${TARGET_INSTALL_DIR}/bin/${PYTHON_BIN_NAME}
    PYTHON_SRC_PKG_URL=${PYTHON_SRC_URL_PREFIX}/${PYTHON_VERSION}/${PYTHON_SRC_PKG_NAME}
    echo -e "${BTXTGREEN}
******************* Python Install Environment ***********************
Python Source Package:     ${PYTHON_SRC_PKG_URL}
Python Install Directory:  ${TARGET_INSTALL_DIR}
Python Bin Directory:      ${TARGET_INSTALL_DIR}/bin
Python Bin Path:           ${PYTHON_BIN_PATH}
Python Startup Path:       /usr/local/bin/python${PYTHON_VERSION}
******************* Python Install Environment ***********************
${TXTRESET}\n"
}


function install_build_deps() {
    echo -e "${BTXTGREEN}
**********************************************************************
Start to install dependencies, make sure you have root permission.
**********************************************************************
${TXTRESET}\n"
   if [ -f /usr/bin/yum ]; then
       yum -y groupinstall "Development tools"
       INSTALL_CMDLINE="yum -y install \
           openssl*-devel bzip2-devel \
           expat-devel gdbm-devel \
           readline-devel sqlite-devel wget"
   elif [ -f /usr/bin/apt-get ]; then
       INSTALL_CMDLINE="apt-get -y install \
           build-essential libncursesw5-dev \
           libreadline6-dev libssl-dev \
           libgdbm-dev libc6-dev \
           libsqlite3-dev tk-dev bzip2 libbz2-dev wget"
   fi
   sudo ${INSTALL_CMDLINE}
   if [ "$?" -ne "0" ]; then
       echo -e "${BTXTRED}
       Errors happened or failed install dependencies,
       please re-run to install it again.
       ${TXTRESET}\n"
       exit ${ERRORS}
   fi
}


function get_python_source_pkg() {
   echo -e "${BTXTGREEN}Start to download python source code now...${TXTRES}\n"
   wget ${PYTHON_SRC_PKG_URL}
   if [ "$?" -ne "0" ]; then
      exit ${ERROR_DOWNLOAD}
   fi
}


function build_install_python() {
    cd ${WORKSPACE}
    if [ -f ${PYTHON_SRC_PKG_NAME} ]; then
        tar xvf ${PYTHON_SRC_PKG_NAME}
    else
        echo -e "${PYTHON_SRC_PKG_NAME} is not found!"
        exit ${FILE_NOT_EXISTS}
    fi
    if [ "$?" -ne "0" ]; then
        echo -e "${BTXTRED}Errors on extracting source package ${PYTHON_SRC_PKG_NAME}${TXTRESET}\n"
        exit 5
    else
        cd ${PYTHON_SRC_DIR}
        echo -e "${BTXTGREEN}
**********************************************************************
Start to build and install Python ${PYTHON_VERSION} now...
**********************************************************************
${TXTRESET}\n"
        ./configure --prefix=${TARGET_INSTALL_DIR}
        make
        sudo make install
    fi
}


function post_install() {
    if [ -f ${PYTHON_BIN_PATH} ]; then
        echo -e "${BTXTGREEN}
**********************************************************************
Creating symblinks below

/usr/local/bin/python${PYTHON_VERSION}
/usr/local/bin/python${PYTHON_VERSION_SHORT}
**********************************************************************
${TXTRESET}\n"
        sudo ln -s -f ${PYTHON_BIN_PATH} /usr/local/bin/python${PYTHON_VERSION}
        sudo ln -s -f ${PYTHON_BIN_PATH} /usr/local/bin/python${PYTHON_VERSION_SHORT}
    else
        echo -e "${BTXTRED}${PYTHON_BIN_PATH} doesn't exist.${TXTRESET}\n"
    fi

}


function clean_build_artifacts() {
   cd ${WORKSPACE}
   sudo rm -rf ${PYTHON_SRC_DIR}
   sudo rm -rf ${PYTHON_SRC_PKG_NAME} 
}


function install_pip() {
    if [ "${PYTHON_VERSION_MAJOR}" -ne "3" ]; then
        ./pip_installer.sh ${PYTHON_VERSION} ${INSTALL_DIR_PREFIX}
    fi
}


function main() {
    check_parameters
    install_build_deps
    prepare_environment
    get_python_source_pkg
    build_install_python
    post_install
    clean_build_artifacts
}


main
