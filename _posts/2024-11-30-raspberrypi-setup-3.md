---
title: Raspberry Pi 4B Setup 3 - Connecting Pi to Eduroam, An Enterprise Wi-Fi
description: This post guides you on how to connect the Raspberry Pi to Eduroam, an Enterprise Wi-Fi.
author: [johmin8888]
date: 2024-11-30 11:10:00 +09:00
categories: [Hardware, Raspberry Pi]
tags: [Hardware, Raspberry Pi]
pin: false
math: false
image:
  path: /media/20241106-raspberrypi-setup-1/rpi4b.jpg
  alt: Raspberry Pi 4 Model B
---

> This document is based on:
- Raspberry Pi 4 Model B 4GB
- Raspberry Pi OS (legacy, 64-bit)
- PuTTY v0.81 64-bit x86 Windows
{: .prompt-info }

## Introduction

**Eduroam** is one of the enterprise Wi-Fi networks that requires individual credentials (username and password) for authentication. It is a credential-based network that relies on user-specific credentials, typically provided by the home institution. To connect the Raspberry Pi to Wi-Fi in universities or research institutes, some manual configurations of the network settings are needed, unlike home Wi-Fi.

## 1. Setup before configurations

It is recommended to turn off the wireless network interfaces on the Raspberry Pi before making modifications to the configuration file.

1. Log in to the Raspberry Pi using SSH.
2. Type `iwlist wlan0 scan` to check if **Eduroam** is detected. The name of the Wi-Fi will be printed as `ESSID: "eduroam"`.
3. Type `sudo su` to elevate to superuser mode.
4. Type `ifdown wlan0`, then `ifdown eth0` to shut down all network interfaces.

   > What are `wlan0` and `eth0`?  
   These are network interfaces:  
   - `wlan0` is the Wi-Fi interface.  
   - `eth0` is the Ethernet interface.  
   {: .prompt-info }

5. Type `killall wpa_supplicant` to terminate any process associated with `wpa_supplicant.conf`{: .filepath }.

## 2. Modify Wi-Fi Network Configuration File

Now, it is safe to modify the configuration file `wpa_supplicant.conf`{: .filepath }.

1. Open `/etc/wpa_supplicant/wpa_supplicant.conf`{: .filepath } using **nano**:

    ```bash
    nano /etc/wpa_supplicant/wpa_supplicant.conf
    ```

2. Scroll to the bottom of the file and add the following network information. Replace the identity and password values with your own credentials.

   - For typical **Eduroam** (PEAP with MSCHAPv2): 

      ```bash
      network={
          ssid="eduroam"
          key_mgmt=WPA-EAP
          eap=PEAP
          identity="your_username@institution.edu"
          password="your_password"
          phase2="auth=MSCHAPV2"
          ca_cert="/etc/ssl/certs/ca-certificates.crt" # optional
      }
      ```
      {: file='/etc/wpa_supplicant/wpa_supplicant.conf' }

   - For **Eduroam** with certificate validation (EAP-TLS):

      ```bash
      network={
          ssid="eduroam"
          key_mgmt=WPA-EAP
          eap=TLS
          identity="your_username@institution.edu"
          client_cert="/path/to/client-cert.pem"
          private_key="/path/to/private-key.pem"
          ca_cert="/path/to/ca-certificate.pem"
          private_key_passwd="your_key_password"
      }
      ```
      {: file='/etc/wpa_supplicant/wpa_supplicant.conf' }

   - For anonymous identity to enhance privacy:

      ```bash
      network={
          ssid="eduroam"
          key_mgmt=WPA-EAP
          eap=PEAP
          identity="your_username@institution.edu"
          anonymous_identity="anonymous@institution.edu"
          password="your_password"
          phase2="auth=MSCHAPV2"
          ca_cert="/etc/ssl/certs/ca-certificates.crt"
      }
      ```
      {: file='/etc/wpa_supplicant/wpa_supplicant.conf' }

   > What do these values mean?  
   For more information about common values used in network configurations, refer to Section [A.1](#a1-common-values-in-the-wi-fi-network-configuration-file).
   {: .prompt-info }

3. Once finished, save and exit by pressing <kbd>Ctrl</kbd> + <kbd>X</kbd>, followed by <kbd>Y</kbd> to confirm saving.

4. Restart the `wpa_supplicant` service to apply the changes:

    ```bash
    systemctl restart wpa_supplicant
    ```

5. Initialize the `wpa_supplicant.conf`{: .filepath } file:

    ```bash
    wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
    ```


## 3. Check Connectivity

Now that the modifications to the Wi-Fi network configuration file are complete, let’s check the connectivity.

1. Type `ifup wlan0` followed by `ifup eth0` to bring the network interfaces back online.
2. Use `iwconfig` to verify that the `wlan0` network interface is connected to `ESSID:"eduroam"`.
3. Ping `www.google.com` to confirm data transmission:

    ```bash
    ping -c 3 www.google.com
    ```

## A. Appendix

### A.1. Common values in the Wi-Fi network configuration file

1. `ssid` is the name of the Wi-Fi network.
2. `key_mgmt` specifies the key management protocol used.
  - `WPA-EAP` for WPA2/WPA3 Enterprise
  - `IEEE8021X` for older 802.1X networks
3. `eap` specifies the Extensible Authentication Protocol (EAP) type. Common values:
  - `PEAP`: Protected EAP, commonly used with MSCHAPv2 for username/password authentication.
  - `TLS`: EAP-TLS, used for certificate-based authentication (requires client certificates).
  - `TTLS`: EAP-TTLS, similar to PEAP but supports more inner authentication methods.
  - `PWD`: EAP-PWD, password-based without certificates.
  - `FAST`: EAP-FAST, uses a Protected Access Credential (PAC) instead of certificates.
4. `identity` is the username or email address used to authenticate.
5. `password` is the user's password
6. `phase1` specifies the outer authentication method used in WPA2/WPA3 Enterprise networks. It is *not required* for most standard **Eduroam** setups using PEAP with MSCHAPv2, as default values often work without it.
  - Use `phase1="peaplabel=1"` if your institution uses PEAP with specific requirements for phase 1.
  - Use `phase1="include_tls_length=1"` for EAP-TLS, which is rarely required.
7. `phase2` specifies the inner authentication method for EAP.
  - `auth=MSCHAPV2` for PEAP, the most common method for **Eduroam**
  - `auth=PAP`, `auth=CHAP`, or `auth=GTC` used less frequently
8. `ca_cert` specifies the path to Certificate Authority (CA) certificate file, required for validating the server certificate.

    ```bash
    ca_cert="/path/to/ca-certificate.pem"
    ```

9. `client cert` specifies the path to the client certificate file, required for EAP-TLS.

    ```bash
    client_cert="/path/to/client-cert.pem"
    ```

10. `private_key` specifies the path to the private key file, used for EAP-TLS.

    ```bash
    private_key="/path/to/private-key.pem"
    ```

11. `private_key_password` is the password for the private key.
12. `anonymous_identity` specifies an anonymous identity sent in the first EAP request, protecting the actual username from being revealed during the initial authentication phase.
13. `priority` determines the priority of this network compared to others when connecting. Higher values mean higher priority to connect.
14. `proto` specifies the Wi-Fi protocol.
  - `RSN` for WPA2/WPA3
  - `WPA` for older WPA1

## Useful Links

[Connecting to eduroam wifi network](https://forums.raspberrypi.com/viewtopic.php?t=86253)

[Connecting Linux based Raspberry Pi devices to eduroam](https://services.udel.edu/TDClient/32/Portal/KB/ArticleDet?ID=919)

[HOWTO Connect Raspberry Pi to Eduroam Wi-Fi](https://inrg.engineering.ucsc.edu/howto-connect-raspberry-to-eduroam/)

[Raspberry Pi Zero OTG Mode](https://gist.github.com/gbaman/50b6cca61dd1c3f88f41)
