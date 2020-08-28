<table>
    <tbody>
        <tr>
            <td><b><a href="#google-cloud-login-and-account-creation">i.</a></b></td>
            <td>Google Cloud Login and Account Creation</td>
        </tr>
        <tr>
            <td><b><a href="#compute-engine-virtual-machine-setup">ii.</a></b></td>
            <td>Compute Engine Virtual Machine & Firewall Setup</td>
        </tr>
        <tr>
            <td><b><a href="#cloud-console-mobile-app">iii.</a></b></td>
            <td>Cloud Console Mobile App</td>
        </tr>
    </tbody>
</table>

---

<img src="./images/logos/cloud.svg" width="48" align="left">

# i. Google Cloud Login and Account Creation

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

---

<img src="./images/logos/computeengine.svg" width="48" align="left">

# ii. Compute Engine Virtual Machine Setup

Be aware of the limitations of the **[Free Usage Tier](https://cloud.google.com/free/)**:

- 1 vCPU + 3.75GB RAM f1-micro virtual machine instance per month in one of the following US regions:
  - Oregon: `us-west1`
  - Iowa: `us-central1`
  - South Carolina: `us-east1`
- up to 30 GB HDD
- 5 GB of snapshots storage for backups of your server in the following regions:
  - Oregon: `us-west1`
  - Iowa: `us-central1`
  - South Carolina: `us-east1`
  - Taiwan: `asia-east1`
  - Belgium: `europe-west1`
- 1 GB network egress from North America to all region destinations (excluding China and Australia) per month.

<ol>
<li>Create a Virtual Machine instance on Compute Engine: <br><img src="./images/screenshots/8.png" width="433"></li>
<li>Customize the instance:
  <ul>
    <li>Name: <b>pi-hole</b></li>
    <li>Labels: <em>optional section</em></li>
    <li>Region: <b>us-east1</b>, <b>us-west1</b>, or <b>us-central1</b>.
    <li>Zone: <em>choose anything, default selection is fine</em></li>
    <li>Machine configuration:
    <ul>
      <li>Machine family: <b>General-purpose</b></li>
      <li>Series: <b>N1</b></li>
      <li>Machine type: <b>n1-standard-1</b> (1 vCPU, 3.75 GB memory)</li>
    </ul>
    </li>
    <li>Boot disk: click <b>Change</b></li>
      <ul>
        <li>Operating system: <b>Ubuntu</b></li>
        <li>Version: <b>Ubuntu 20.04 LTS Minimal</b></li>
        <li>Boot disk type: <b>30GB</b></li>
      </ul>
    </ul>
    The final selections should appear as follows: <br><img src="./images/screenshots/9.png" width="466">
  </li>
  <li>Expand <b>Management, Security, disks, networking, sole tenancy</b>:
    <ul>
      <li>Click the <b>Networking</b> tab</li>
      <li>Click the Pencil icon under <b>Network Interfaces</b><br><img src="./images/screenshots/10.png" width="476"></li>
      <li>In the External IP Address section, change from <b>Ephemeral</b> to <b>Create IP Address</b> to reserve a new Static IP Address.<br>Click <b>Reserve</b> <br><img src="./images/screenshots/13.png" width="460"> <br><img src="./images/screenshots/14.png" width="790"></li>
    </ul>
  </li>
<li>You can log into your Virtual Machine via SSH in a Browser by clicking the SSH button. Make note of your External IP (it will be different from the screenshot below).<br><img src="./images/screenshots/15.png" width="369"></li>
<li>Click the Hamburger Menu at the top left, click <b>VPC Network</b> and click <b>Firewall Rules</b>. <br><img src="./images/screenshots/firewall.png" width="444"> <br>Click <b>Create Firewall Rule</b> at the top center of the page. The name of your rule should be <code>allow-wireguard</code>, change the <b>Targets</b> dropdown to <b>All instances in the network</b>. The <b>Source IP Ranges</b> should be <code>0.0.0.0/0</code>. The <b>udp</b> checkbox should be selected, and the port number next to it should be changed from <code>all</code> to <code>51515</code>. Then click the <b>Create</b> button. You can disable the <code>default-allow-rdp</code> rule which Google set up with a default action of Allow, but because our server does not run any service on Port 3389 it is harmless to leave this rule alone. Do not disable the <b>default-allow-ssh</b> firewall rule, or you will disable the browser-based SSH from within the Google Cloud Console.</li>
</ol>

---

<img src="./images/logos/cloudconsole.svg" width="48" align="left">

# iii. Cloud Console Mobile App

<a href="https://play.google.com/store/apps/details?id=com.google.android.apps.cloudconsole" target="_blank">
<img src="./images/logos/google-play.svg" alt="Get it on Google Play" height="60"></a>
<a href="https://itunes.apple.com/us/app/google-cloud-console/id1005120814?mt=8#iTunes" target="_blank">
<img src="./images/logos/app-store.svg" alt="Get it on the App Store" height="60"></a>

Install the "Cloud Console" app on your Android or iOS device.

Now you can manage and monitor Google Cloud Platform services from your Android or iOS device.
