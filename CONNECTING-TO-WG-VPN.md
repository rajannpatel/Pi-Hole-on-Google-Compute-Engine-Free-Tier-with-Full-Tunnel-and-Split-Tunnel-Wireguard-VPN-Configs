# [Linux] Connecting to Wireguard VPN using Network Manager

## 1. Install Wireguard plugin
As a prerequisite, you should have Wireguard plugin for Network Manager installed. See [here](https://github.com/max-moser/network-manager-wireguard/). Some linux distributions provide pre-built packages:

###  Arch

From the Arch User Repository, you can install `networkmanager-wireguard-git`.

## 2. Retrieve your Wireguard configuration

At the end of wireguard configuration, a `conf` file should have been created to allow a client to connect to the VPN. Retrieve your file and copy it to the device you want to connect from.

## 3. Tweaking the config file

The generated file is formatted in a way that is unreadable by Network Manager.

You should open the config file and make sure that fields holding 2 IP address (IPv4 and IPv6), that are separated by a comma, should have a space after the comma. For example `Address = 10.66.66.3/24,fd42:42:42::3/64` should be changed to `Address = 10.66.66.3/24, fd42:42:42::3/64` (note the space after the comma).

Fields that might be affected by this issue are **(non-exhaustive list)**:

  - Address
  - DNS
  - AllowedIPs

Make sure to add an extra space after the comma, if needed.

## 4. Importing the configuration

  1. Right click on Network Manager applet
  2. Select `Modify connections`
  3. At the bottom left, click on the `+` symbol
  4. From the dropdown menu, select `Import saved VPN configuration` and confirm
  5. Select the configuration and confirm.
  6. You are free to change the name of the VPN configuration if you want. Once done, click `Save` and you should see the VPN connection pop up in the list.