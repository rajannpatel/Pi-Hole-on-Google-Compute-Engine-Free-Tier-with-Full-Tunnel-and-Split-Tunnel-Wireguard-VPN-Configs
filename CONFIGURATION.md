# Software Installation & Configuration

This guide assumes you have completed a fresh installation of a Pi-Hole compatible Linux Operating System, such as Ubuntu 20.04.

1. Connect via SSH to your Server, and become the root user (in the root home directory at **/root**) by executing this command:

```bash
sudo su -
```

2. Download and execute the setup script. (This **setup.sh** script must always be run as the root user.)

```bash
curl -O https://raw.githubusercontent.com/rajannpatel/Pi-Hole-on-Google-Compute-Engine-Free-Tier-with-Full-Tunnel-and-Split-Tunnel-Wireguard-VPN-Configs/master/setup.sh
chmod +x setup.sh
./setup.sh 
```

3. Accept the default values provided throughout the entire installation process, once it is running, the only key you need to press is `ENTER`.

    - The Pi-Hole installation will begin after the Wireguard network interface is configured. You should accept all the default options throughout the Pi-Hole installation, by pressing `ENTER`.

4. At the end, you will get a QR code you can scan to connect your mobile devices. You could optionally use the provided **.conf** files to import your Wireguard Client Profiles into your devices.

5. To add additional Wireguard VPN Clients, run **setup.sh** again. You must run this script as the root user, from within the **/root** home directory. This can be accomplished by making sure you have performed *Step 1* before performing this step.

```bash
./setup.sh
```

It will automatically increment the IP Addresses for each new client profile, continue accepting all the default values the script provides. The option to edit values is provided for advanced users with edge case requirements.

6. Once your device is connected to Wireguard, all your DNS requests will flow through Pi-Hole. Your device will be identified by its IPv6 address in Pi-Hole's admin interface, which will be accessible at `http://10.66.66.1/admin`. The default configuration (which is the recommended configuration) for all VPN profiles is Split Tunnel. If you wish to have a Full Tunnel, edit the **Allowed IPs** on your Client Profile to read `0.0.0.0/0, ::/0`.
