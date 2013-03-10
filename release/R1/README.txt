This Phase is for USB communication and JPEG implementation. For HDMI implementation look at Phase 1 directory.
HDMI stream capturing system which connects with PC and will appera as a video/web camera. Also act as a bypass system.
Initial design is based on Digilent Atlys.

USB chip on Digilent Atlys is used for data transfer as compare to previous design.

HDMI only is tested on the following hardwares

input source
Acer Aspire 5755G 
Windows 7 and Ubuntu 

Display Devices
Acer GD245HQ (HDMI)
HP L1740 (DVI)
ViewSonic VX2260WM (HDMI)
LG TV (800x600)

-- Complete system is tested and build on 
input source
Acer Aspire 5755G 
Windows 7/ Ubuntu

Display Devices
HP L1740 (DVI)

-- To build 
	- At the moment we only recommend building the project use the xilinx projects in ise folder.
	
-- To test the system
	- Make sure JP6 and JP7 on ATLYS are open. 
	- connect the LCD HDMI/DVI with ATLYS HDMI OUT(J2).
	- Toggle(high then low) SW0 to emulate HPD. LED7 should turn on if not press red reset button and toggle again.
	- Connect PC HDMI/DVI with ATLYS HDMI(J3). 
	- Use SW1 to toggle between color and grayscale. 
	- EDID can be read using serial com port (using CDC driver). press "e" or "E". EDID will appear on screen. SW2 should be off.
	- Use SW2 to turn jpeg encoder on. and use any uvc program to start capturing the video. 

-- important info.txt contain important information about different files and folder in the design

-- folder pre-build containes the hex and bit files to test the system. to test the complete system use hdmi2usb_onboard.bit and uvc.hex
