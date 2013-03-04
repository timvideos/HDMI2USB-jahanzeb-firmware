all:
	XILINX=/opt/Xilinx/14.2/ISE_DS/ISE
	XILINX_DSP=${XILINX}
	PATH=${XILINX}/bin/lin:${XILINX}/lib/lin
	/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin/xst -intstyle ise -filter "iseconfig/filter.filter" -ifn "hdmi2usb.xst" -ofn "hdmi2usb.syr" 
	/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin/ngdbuild -filter "iseconfig/filter.filter" -intstyle ise -dd _ngo -sd ipcore_dir -nt timestamp -uc /home/jahanzeb/Dropbox/vWorker/phase2/ucf/backup/hdmi2usb_offboard_usb.ucf -p xc6slx45-csg324-3 hdmi2usb.ngc hdmi2usb.ngd  
	/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin/map -filter "/home/jahanzeb/Dropbox/vWorker/phase2/ise/iseconfig/filter.filter" -intstyle ise -p xc6slx45-csg324-3 -w -logic_opt on -ol high -xe n -t 1 -xt 0 -register_duplication off -r 4 -global_opt off -mt off -ir off -pr b -lc off -power off -o hdmi2usb_map.ncd hdmi2usb.ngd hdmi2usb.pcf 
	/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin/par -filter "/home/jahanzeb/Dropbox/vWorker/phase2/ise/iseconfig/filter.filter" -w -intstyle ise -ol high -xe n -mt off hdmi2usb_map.ncd hdmi2usb.ncd hdmi2usb.pcf 
	/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin/trce -filter /home/jahanzeb/Dropbox/vWorker/phase2/ise/iseconfig/filter.filter -intstyle ise -v 3 -s 3 -n 3 -fastpaths -xml hdmi2usb.twx hdmi2usb.ncd -o hdmi2usb.twr hdmi2usb.pcf 
	/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin/bitgen -filter "iseconfig/filter.filter" -intstyle ise -f hdmi2usb.ut hdmi2usb.ncd 
