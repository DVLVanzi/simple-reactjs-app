#!/bin/bash
cd /home/centos/simplereact
sudo pkill node
nohup sudo npm start </dev/null &>/dev/null & disown
