---
title: Raspberry Pi 4B Setup 2 - Gadget Mode
description: This post provides instructions on enabling USB gadget mode on the Raspberry Pi 4 Model B via Ethernet, allowing it to function as a network adapter connected to a computer using only a USB-C cable, without a monitor, mouse, or keyboard.
author: [johmin8888]
date: 2024-11-20 02:20:00 +09:00
categories: [Hardware, Raspberry Pi]
tags: [Hardware, Raspberry Pi]
pin: false
math: false
image:
  path: /media/20241106-raspberrypi-setup-1/rpi4b.jpg
  alt: Raspberry Pi 4 Model B
---

> This document is based on:
- Windows 10 Home (22H2)
- Raspberry Pi 4 Model B 4GB
- Raspberry Pi OS (legacy, 64-bit)
- PuTTY v0.81 64-bit x86 Windows
- RealVNC Viewer 7.12.1 (r21) x64
- RealVNC Server 7.5.1
{: .prompt-info }
 
## Introduction

This post provides a guide to enabling 'gadget mode' on the Raspberry Pi 4 Model B using only a USB-C cable, without requiring a mouse, keyboard, or monitor. The setup can be completed entirely from your computer. The Raspberry Pi 4B is chosen because it is the most powerful Raspberry Pi device capable of running the 'legacy OS.' Raspberry Pi 5 cannot install the legacy OS, which simplifies the process of enabling gadget mode. While it is possible to enable gadget mode on a Raspberry Pi 5, it requires additional peripherals (mouse, keyboard, and monitor) to modify `/boot`{: .filepath } files.

> Raspberry Pi 5 gadget mode discussions:  
- RPi 5 USB gadget mode possible?: <https://forums.raspberrypi.com/viewtopic.php?t=358573>  
- Pi 5 dwc2 overlay fails #77: <https://github.com/raspberrypi/bookworm-feedback/issues/77>

## 1. Modify boot files

The Raspberry Pi OS is not configured for 'USB Gadget Mode' by default. To enable it, some files in `/boot`{: .filepath } or `/bootfs`{: .filepath } must be modified.

1. Remove and reinsert the SD card into your computer if this step was not completed right after the OS installation.

   > You will see `/bootfs`{: .filepath } or `/boot`{: .filepath }, which is accessible, and `/USB Drive`{: .filepath }, which is not. This is normal on Windows, as it cannot read Linux-based file systems.
   {: .prompt-info }

    ![RPi OS Volumes](/media/20241120-raspberrypi-setup-2/rpi-os-volumes.png){: .shadow }
    _Two drives appear after the OS installation is completed on the microSD card._

2. Open the file `/bootfs/config.txt`{: .filepath } and add the following line at the end. Save and close the file.

   ```text
   [all]
   dtoverlay=dwc2
   ```
   {: file='/bootfs/config.txt' }

   > What does `dtoverlay=dwc2` mean? <br>
   **DWC2** refers to the **DesignWare USB 2.0 Core** driver. which allows the Raspberry Pi to function as a USB gadget device.
   {: .prompt-info }

3. Open the file `/bootfs/cmdline.txt`{: .filepath }, and add `modules-load=dwc2,g_ether` after `rootwait`. Save and close the file.

   ```text
   ... rootwait modules-load=dwc2,g_ether ...
   ```
   {: file='/bootfs/cmdline.txt' }

   > What does `g_ether` mean? <br>
   `g_ether` is one of several emulation modes for the Raspberry Pi when DWC2 is enabled. **USB Ethernet** (`g_ether`) emulates a  USB network adapter, allowing the Pi to appear as a network interface to a connected host computer. For the other USB gadget modules, please refer to Section [A.1](#a1-common-usb-gadget-modules).
   {: .prompt-info }

1. Create a file named `ssh`{: .filepath } in `/bootfs` with no extension and no contents.
   > You can create this file by renaming a text file anad removing the `.txt` extension using a text editor like VSCode.
   {: .prompt-tip }

    ![SSH File on RPi4B](/media/20241120-raspberrypi-setup-2/ssh-file.png){: .shadow }
    _Creating the `ssh`{: .filepath }_

## 2. Connect RPi4B with a USB-C cable

1. Download **Bonjour Print Services for Windows** from the following link: <https://developer.apple.com/bonjour/>.

   > Bonjour Services is an application developed by Apple that improves USB communication between Windows and Linux-based computers. It allows you to use `ssh {username}@{hostname}.local` instead of an IP address.
   {: .prompt-info }

    ![Bonjour Services Download](/media/20241120-raspberrypi-setup-2/bonjour-services-download.png){: .shadow }
    _**Bonjour Print Services for Windows** download page_

2. Insert the microSD card into the Raspberry Pi.
   - Ensure the card’s electrical contacts face the board.

3. Connect the USB-C cable between the Raspberry Pi and your computer.
   - A successful connection will cause the green LED on the Raspberry Pi to blink.

4. Open **Device Manager** on your computer and verify that "USB Ethernet/RNDIS Gadget" is listed under the "Network adapters" section.

    ![Successful Detection on Device Manager](/media/20241120-raspberrypi-setup-2/device-manager-successfully-detected.png)
    _Successful detection of the device in **Device Manager**_

    > If the device is detected under "Ports (COM & LPT)" instead of "Network adapters," follow the instructions in Section [E.1](#e1-device-is-detected-under-the-ports-com--lpt-tree) to install the **RNDIS/Ethernet Gadget** driver.
    {: .prompt-warning }

## 3. Run SSH to control RPi4B

Secure Shell (SSH) is a protocol used to control and manage a remote machine from a client computer. It enables communication between your computer and the Raspberry Pi. For additional details on connecting to the Raspberry Pi remotely, refer to the YouTube video below.

{% include embed/youtube.html id='l4VDWhKsFgs' %}

You can use three methods to establish an SSH connection on Windows:
1. **OpenSSH Client**, which enables SSH through **Command Prompt**.
2. **PuTTY**, a third-party SSH application.
3. **VNC**, which provides a graphical user interface (GUI) for remote access.

### 3.1. Using OpenSSH Client

**OpenSSH Client** is a built-in application that enables SSH through **Command Prompt** in Windows 10 and later versions. However, it must be installed manually. Follow the steps below to install the application:

1. Go to **Settings**.
2. Search for `Add an optional feature` in the search bar.
3. Look for **OpenSSH Client**.

    ![OpenSSH Client Installation](/media/20241120-raspberrypi-setup-2/openssh-client-install.png)
    _**OpenSSH Client** installation page in **Settings**_

4. Install it.

Once installed, follow these steps to use SSH:

5. Open **Command Prompt**.
6. Type `ssh {username}@{hostname}.local`.
7. When prompted with "Are you sure you want to continue connecting (yes/no/[fingerprint])?", type `yes`.
8. Enter the password you set during the OS installation on the Raspberry Pi.

### 3.2. Using PuTTY

**PuTTY** is a popular third-party SSH application, especially for Windows users, offering extensive SSH management options.

1. Download **PuTTY** from the official website: <https://www.putty.org/>. Alternatively, you can install it from the Microsoft Store.
2. After installation, open **PuTTY**.
3. In the "Host Name (or IP address)" field, type `{hostname}.local` as configured during the OS setup.
4. Ensure the port is set to `22` and the connection type is `SSH`.

    ![PuTTY Start Page](/media/20241120-raspberrypi-setup-2/putty-start.png)
    _Configuration page in **PuTTY**_

5. Click "Open."
6. When prompted with "login as:", enter `{username}`.
7. Enter the password you set during the OS installation on the Raspberry Pi.

    ![Successful Login Prompt on PuTTY](/media/20241120-raspberrypi-setup-2/putty-successful-login.png)
    _Successful login prompt in **PuTTY**_

### 3.3. Using VNC

**Virtual Network Computing (VNC)** is a protocol that provides a graphical user interface (GUI) while maintaining an SSH connection. It offers a complete remote control experience.

> To use VNC, the Raspberry Pi OS must support a graphical UI. This excludes Lite OS versions.
{: .prompt-warning }

#### 3.3.1. Enabling VNC mode on the Raspberry Pi

Before using VNC, enable the VNC mode on the Raspberry Pi by accessing its configuration via SSH (refer to Section [3.1](#31-using-openssh-client) or [3.2](#32-using-putty)).

1. Connect to the Raspberry Pi via SSH.
2. Run the command: `sudo raspi-config`.

    ![Raspberry Pi Configuration Prompt on PuTTY](/media/20241120-raspberrypi-setup-2/putty-raspi-config.png)
    _Raspberry Pi configuration prompt in **PuTTY**_

3. In the "Raspberry Pi Software Configuration Tool (raspi-config)" menu, navigate to "Interface Options."
   > Use <kbd>&#8593;</kbd> and <kbd>&#8595;</kbd> keys to navigate and press <kbd>Enter</kbd> to select. Use <kbd>&#8592;</kbd> and <kbd>&#8594;</kbd> to switch between "\<Select>", "\<Back>", and "\<Finish>".
   {: .prompt-tip }

    ![raspi-config Interface Options 1](/media/20241120-raspberrypi-setup-2/raspi-config-interface-options-1.png)
    _`raspi-config` menu page_

4. Select "VNC."

    ![raspi-config Interface Options 2](/media/20241120-raspberrypi-setup-2/raspi-config-interface-options-2.png)
    _`raspi-config` interface options page_

5. When prompted, "Would you like the VNC Server to be enabled?", select "\<Yes>."

    ![raspi-config Enabling VNC](/media/20241120-raspberrypi-setup-2/raspi-config-enabling-vnc.png)
    _Enabling VNC mode_

6. Select "\<Finish>" to return to the terminal.
7. Restart the Raspberry Pi.

#### 3.3.2. Using **RealVNC Viewer**

Once VNC mode is enabled, use the **RealVNC Viewer** client to connect.

1. Download **RealVNC Viewer** from the official website: <https://www.realvnc.com/en/connect/download/viewer/>. Alternatively, install it from the Microsoft Store.
2. Open the application. You do not need to log in. Close the login window and enter the VNC server address (either the IP address or `{hostname}.local`).

    ![RealVNC Viewer Accessed](/media/20241120-raspberrypi-setup-2/realvnc-viewer-accessed.png)
    _**RealVNC Viewer** interface_

3. Enter the username and password. Click "OK" to start.
4. The Raspberry Pi desktop will appear, and the address will be saved in the address book.

    ![RealVNC Viewer Connected](/media/20241120-raspberrypi-setup-2/realvnc-viewer-connected.png)
    _**RealVNC Viewer** when connected_

#### 3.3.3. Adjusting Resolution

If the resolution is unsatisfactory, adjust it through the Raspberry Pi configuration menu (`raspi-config`).

1. On the Raspberry Pi desktop, click the Raspberry Pi icon in the top-left corner.
2. Navigate to "Preferences" > "Raspberry Pi Configuration."
3. Select the "Display" tab and choose your preferred "Headless Resolution."

    ![raspi-config GUI resolution adjustment](/media/20241120-raspberrypi-setup-2/raspi-config-gui-resolution-adjustment.png)
    _Adjusting resolution through the GUI_

> If you encounter the error `Cannot currently show the desktop`, resolve it by manually setting the resolution through the Raspberry Pi configuration menu. See Section [E.2](#e2-realvnc-viewer-error-cannot-currently-show-the-desktop) for more details.
{: .prompt-warning }

## A. Appendix

### A.1. Common USB gadget modules

- `g_ether` emulates a **USB Ethernet adapter**, allowing network communication between the device and the host. It is used for networking between the Raspberry Pi and a host such as via SSH over a USB cable.
- `g_serial` emulates a **USB-to-serial converter**, enabling serial communication like a COM port. It is used for debugging or controlling the Raspberry Pi via serial connection.
- `g_mass_storage` emulates a **USB flash drive or external storage device**, making the device appear as a storage medium to the host. It is enabled when sharing files with a host by emulating a USB flash drive.
- `g_hid` emulates a **USB Human Interface Device (HID)**, such as a keyboard, mouse, or joystick.
- `g_audio` emulates a **USB audio device**, such as a microphone or speaker. It is used to utilize the Raspberry Pi as a USB microphone or speaker.
- `g_webcam` emulates a **USB Video Class (UVC) device**, making the device appear as a webcam. It is enabled to stream video from the Raspberry Pi's camera module as a USB webcam.
- `g_midi` emulates a **USB MIDI device**, allowing the device to act as a musical instrument interface. It is used when connecting the Raspberry Pi to a MIDI-compatible musical instrument.
- `g_multi` combines multiple functionalities (e.g., Ethernet + mass storage or Ethernet + serial).
- `g_acm_ms` combines **serial (ACM)** and **mass storage**.
- `g_ncm` emulates a **USB Ethernet device** using the NCM protocol, which is faster than RNDIS.
- `g_cdc` emulates a **CDC Ethernet device**, providing an alternative USB networking.

## E. Error Notes

### E.1. Device is detected under the "Ports (COM & LPT)" tree

On Windows 10, the Raspberry Pi device might not be recognized as an Ethernet gadget and may instead appear as a USB device under "Ports (COM & LPT)." This issue can be resolved by installing the **RNDIS/Ethernet Gadget** driver[^1].

1. Download the RNDIS driver from this link: <https://modclouddownloadprod.blob.core.windows.net/shared/mod-duo-rndis.zip>.
    - Alternatively, use this file link: [RNDIS/Ethernet Gadget](/media/20241120-raspberrypi-setup-2/mod-duo-rndis.zip)
2. Extract the `mod-duo-rndis`{: .filepath } folder from the `.zip`{: .filepath } file.
3. Open **Device Manager** and navigate to "Ports (COM & LPT)."
4. Expand the section and locate the detected "USB Serial Device."
5. Right-click the device and select "Update Driver Software."
6. Choose "Browse my computer for driver software."
7. Browse to the extracted folder, `mod-duo-rndis`{: .filepath }, and ensure "Include subfolders" is checked.

    ![Device Manager USB Driver Update](/media/20241120-raspberrypi-setup-2/device-manager-driver-update.png)
    _Browsing `mod-duo-rndis`{: .filepath } in the driver updater_

8. In **Device Manager**, click "Action" > "Scan for hardware changes."
9. Verify that "USB Ethernet/RNDIS Gadget" now appears under the "Network adapters" section.

### E.2. RealVNC Viewer Error: `Cannot currently show the desktop`

![RealVNC Viewer Error on Showing the Desktop](/media/20241120-raspberrypi-setup-2/realvnc-viewer-error-cannot-show.png)
_**RealVNC Viewer** error when the Raspberry Pi desktop cannot be displayed. Referenced from a Raspberry Pi forum discussion[^2]._  

This error often occurs when no HDMI monitor is attached. Manually setting the display resolution resolves the issue.

1. Connect to the Raspberry Pi using a terminal interface via **OpenSSH** or **PuTTY**.
2. Open the Raspberry Pi configuration menu by entering the command: `sudo raspi-config`.
3. Navigate to "Display Options."

    ![raspi-config Display Options 1](/media/20241120-raspberrypi-setup-2/raspi-config-display-options-1.png)
    _`raspi-config` menu page_

4. Select "VNC Resolution."

    ![raspi-config Display Options 2](/media/20241120-raspberrypi-setup-2/raspi-config-display-options-2.png)
    _`raspi-config` display options page_

5. Choose your preferred resolution.

    ![raspi-config VNC Resolution Adjustment](/media/20241120-raspberrypi-setup-2/raspi-config-vnc-resolution-adjustment.png)
    _Adjusting VNC resolution_

6. Reboot the Raspberry Pi.

## Useful Links

[Turning your Raspberry Pi Zero into a USB Gadget](https://cdn-learn.adafruit.com/downloads/pdf/turning-your-raspberry-pi-zero-into-a-usb-gadget.pdf)

[How to Set Up a Headless Raspberry Pi, Without Ever Attaching a Monitor](https://www.tomshardware.com/reviews/raspberry-pi-headless-setup-how-to,6028.html)

[Raspberry Pi Zero USB/Ethernet Gadget Tutorial](https://www.circuitbasics.com/raspberry-pi-zero-ethernet-gadget/#google_vignette)


## References

[^1]: [Raspberry Pi Zero W Headless setup – Windows 10 RNDIS Driver issue resolved](https://www.factoryforward.com/pi-zero-w-headless-setup-windows10-rndis-driver-issue-resolved/)

[^2]: [\[VNC\] Cannot currently show the dekstop](https://forums.raspberrypi.com/viewtopic.php?t=216737)
