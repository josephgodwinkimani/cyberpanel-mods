#!/bin/bash

# use cscli that manages crowdsec to update

sudo cscli hub update --trace
sudo cscli hub upgrade --force --trace
sudo cscli scenarios upgrade --all --force --trace
sudo cscli parsers upgrade --all --force --trace
sudo cscli collections upgrade --all --force --trace
sudo cscli postoverflows upgrade --all --force --trace
sudo cscli metrics
