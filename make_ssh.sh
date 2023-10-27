#!/bin/sh
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
cd ~\.ssh
ssh-keygen -t ed25519 -C "vicrwyatt@gmail.com"
