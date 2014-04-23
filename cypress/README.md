# HDMI2USB - Building the USB firmware on Linux

## Installing wine + dependencies

Currently, the build requires a proprietary toolchain that is only available
for windows, but also runs in wine.

You need to have a recent wine version to install the toolchain. Wine 1.7 is
known to work. On Ubuntu you can use the PPA at https://launchpad.net/~ubuntu-wine/+archive/ppa
to install it.

To install the toolchain you also need to have .NET 2.0 and IE8 installed, you
can use winetricks for that purpose.

```
sudo add-apt-repository ppa:ubuntu-wine/ppa
sudo apt-get install wine1.7
sudo apt-get install winetricks

export WINEPREFIX=~/.wine32 # Use a separate wine environment
export WINEARCH=win32       # which is running 32-bit

wine wineboot               # initialize new wine environment
winetricks dotnetsp1        # install .NET 2.0 framework, if it
                            # doesn't know dotnetsp1, try
                            # 'dotnet20sp1'
winetricks ie8              # install IE8
```

## Installing the toolchain

The toolchain is available from Cypress at http://www.cypress.com/?rID=14321
as the "CY3684 EZ-USB FX2LP Development Kit (Rev. \*A)".

To install the toolchain, just run `CY3684Setup.exe`.

```
wine CY3684Setup.exe
```

## Building the firmware

If you made it all the way here, run:

```
wine ~/.wine32/drive_c/Keil/UV2/uv2.exe hdmi2usb.Uv2
```

Then "Project > Build Target" in the menu. The firmware should be available
as `output/hdmi2usb.hex`.

# TODO

This code should be changed to be 100% open source using the sdcc compiler.
The library at https://github.com/djmuhlestein/fx2lib might be helpful.
