#!/bin/bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install python3-pip git stress -y

#Ops Agent Installation
# curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
# sudo bash add-google-cloud-ops-agent-repo.sh --also-install

git clone https://github.com/coding-katas/gcp-compute-ex.git
cd gcp-compute-ex
pip install -r requirements.txt
chmod +x app.py
nohup python3 app.py &

