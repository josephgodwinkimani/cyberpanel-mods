#!/bin/bash
source /usr/local/CyberCP/bin/activate
pip install --ignore-installed -r /usr/local/CyberCP/requirments.txt
# deactivate the virtual environment 
deactivate
# create virtual environment
virtualenv --system-site-packages /usr/local/CyberCP
# restart gunicorn http server
systemctl restart gunicorn.socket
