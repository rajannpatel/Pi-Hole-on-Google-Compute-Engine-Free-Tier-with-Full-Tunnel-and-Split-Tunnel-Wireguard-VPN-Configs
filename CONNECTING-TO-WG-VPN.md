# Common Wireguard VPN Client Configuration Steps

## Arch Linux

### 1. Install Wireguard plugin

As a prerequisite, you should have the [Wireguard plugin for Network Manager](https://github.com/max-moser/network-manager-wireguard/) installed.

From the Arch User Repository, you can install **networkmanager-wireguard-git**.

### 2. Retrieve your Wireguard configuration

At the end of the Quickstart or Detailed Server Setup Guide, a Wireguard configuration file named **wg0-client-1.conf** should have been created. This allows a client to connect to the VPN. Retrieve your file and copy it to the device you want to connect from.

You can print the contents of the file on the server, with this command:

```bash
sudo cat /root/wg0-client-1.conf
```

### 3. Import the configuration

  1. Right click on Network Manager applet
  2. Select **Modify connections**
  3. At the bottom left, click on the `+` symbol
  4. From the dropdown menu, select **Import saved VPN configuration** and confirm
  5. Select the configuration and confirm.
  6. You are free to change the name of the VPN configuration if you want. Once done, click **Save** and you should see the VPN connection appear in the list.