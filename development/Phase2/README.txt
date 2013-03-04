This Phase is for USB communication and JPEG implementation. For HDMI implementation look at Phase 1 directory.

HDMI stream capturing system which connects with PC and will appera as a video/web camera. Also act as a bypass system.
Initial design is based on Digilent Atlys.

USB chip on Digilent Atlys is used for data transfer as compare to previous design.

HDMI only is tested on on the following hardwares

-- input source
Acer Aspire 5755G 
Windows 7 and Ubuntu 

-- Display Devices
Acer GD245HQ (HDMI)
HP L1740 (DVI)
ViewSonic VX2260WM (HDMI)
LG TV (800x600)

-- Complete system is tested and build on 
Acer Aspire 5755G and HP L1740 (DVI)
Windows 7 and ubuntu 

-- To build 
At the moment preffer method of building is use Xilinx ISE
copy the build script into ise filter and run the script 
for windows use makefile.bat
for linux use makefile

-- To test the system
- Make sure JP6 and JP7 on ATLYS are open. 
- connect the LCD HDMI/DVI with ATLYS HDMI OUT(J2).
- Toggle(high then low) SW0 to emulate HPD. LED7 should turn on if not press red reset button and toggle again.
- Connect PC HDMI/DVI with ATLYS HDMI(J3). 
- Use SW1 to toggle between color and grayscale. 
- Use SW2 to turn jpeg encoder on. and use any uvc program to start capturing the video. 
- use hex file in cypress/UVC/outut to program cypress chip 
- EDID can be read using serial com port (using CDC driver). press "e" or "E". EDID will appear on screen. SW2 should be off.

-- Bugs
- At the moment onboard cypress chip is not working properly because works fine with expernal cypress board
- EDID tranfer is only possible before turning the jpeg encoder(SW[2])
- Complex images is causing crupted jpeg may be fifo overflow


