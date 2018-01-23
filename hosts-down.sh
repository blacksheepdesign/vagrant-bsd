#!/usr/bin/env bash

## CONFIGURATION
LOCAL_DOMAIN="{{ domain }}-local.bsd.nz"

## STOP EDITING
if [ "$EUID" -ne 0 ]
  then echo "Please run me as root"
  exit
fi

sed -i.bak "/192.168.68.8  $LOCAL_DOMAIN/d" /etc/hosts
