---
title: Raspberry Pi 4B Setup 1 - Install Raspberry Pi OS
description: This post instructs how to install Raspberry Pi OS on the Raspberry Pi 4 Model B.
author: [johmin8888]
date: 2024-11-06 17:10:00 +09:00
categories: [Hardware, Raspberry Pi]
tags: [Hardware, Raspberry Pi]
pin: false
math: false
image:
  path: /media/20241106/rpi4b.jpg
  alt: Raspberry Pi 4 Model B
---

> This document is based on:
- Windows 10 Home
- Raspberry Pi 4 Model B
- Samsung Evo 32GB microSD Card
{: .prompt-info }

## 1. Prepare a microSD card

### 1.1. Check specifications

> A microSD card should be at least **8GB** or larger to operate the Raspberry Pi 4B. 
{: .prompt-warning }

According to [the official documentation](https://www.raspberrypi.com/documentation/computers/getting-started.html), **32GB** is the recommended size for the current version of Raspbian OS, while **16GB** is recommended for Raspbian OS Lite. The maximum capacity of the SD card can be up to **2TB**.

| Operating System     | Minimum | Recommended |
| :------------------- | :------ | :---------- |
| Raspberry Pi OS      | 8GB     | 32GB        |
| Raspberry Pi OS Lite | 8GB     | 16GB        |

### 1.2. Prepare the SD card reader and read the SD card

![A microSD card and its reader](/media/20241106/sd-card-reader.jpg){: width="500" height="500" }
_A MicroSD Card and Its Reader_

As shown in the picture, the reader has two slots for different SD card sizes. 

> I personally recommend using a reader with a dedicated microSD card slot for physical safety.
{: .prompt-tip }

*If you encounter issues reading the SD card on your computer, please go to Section [E.1](#e1-unable-to-read-the-microsd-card-on-your-computer).*

### 1.3. Format the SD card

![Default Drive Formatter](/media/20241106/format-sd-card.png)
_Drive Formatter on Windows 10_

> The SD card must be formatted to **FAT32**.
{: .prompt-warning }

FAT32 is a file system compatible with various operating systems. There are two different methods to format the SD card depending on its size.

For an SD card of 32GB or less, labeled as **SDHC**, use the Windows default drive formatter:

1. Right-click the SD card drive under `This PC`{: .filepath }.
2. Select "Format".
3. Leave configurations as default but set "File system" to **"FAT32"**. You may name your volume label. Check "Quick Format".
4. Click "Start" to begin formatting.

For SD cards larger than 32GB, labeled as **SDXC**, use a third-party SD card formatter, as the default Windows 10 formatter cannot handle it.

> SD Card Formatter from SD Card Association: <https://www.sdcard.org/downloads/formatter/>

*If you experience issues with formatting, please see Section [E.2](#e2-unable-to-complete-formatting-the-microsd-card) or [E.3](#e3-unable-to-create-primary-partition).*

## 2. Set Up the Raspberry Pi Imager

### 2.1. Install the Raspberry Pi Imager

Download the Raspberry Pi Imager from the official site.

> Raspberry Pi Imager: <https://www.raspberrypi.com/software/>

### 2.2. Select the Raspberry Pi OS

There are various operating systems available depending on your purpose:

For default options:

- **Raspberry Pi OS** is the standard version with a **Graphical UI** and basic applications. *Recommended for beginners.*

For "Raspberry Pi OS (other)" options:

- **Raspberry Pi OS Lite** is a lightweight version with a **Terminal-based UI**.
- **Raspberry Pi OS Full** includes a **Graphical UI** and additional recommended applications.

For "Other general-purpose OS" options:

- **Ubuntu Desktop** is a Linux-based OS with a **Graphical UI**.
- **Ubuntu Server** offers a **Terminal-based UI**.

*I personally selected **Raspberry Pi OS (64-bit)**, the default option, for easier adaptation to a development environment.*

![RPi Imager](/media/20241106/rpi-imager.png)
_Raspberry Pi Imager_


### 2.3. Configure the settings

When the OS customization prompt appears, you can edit settings such as username, password, WiFi, locale, SSH, etc. To connect the Raspberry Pi remotely using SSH, follow the steps below after selecting "edit settings"; otherwise, choose "no" to continue without customization.

![RPi Imager configuration](/media/20241106/rpi-imager-config.png)
_Enabling SSH from configurations on the imager_

- This configuration enables SSH via the address `username@raspberrypi.local`. To enable SSH, the username and password must be set.
- Configuring wireless LAN allows users to connect to a WiFi network other than the one connected to the user's computer.


## E. Error Notes

### E.1. Unable to read the microSD card on your computer

![SD card reading error](/media/20241106/sd-card-reading-error.png)
_Prompt when SD card has a reading error_

Sometimes, the microSD card drive won’t be recognized as shown above. Follow these steps to troubleshoot:

1. Check for physical damage on the microSD card, SD card mount, slot, or USB extension if used. 
   > If using an SD card adapter in the SD card slot, try directly inserting the microSD card into its dedicated slot.
   {: .prompt-tip }
2. Check if the microSD card is over 32GB. Windows 10 has issues with microSD cards larger than 32GB.
3. Check if the microSD card appears in `Disk Management`{: .filepath }.
   - Right-click the Windows logo, then find `Disk Management`{: .filepath }.
   - Type `Create and format hard disk partitions`{: .filepath } or `Disk Management`{: .filepath } in the search bar. *If the drive is recognized but labeled "Unallocated," refer to Section [E.3](#e3-unable-to-create-primary-partition).*

   ![Find drive recognition from Disk Management](/media/20241106/disk-management-unallocated.png) 
   _`Disk Management`{: .filepath } window showing a detected microSD card_

4. Update USB drivers in `Device Manager`{: .filepath }.
   - Right-click the Windows logo, then find `Device Manager`{: .filepath }.
   - Type `Device Manager`{: .filepath } in the search bar.

   ![Update USB drivers from Device Manager](/media/20241106/device-manager-usb-driver-update.png)
   _`Device Manager`{: .filepath } window instructing to "update driver"_

5. Try a different SD card mount or slot, or use another computer with an SD card slot on the mainboard. Some reports suggest that USB 3.0 may not detect microSD cards. 
   > If the SD card does not appear in `Device Manager`{: .filepath }, it might be a physical issue.*
   {: .prompt-warning }


### E.2. Unable to complete formatting the microSD card

If the SD card is corrupted or unused for a long time, formatting may fail. Try advanced options with `diskpart.exe`{: .filepath }.

1. Type `diskpart`{: .filepath } in the search bar or in `Command Prompt`{: .filepath } to open `diskpart.exe`{: .filepath }.
2. Type `list disk` to see if the SD card is detected.
3. Type `select disk {number}` to select the SD card drive.
4. Type `clean` to erase all data on the card.
5. Type `list volume`.
6. Type `select volume {number}` to select the volume you want to install the OS.
7. Type `create primary partition` to create partition 1 on the volume.
8. Type `format fs=FAT32 quick` to format the card in FAT32 format as a "quick format." This sets the maximum size for the card.
9. Once formatting is complete, type `exit` to close `diskpart.exe`{: .filepath }.


### E.3. Unable to `create primary partition`

If the SD card cannot create a partition on the selected volume, reinstall the volume.

1. Open `Disk Management`{: .filepath } to view the list of disks.
2. Right-click any volume on the selected microSD card disk.
3. Delete all volumes on the disk.
4. Right-click "Unallocated" volume.
5. Select "New Simple Volume" to start the "New Simple Volume Wizard."

   ![Create New Simple Volume](/media/20241106/disk-management-new-simple-volume.png)
   _`Disk Management`{: .filepath } window to create a "New Simple Volume" on the "Unallocated" volume_

6. Type the maximum disk space in MB in "Simple volume size in MB" (*usually set by default*).
7. Select your preferred drive letter.
8. Select "Format this volume with the following settings".
   - File system: **FAT32**
   - Allocation unit size: **Default**
   - Check "Perform a quick format".
9. Complete the wizard, then check if the card is correctly formatted.

    ![Correctly formatted](/media/20241106/disk-management-correctly-formatted.png)
    _`Disk Management`{: .filepath } window after formatting is completed_

## U. Useful Links

[Getting started with your Raspberry Pi](https://www.raspberrypi.com/documentation/computers/getting-started.html)

[13 Best Ways to Fix Corrupted/Damaged SD Card in 2024](https://www.cleverfiles.com/howto/fix-corrupted-sd-card.html)
