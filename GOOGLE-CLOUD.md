# Server Provisioning with Google Cloud

<img src="./images/logos/cloud.svg" width="48" align="left">

# Google Cloud Login and Account Creation

Go to https://cloud.google.com and click **Console** at the top right if you have previously used Google's Cloud Services, or click **Try Free** if it's your first time.

### Account Creation
- **Step 1 of 2** <br> Agree to the terms and continue. <br><img src="./images/screenshots/5.png" width="265">
- **Step 2 of 2** <br> Set up a payments profile and continue <br><img src="./images/screenshots/5.png" width="223">
### Project & Compute Engine Creation
1. Click the Hamburger Menu at the top left: <br><img src="./images/screenshots/1.png" width="197">
2. Click **Compute Engine**: <br><img src="./images/screenshots/2.png" width="138">
3. Select **VM instances**: <br><img src="./images/screenshots/3.png" width="102">
4. Create a Project if you don't already have one: <br><img src="./images/screenshots/4.png" width="294">
5. Enable billing for this Project if you haven't already: <br><img src="./images/screenshots/6.png" width="288">
- Compute Engine will begin initializing: <br><img src="./images/screenshots/7.png" width="232">

<img src="./images/logos/computeengine.svg" width="48" align="left">

# Compute Engine Virtual Machine Setup

1. Create a Virtual Machine instance on Compute Engine: <br><img src="./images/screenshots/8.png" width="216">
2. Customize the instance: <br><img src="./images/screenshots/8.png" width="216">
3. Name your Virtual Machine **pi-hole**. <br>To qualify for the Free Tier, your Region selection should be any US region only (excluding Northern Virginia [us-east4]). I have used **us-east1** and the **us-east1-b** zone because it is closest to me. <br>Choose the **f1-micro** Machine Type in the dropdown. <br>You must **Change** the operating system to **Ubuntu** (Operating System dropdown menu), and choose **Ubuntu 20.04 LTS Minimal** (version dropdown menu). <br>Change the Boot Disk Size to be **30GB** if you plan on keeping your DNS lookup records for any reason, otherwise the default **10GB** disk allocation is adequate.
<br><img src="./images/screenshots/9.png" width="232">
4. Expand **Management, Security, disks, networking, sole tenancy** and click the **Networking** tab. Click the Pencil icon under **Network Interfaces**. <br><img src="./images/screenshots/10.png" width="238">
5. The External IP Address should not be Ephemeral. Choose **Create IP Address** to Reserve a New Static IP Address <br><img src="./images/screenshots/13.png" width="230"> <br><img src="./images/screenshots/14.png" width="395">
6. You can log into your Virtual Machine via SSH in a Browser by clicking the SSH button. Make note of your External IP (it will be different from the screenshot below).<br><img src="./images/screenshots/15.png" width="369">
7. Click the Hamburger Menu at the top left, click **VPC Network** and click **Firewall Rules**. <br><img src="./images/screenshots/firewall.png" width="222"> <br>Click **Create Firewall Rule** at the top center of the page. The name of your rule should be `allow-wireguard`, change the **Targets** dropdown to **All instances in the network**. The **Source IP Ranges** should be `0.0.0.0/0`. The **udp** checkbox should be selected, and the port number next to it should be changed from `all` to `51515`. Then click the **Create** button. You can disable the `default-allow-rdp` rule which Google set up with a default action of Allow, but because our server does not run any service on Port 3389 it is harmless to leave this rule alone. Do not disable the **default-allow-ssh** firewall rule, or you will disable the browser-based SSH from within the Google Cloud Console.


<img src="./images/logos/cloudconsole.svg" width="48" align="left">

# Cloud Console Mobile App

<a href="https://play.google.com/store/apps/details?id=com.google.android.apps.cloudconsole" target="_blank">
<img src="./images/logos/google-play.svg" alt="Get it on Google Play" height="60"></a>
<a href="https://itunes.apple.com/us/app/google-cloud-console/id1005120814?mt=8#iTunes" target="_blank">
<img src="./images/logos/app-store.svg" alt="Get it on the App Store" height="60"></a>

Install the "Cloud Console" app on your Android or iOS device.

Manage and monitor Google Cloud Platform services from your Android or iOS device.