
# Building on Linux

Install wine1.7, on Ubuntu you can use the PPA at https://launchpad.net/~ubuntu-wine/+archive/ppa
Install winetricks

```
sudo add-apt-repository ppa:ubuntu-wine/ppa
sudo apt-get install wine1.7
sudo apt-get install winetricks
export WINEPREFIX='/home/tansell/.wine32'
export WINEARCH='win32'
# Initialize the wine directory
wine 'wineboot'
winetricks dotnetsp1
winetricks ie8

# Get the CY3684Setup.exe executable
wine CY3684Setup.exe
wine /home/tansell/.wine32/drive_c/Keil/UV2/uv2.exe hdmi2usb.Uv2
```

Then "Project > Build Target" in the menu.

# TODO

This code should be changed to be 100% open source using the sdcc compiler and
probably https://github.com/djmuhlestein/fx2lib

