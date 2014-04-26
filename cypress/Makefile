
# Use a separate wine environment
export WINEPREFIX=$(HOME)/.wine32
# which is running 32-bit
export WINEARCH=win32

output/hdmi2usb.hex: DSCR_HDMI2USB.a51 EZUSB.LIB fw.c Fx2.h fx2regs.h fx2sdly.h hdmi2usb.c hdmi2usb.Uv2 syncdly.h usb2hdmi.inf USBJmpTb.OBJ
	wine ~/.wine32/drive_c/Keil/UV2/uv2.exe -b hdmi2usb.Uv2


packages:
	sudo add-apt-repository ppa:ubuntu-wine/ppa
	sudo apt-get install wine1.7
	sudo apt-get install winetricks


wine: packages
	wine wineboot
	winetricks dotnet20sp1
	winetricks ie8


CY3684Setup.exe:
	wget "http://dlm.cypress.com.edgesuite.net/downloadmanager/software/cy3684kit_revSA.zip?userid=375693441"


clean:
	git clean -x -f -d


cypress-tools: CY3684Setup.exe wine
	wine CY3684Setup.exe


.PHONY: packages wine cypress-compiler firmware
