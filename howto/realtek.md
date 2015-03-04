## Try this first

If you are facing any problems with Realtek adapters (e.g. Edimax EW-7811Un)
first try to run create_ap with `-w 2` (i.e. use WPA2 only) or use it
without passphrase. If you are still facing any problems or you want to
also use WPA1, then follow the instructions below.

NOTE: The instructions below are only valid for Realtek adapters with 8192 chipset.

## Before installation

If you're using ArchLinux, run:

```
pacman -S base-devel linux-headers dkms git
pacman -R hostapd
```

If you're using Debian, Ubuntu, or any Debian-based distribution, run:

```
apt-get install build-essential linux-headers-generic dkms git
apt-get remove hostapd
apt-get build-dep hostapd
```

## Install driver

The driver in the mainline of Linux kernel doesn't work well with the 8192 adapters.
For this reason you need to install the driver that is provided from Realtek. Their
driver can not be compiled with newer kernels, but since it was an open-source
release under GPL license some people were able to fixed it and make it compile.

With the following commands you can install a fixed version of Realtek's driver:

```
git clone https://github.com/pvaret/rtl8192cu-fixes.git
dkms add rtl8192cu-fixes
dkms install 8192cu/1.9
cp rtl8192cu-fixes/blacklist-native-rtl8192.conf /etc/modprobe.d
cp rtl8192cu-fixes/8192cu-disable-power-management.conf /etc/modprobe.d
```

After installation, unload the previous driver and load the new one, or just reboot.

## Install hostapd

Realtek's driver is using an old subsystem which is called `wireless-extensions`
(or `wext`). Hostapd works only with the new subsystem (which is called `nl80211`).
For this reason Realtek wrote a patch for hostapd. You can install it with the
following commands:

If you have ArchLinux install [hostapd-rtl871xdrv](https://aur.archlinux.org/packages/hostapd-rtl871xdrv)
from AUR or just run:

```
yaourt -S hostapd-rtl871xdrv
```

If you're using any other distribution, run:

```
git clone https://github.com/pritambaral/hostapd-rtl871xdrv.git
wget http://w1.fi/releases/hostapd-2.2.tar.gz
tar zxvf hostapd-2.2.tar.gz
cd hostapd-2.2
patch -p1 -i ../hostapd-rtl871xdrv/rtlxdrv.patch
cp ../hostapd-rtl871xdrv/driver_* src/drivers
cd hostapd
cp defconfig .config
echo CONFIG_DRIVER_RTW=y >> .config
make
make install
```
