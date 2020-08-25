# Software Installation & Configuration

These instructions assume

- *Do not skip steps:*

- you have completed a fresh installation of a Pi-Hole compatible Linux Operating System such as [Ubuntu 20.04 in the cloud](./GOOGLE-CLOUD.md), or locally in your home/office.

- port 51515 is forwarded to your server in your router. If you are using the Google Cloud Firewall:

  - Log into https://cloud.google.com/console

  - Click the Hamburger Menu at the top left, click **VPC Network** and click **Firewall Rules**. <br><img src="./images/screenshots/firewall.png" width="222"> <br>Click **Create Firewall Rule** at the top center of the page. The name of your rule should be `allow-wireguard`, change the **Targets** dropdown to **All instances in the network**. The **Source IP Ranges** should be `0.0.0.0/0`. The **udp** checkbox should be selected, and the port number next to it should be changed from `all` to `51515`. Then click the **Create** button.

1. Connect via SSH to your Server, and become the root user (in the root home directory at **/root**) by executing this command:

```bash
sudo su -
```

2. Download and apply execution privileges to the setup script, before running it. (This **setup.sh** script must always be run as the root user, from the root user's home directory.)

```bash
curl -O https://raw.githubusercontent.com/rajannpatel/Pi-Hole-on-Google-Compute-Engine-Free-Tier-with-Full-Tunnel-and-Split-Tunnel-Wireguard-VPN-Configs/master/setup.sh
chmod +x setup.sh
bash ./setup.sh 
```

3. Accept the default values provided throughout the entire installation process, once it is running, the only key you need to press is `ENTER`.

    - The Pi-Hole installation will begin after the Wireguard network interface is configured. You should accept all the default options throughout the Pi-Hole installation, by pressing `ENTER`.

4. At the end, you will get a QR code you can scan to connect your mobile devices. You could optionally use the provided **.conf** files to import your Wireguard Client Profiles into your devices.

5. To add additional Wireguard VPN Clients, run **setup.sh** again. You must run this script as the root user, from within the **/root** home directory. This can be accomplished by making sure you have performed *Step 1* before performing this step.

```bash
bash ./setup.sh
```

It will automatically increment the IP Addresses for each new client profile, continue accepting all the default values the script provides. The option to edit values is provided for advanced users with edge case requirements.

6. [Configure the Wireguard VPN Client on your device](./CONNECTING-TO-WG-VPN.md). Once your device is connected via Wireguard, all your DNS requests will flow through Pi-Hole. Your device will be identified by its IPv6 address in Pi-Hole's admin interface, which will be accessible at both `http://[fd42:42:42::1]/admin` and `http://10.66.66.1/admin`. The default configuration (which is the recommended configuration) for all VPN profiles is Split Tunnel. If you wish to route all your traffic through the VPN (Full Tunnel), edit the **Allowed IPs** on your Client Profile on your device to read `0.0.0.0/0, ::/0`.

### NOTE: Google Cloud Free Tier limits for Google Compute Engine

- You get 1 GB network egress from North America to all region destinations (excluding China and Australia) per month.

---

## Edge Case Requirements

### Configure automated Pi-Hole updates and scheduled reboots

Pause and consider if you need this for mission critical Pi-hole Servers. If you are running multiple Pi-Holes for redundancy, and you choose to implement this, stagger the upgrade and reboot schedules. Be prepared to perform health-checks to ensure all services are operational. Blind upgrades are not gauranteed to be smooth.

**Note:** The following steps assume you have **nano** installed. You can use any other editor (e.g **vim**) to do this.

Create the script to check if a reboot is required or not, by checking for the presence of the **/var/run/reboot-required** file, by running:

```bash
sudo nano /etc/cron.daily/zz-restart-if-required
```

Paste the following into **/etc/cron.daily/zz-restart-if-required**:

> ```bash
> #!/bin/sh
> if [ -f /var/run/reboot-required ]; then
>   /sbin/shutdown -r now
> fi
> ```

Set the correct permissions:

```bash
sudo chmod 755 /etc/cron.daily/zz-restart-if-required
```

Check for Pi-Hole updates and perform an update if one is available:

Create the script to update PiHole:

```bash
sudo nano /etc/cron.daily/update-pi-hole
```

Paste the following into **/etc/cron.daily/update-pi-hole**:

> ```bash
> #!/bin/sh
> /usr/local/bin/pihole -up
> ```

Set the correct permissions:

```bash
sudo chmod 755 /etc/cron.daily/update-pi-hole
```

### Enabling or Blocking communication between Wireguard Clients

If you wish to enable communication between select Wireguard clients, using the same CIDR notation under **Allowed IPs** in each Client Configuration file is necessary. This table could help you plan which devices get what IPs.

**TODO:** provide a subnet cheatsheet for IPv6 addresses

#### Subnet Cheatsheet

| CIDR Notation | Address Range |
| -- | -- |
| 10.66.66.0/30 | 10.66.66.1 - 10.66.66.2 |
| 10.66.66.0/29 | 10.66.66.1 - 10.66.66.6 |
| 10.66.66.0/28 | 10.66.66.1 - 10.66.66.14 |
| 10.66.66.0/27 | 10.66.66.1 - 10.66.66.30 |
| 10.66.66.0/26 | 10.66.66.1 - 10.66.66.62 |
| 10.66.66.0/25 | 10.66.66.1 - 10.66.66.126 |
| 10.66.66.0/24 | 10.66.66.1 - 10.66.66.254 |
