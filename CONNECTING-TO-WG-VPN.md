# Common Wireguard VPN Client Configuration Steps

Running the `wireguard` command on your adblocker virtual machine will run the Wireguard configuration command line utility. A configuration file is generated, and a QR Code which can be consumed by the Wireguard mobile apps is also printed in the terminal. The VPN configuration can be scanned using the Android or iOS Wireguard apps, or copy and pasted from the generated .conf file, to your device.

If you are setting up a Wireguard Client on a computer or server, obtain the contents of the **wg0-client-username.conf** file and copy it to the device you want to connect from.

You can print the contents of the **wg0-client-username.conf** file in the command line interface of the Wireguard Server, by running this command:

```bash
sudo cat /root/wg0-client-username.conf
```

The output can be copy and pasted into a blank text file on your client device, and this configuration file should be saved on your client device as **wg0-client-username.conf**

---

## Android & Chrome OS

Install the [official Wireguard Android App](https://play.google.com/store/apps/details?id=com.wireguard.android) and use a QR Code to import your VPN profile.

<a href="https://f-droid.org/en/packages/com.wireguard.android/" target="_blank">
<img src="./images/logos/f-droid.svg" alt="Get it on F-Droid" height="80"></a>
<a href="https://play.google.com/store/apps/details?id=com.wireguard.android" target="_blank">
<img src="./images/logos/google-play.svg" alt="Get it on Google Play" height="60"></a>

To configure a persistent tunnel on Android, that reconnects after the device restarts, you have to edit the system-wide VPN settings:

| Device | Steps to enable Always-on VPN Tunnel |
| :------| :------------------------------------|
| Pixel Phones | **Settings** > **Network & Internet** > **Advanced** > **VPN** > **⚙** (for Wireguard) <br>enable **Always-on VPN** |
| Samsung Phones | **Settings** > **Connections** > **More Connection Settings** > **VPN** > **⚙** (for Wireguard) <br>enable **Always-on VPN** |
| Huawei Phones | **Settings** > **More connections** > **VPN** > press and hold (on Wireguard) > **Edit** <br>enable **Always-on VPN** |

## Arch Linux

Install an open source [Wireguard plugin for Network Manager](https://github.com/max-moser/network-manager-wireguard/).

### 1. Install Wireguard plugin

From the Arch User Repository, you can install **networkmanager-wireguard-git**.

### 2. Import the configuration

  1. Right click on Network Manager applet
  2. Select **Modify connections**
  3. At the bottom left, click on the `+` symbol
  4. From the dropdown menu, select **Import saved VPN configuration** and confirm
  5. Select the **wg0-client-1.conf** file and confirm.
  6. You are free to change the name of the VPN configuration if you want. Once done, click **Save** and you should see the VPN connection appear in the list.

## iOS

Install the [official Wireguard iOS App](https://itunes.apple.com/us/app/wireguard/id1441195209?ls=1&mt=8) and use a QR Code to import your VPN profile.

<a href="https://itunes.apple.com/us/app/wireguard/id1441195209?ls=1&mt=8" target="_blank">
<img src="./images/logos/app-store.svg" alt="Get it on the App Store" height="60"></a>

Steps to enable Always-on VPN Tunnel:

  - Edit the Tunnel in the Wireguard App
  - Click **Edit** on the top right
  - Scroll down to **On-Demand Activation** and Enable **Cellular** and **Wi-Fi** toggles

## macOS

Install the [official Wireguard macOS Client](https://itunes.apple.com/us/app/wireguard/id1451685025?ls=1&mt=12) and use the **wg0-client-1.conf** file to import your VPN profile.

<a href="https://itunes.apple.com/us/app/wireguard/id1451685025?ls=1&mt=12" target="_blank">
<img src="./images/logos/app-store-macOS.svg" alt="Get it on the Mac App Store" height="60"></a>

## Windows

Install the [official Wireguard Windows Client](https://www.wireguard.com/install/) and use the **wg0-client-1.conf** file to import your VPN profile.

Get the latest Windows Client from [wireguard.com/install](https://www.wireguard.com/install/)
