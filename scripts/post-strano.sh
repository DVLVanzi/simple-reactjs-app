#!/bin/bash
cd /home/centos/simplereact/scripts
sudo cp x22.service /etc/systemd/system/x22.service
sudo systemctl daemon-reload
sudo systemctl restart x22
sudo systemctl enable x22
