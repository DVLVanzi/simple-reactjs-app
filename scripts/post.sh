#!/bin/bash
cd /home/centos/simplereact
sudo pkill node
sudo npm start > /dev/null &
