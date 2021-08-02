#!/usr/bin/env bash
set -e

git clone https://github.com/thduerr/nd081-c4-azure-performance-project-starter.git
cd nd081-c4-azure-performance-project-starter/
git checkout Deploy_to_VMSS

sudo apt update
sudo apt install redis-server
#redis-server
sudo apt install python3.7 -y
python3 -m pip install -r requirements.txt
(cd azure-vote; python3 main.py)
