# DuetScreen image boot options

The DuetScreen image provides a couple of options to be set **on first boot only** using the user-accessible FAT32 boot partiton of a burnt SD image.
Note that these options are **not** available when booting from the embedded NAND memory.

Here you can find a list of the mentioend boot options and their implications:

## WiFi

### WiFi setup

In order to set up WiFi, create file `wpa_supplicant.conf` with your WiFi data. Example:

```
ctrl_interface=/var/run/wpa_supplicant
update_config=1
ap_scan=1

network={
    scan_ssid=1
    ssid="<WiFi SSID>"
    psk="<WiFi PSK>"
}
```

Replace `<WiFi SSID>` and `<WiFi PSK>` with your own data.

Once the board has booted and WiFi has been enabled in the USB settings, it will attempt to connect to the provided WiFi network and obtain an IP address via DHCP.

### Static IP address

If you wish to set up a static IP address for the screen, it is necessary to create `dhcpcd.conf` with content like:

```
interface wlan0

static ip_address=192.168.0.200/24
static routers=192.168.0.1
static domain_name_servers=192.168.0.1
```

Adjust this to your own needs.

## Shell access

For security reasons the image does not come with any shell access enabled by default.
However, if you need to obtain access to a shell, this can be achieved by setting a `root` password first.

To set a `root` password, create a file `password`  or `password.txt` on the boot partition with your chosen password.
This will be applied on first boot and erased again from the SD card when the screen boots. It must not be empty.

### SSH

The DuetScreen image comes with a preinstalled version of the Dropbear SSH server.
This service can be enabled by creating an `ssh` file on the boot partition.

Note that it does not permit remote access if the `root` password is empty or not set.

#### SSH certificate

Instead of password-based authentication, it is possible to install a custom SSH certificate.
To achieve this, simply copy your `authorized_keys` file to the boot partition and it will be automatically moved into place.

### ADB

Apart from the classic SSH remote access, it is also possible to activate an Android Debug Bridge.
To do this, create a file called `adb` on the boot partition. Note that ADB does not use password authentication.

Bear in mind that **either** ADB **or** WiFi can be active because the USB port is shared among the two.
In order to use ADB, put the screen in `USB device` mode.

### UART

In order to enable UART console access on the debug port, create a file `getty` on the first boot partition.

