#!/bin/bash

sudo touch /etc/default/locale

sudo sh -c 'echo "LC_ALL=en_US.UTF-8" > /etc/default/locale'
sudo sh -c 'echo "LANG=en_US.UTF-8" > /etc/default/locale'
sudo sh -c 'echo "LANGUAGE=en_US" >> /etc/default/locale'

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US

sudo apt-get install -y ruby1.9.1-full ruby1.9.1-dev
sudo /usr/bin/gem1.9.1 install nokogiri
