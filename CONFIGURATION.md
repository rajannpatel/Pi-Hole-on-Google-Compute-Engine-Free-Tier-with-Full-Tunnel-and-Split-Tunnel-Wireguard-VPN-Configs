<img src="./images/numbers/2.svg" width="96" align="left">

# Configuration Steps

<br><br>

1. Connect via SSH to your Server, and become root.

```bash
sudo su -
```

2. Download and execute the setup script.

```bash
curl -O https://raw.githubusercontent.com/rajannpatel/Pi-Hole-on-Google-Compute-Engine-Free-Tier-with-Full-Tunnel-and-Split-Tunnel-Wireguard-VPN-Configs/master/setup.sh
chmod +x setup.sh
./setup.sh 
```

3. Accept the default values provided throughout the entire installation process, once it is running, the only key you need to press is `ENTER`.

    - The Pi-Hole installation will begin after the Wireguard network interface is configured. You should accept all the default options throughout the Pi-Hole installation, by pressing `ENTER`.

4. At the end, you will get a QR code you can scan to connect your mobile devices. You could optionally use the provided **.conf** files to import your Wireguard Client Profiles into your devices.

5. To add additional Wireguard VPN Clients, run **setup.sh** again

```bash
./setup.sh
```

It will automatically increment the IP Addresses for each new client profile, continue accepting all the default values the script provides. The option to edit values is provided for advanced users with edge case requirements.

6. Once your device is connected to Wireguard, all your DNS requests will flow through Pi-Hole. Your device will be identified by its IPv6 address in Pi-Hole's admin interface, which will be accessible at `http://10.66.66.1/admin`