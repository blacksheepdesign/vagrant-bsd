#!/usr/bin/env bash

## CONFIGURATION
LOCAL_DOMAIN="{{ domain }}-local.bsd.nz"

## STOP EDITING
if [ "$EUID" -ne 0 ]
  then echo "Please run me as root"
  exit
fi

if grep -q $LOCAL_DOMAIN /etc/hosts; then
  echo "Visit $LOCAL_DOMAIN in your browser"
else
  echo "192.168.68.8  $LOCAL_DOMAIN" >> /etc/hosts
  echo "Added hosts entry"
  echo "Visit $LOCAL_DOMAIN in your browser"
fi
