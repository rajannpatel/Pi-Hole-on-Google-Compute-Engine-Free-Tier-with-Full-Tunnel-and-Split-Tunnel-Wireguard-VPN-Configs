# Configure Full Tunnel or Split Tunnel IPv6 Wireguard connections from your Android, iOS, Linux, macOS, & Windows devices

<img src="./images/data-privacy-risk.svg" width="125" align="right">

The goal of this guide is to enable you to safely and privately use the Internet on your phones, tablets, and computers with a self-run VPN Server in the cloud, or on your own hardware in your home. This software shields you from intrusive advertisements. It blocks your ISP, cell phone company, public WiFi hotspot provider, and apps/websites from gaining insight into your usage activity.

Both Full Tunnel (all traffic) and Split Tunnel (DNS traffic only) VPN connections provide DNS based ad-blocking over an encrypted connection to the cloud. The differences are:

- A Split Tunnel VPN allows you to interact with devices on your Local Network (such as a Chromecast or Roku).
- A Full Tunnel VPN can help bypass misconfigured proxies on corporate WiFi networks, and protects you from Man-In-The-Middle SSL proxies.

| Tunnel Type | Data Usage | Server CPU Load | Security | Ad Blocking |
| -- | -- | -- | -- | -- |
| full | +10% overhead for vpn | low | 100% encryption | yes
| split | just kilobytes per day | very low | dns encryption only | yes

---

# Quickstart

1. Install [Ubuntu 20.04](https://ubuntu.com/download/server) if you want to benefit from the Wireguard Module natively shipped in the Linux Kernel. Or install any other OS flavor compatible with Pi-Hole.
2. Download and execute **setup.sh** from this repository.

```bash
sudo su -
curl -O https://raw.githubusercontent.com/rajannpatel/Pi-Hole-on-Google-Compute-Engine-Free-Tier-with-Full-Tunnel-and-Split-Tunnel-Wireguard-VPN-Configs/master/setup.sh
chmod +x setup.sh
./setup.sh 
```

This will:

  - install the latest Wireguard packages
  - install the latest Pi-Hole, and configure it to accept DNS requests from the Wireguard interface
  - Display a QR Code for 1 Split Tunnel VPN Profile, so you can import the VPN Profile to your device without having to type anything

3. Make sure your router or firewall is forwarding incoming UDP packets on Port 51515 to the Ubuntu 20.04 Minimal LTS Server, that you ran the **setup.sh** script on.
4. Create another VPN Client Profile by running `./setup.sh` again, you can create 253 profiles without modifying the script.

---

# Detailed Guides

<table>
    <tbody>
        <tr>
            <td><b><a href="#option-a--set-up-a-pi-hole-ad-blocking-vpn-server-with-a-static-anycast-ip-on-google-clouds-always-free-usage-tier">Option A</a></b></td>
            <td>Set up a Pi-Hole Ad Blocking VPN Server with a static Anycast IP on Google Cloud's Always Free Usage Tier</td>
        </tr>
        <tr>
            <td><b><a href="#option-b--set-up-a-pi-hole-ad-blocking-vpn-server-behind-your-router-at-home">Option B</a></b></td>
            <td>Set up a Pi-Hole Ad Blocking VPN Server behind your router at home.</td>
        </tr>
    </tbody>
</table>

---

## Option A <br> Set up a Pi-Hole Ad Blocking VPN Server with a static Anycast IP on Google Cloud's Always Free Usage Tier

<img src="./images/upfront-cost.svg" width="90" align="right">

You can run your own privacy-first ad blocking service within the **[Free Usage Tier](https://cloud.google.com/free/)** on Google Cloud. **Step 1 of this guide gets you set up with a Google Cloud account, and Step 2 walks you through setting up a full tunnel or split tunnel VPN connection on your Android & iOS devices, and computers.**

This simple 2 step process will get you up and running:

- **STEP 1** [Google Cloud Login, Account Creation, & Server Provisioning](./GOOGLE-CLOUD.md)
- **STEP 2** [Software Installation & Configuration](./CONFIGURATION.md)

The technical merits of major choices in this guide are outlined in [REASONS.md](./REASONS.md).

---

## Option B <br> Set up a Pi-Hole Ad Blocking VPN Server behind your router at home.

- **STEP 1** A new install of Ubuntu 20.04 (or other OS which is compatible with Pi-Hole)
- **STEP 2** [Software Installation & Configuration](./CONFIGURATION.md)
- **STEP 3** Bridge your Local LAN with your Wireguard network:
  - Open the Wireguard Application on your Client Device, and edit the VPN Profile.
  - Change the **Allowed IPs** to include your LAN subnet. For example, if your router's IP address is `192.168.86.1`, your subnet is `192.168.86.0/24`. If you add `192.168.86.0/24` to the comma separated list of **Allowed IPs**, you will be able to ping any device on your LAN over your Wireguard connection.

---

# Contributions Welcome

If there is something that can be done better, or if this documentation can be improved in any way, please submit a Pull Request with your fixes or edits.

Contributors should be aware of [REASONS.md](./REASONS.md), which explain the factors behind choices made throughout this guide.

Please review the [Issues](https://github.com/rajannpatel/Pi-Hole-on-Google-Compute-Engine-Free-Tier-with-Full-Tunnel-and-Split-Tunnel-Wireguard-VPN-Configs/issues) if you are in a position to help others, or participate in improving this project.
