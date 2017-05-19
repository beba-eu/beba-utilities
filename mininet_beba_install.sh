#!/usr/bin/env bash

# Beba install script for Mininet 2.2.1 on Ubuntu 14.04 (64 bit)
# (https://github.com/mininet/mininet/wiki/Mininet-VM-Images)
# This script is based on "Mininet install script" by Brandon Heller
# (brandonh@stanford.edu)
#
# Authors: Davide Sanvito, Luca Pollini, Carmelo Cascone

SWITCHURL="https://github.com/beba-eu/beba-switch.git"
CTRLURL="https://github.com/beba-eu/beba-ctrl.git"

# Exit immediately if a command exits with a non-zero status.
set -e

# Exit immediately if a command tries to use an unset variable
set -o nounset

function beba-switch {
    echo "Installing Beba switch based on ofsoftswitch13..."
    
    cd ~/

    if [ -d "beba-switch" ]; then
        read -p "A directory named beba-switch already exists, by proceeding \
it will be deleted. Are you sure? (y/n) " -n 1 -r
        echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf ~/beba-switch
        else
            echo "User abort!"
            return -1
        fi
    fi
    git clone ${SWITCHURL} beba-switch

    # Resume the install:
    cd ~/beba-switch
    mkdir build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make
    sudo make install
    cd ~/
    
    sudo chown -R mininet:mininet ~/beba-switch
}

# Install beba-ctrl
function beba-ctrl {
    echo "Installing Beba controller based on RYU..."

    # install beba-ctrl dependencies"
    sudo apt-get -y install autoconf automake g++ libtool python make libxml2 \
        libxslt-dev python-pip python-dev python-matplotlib

    sudo pip install gevent pbr pulp networkx fnss numpy
    sudo pip install -I six==1.9.0

    # fetch beba-ctrl
    cd ~/
    if [ -d "beba-ctrl" ]; then
        read -p "A directory named beba-ctrl already exists, by proceeding it will be \
deleted. Are you sure? (y/n) " -n 1 -r
        echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf ~/beba-ctrl
        else
            echo "User abort!"
            return -1
        fi
    fi
    git clone ${CTRLURL} beba-ctrl
    cd beba-ctrl
    
    # install beba-ctrl
    sudo pip install -r tools/pip-requires
    sudo pip install -I eventlet==0.17.4
    sudo python ./setup.py install

    sudo chown -R mininet:mininet ~/beba-ctrl
}

# Download BEBA node for Mininet
function download-mininet-node {
    echo "Downloading BEBA node for Mininet..."
    sudo apt-get -y install valgrind
    cd ~/
    wget https://raw.githubusercontent.com/beba-eu/beba-utilities/master/beba.py
}

sudo apt-get update
~/mininet/util/install.sh -nt
download-mininet-node
beba-ctrl
beba-switch

echo "All set!"
