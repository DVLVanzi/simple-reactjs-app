#!/bin/bash
cd /home/centos/simplereact
sudo pkill node
sudo npm run build
sudo npm run deploy
