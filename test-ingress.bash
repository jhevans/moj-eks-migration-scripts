#!/usr/bin/env bash

source ./get-vars.bash <<< $@

while sleep 5; do curl -I https://$host; done
