#!/usr/bin/env bash
set -e

sudo apt-get update
sudo apt-get -y install stress
sudo stress --cpu 10 --timeout 600 -q >/dev/null 2>&1 &
exit
