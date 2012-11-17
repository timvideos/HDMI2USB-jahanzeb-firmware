

XILINX=/opt/Xilinx/14.2/ISE_DS/ISE
XILINX_DSP=${XILINX}
PATH=${XILINX}/bin/lin64:${XILINX}/lib/lin64

hdmi2usb.syr: hdmi2usb.xst
	mkdir xst/projnav.tmp
	xst -intstyle ise \
		-ifn "hdmi2usb.xst" \
		-ofn "hdmi2usb.syr"

hdmi2usb.ngd: ../../hdl/hdmi2usb.ucf
	ngdbuild -intstyle ise \
		-dd _ngo \
		-nt timestamp \
		-uc ../../hdl/hdmi2usb.ucf \
		-p xc6slx45-csg324-3 \
		hdmi2usb.ngc \
		hdmi2usb.ngd

hdmi2usb_map.ncd: hdmi2usb.ngd hdmi2usb.pcf
	map -intstyle ise \
		-p xc6slx45-csg324-3 \
		-w -logic_opt off \
		-ol high \
		-t 1 \
		-xt 0 \
		-register_duplication off \
		-r 4 \
		-global_opt off \
		-mt off \
		-ir off \
		-pr off \
		-lc off \
		-power off \
		-o hdmi2usb_map.ncd \
		hdmi2usb.ngd hdmi2usb.pcf
	par -w -intstyle ise \
		-ol high \
		-mt off \
		hdmi2usb_map.ncd hdmi2usb.ncd hdmi2usb.pcf

hdmi2usb.twr: hdmi2usb.ncd hdmi2usb.twx
	trce -intstyle ise \
		-v 3 \
		-s 3 \
		-n 3 \
		-fastpaths \
		-xml hdmi2usb.twx \
		hdmi2usb.ncd \
		-o hdmi2usb.twr \
		hdmi2usb.pcf

hdmi2usb.ncd: hdmi2usb.ut
	bitgen -intstyle ise -f hdmi2usb.ut hdmi2usb.ncd
