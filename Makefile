INTSTYLE = ise
# INTSTYLE = silent



# Top Level
all: syn tran map par trce bit


syn:
	@echo "========================================================="
	@echo "                       Synthesizing                      "
	@echo "========================================================="
	@cd  build; \
	xst \
	-intstyle $(INTSTYLE) \
	-filter "../ise/iseconfig/filter.filter" \
	-ifn "../ise/hdmi2usb.xst" \
	-ofn "hdmi2usb.syr"
	
tran:
	@echo "========================================================="
	@echo "                        Translate                        "
	@echo "========================================================="	
	ngdbuild \
	-filter "../ise/iseconfig/filter.filter" \
	-intstyle $(INTSTYLE) \
	-dd _ngo \
	-sd ../ipcore_dir \
	-nt timestamp \
	-uc ../ucf/hdmi2usb.ucf \
	-p xc6slx45-csg324-3 hdmi2usb.ngc hdmi2usb.ngd  

map:
	@echo "========================================================="
	@echo "                          Map                            "
	@echo "========================================================="
	map \
	-filter "../ise/iseconfig/filter.filter" \
	-intstyle $(INTSTYLE) \
	-p xc6slx45-csg324-3 \
	-w -logic_opt off \
	-ol high \
	-xe n \
	-t 1 \
	-xt 0 \
	-register_duplication off \
	-r 4 \
	-global_opt off \
	-mt off -ir off \
	-pr b -lc off \
	-power off \
	-o hdmi2usb_map.ncd hdmi2usb.ngd hdmi2usb.pcf 

par:
	@echo "========================================================="
	@echo "                     Place & Route                       "
	@echo "========================================================="
	par \
	-filter "../ise/iseconfig/filter.filter" -w \
	-intstyle $(INTSTYLE) \
	-ol high \
	-xe n \
	-mt off hdmi2usb_map.ncd hdmi2usb.ncd hdmi2usb.pcf 

trce:
	@echo "========================================================="
	@echo "                        Trace                            "
	@echo "========================================================="
	trce \
	-filter "../ise/iseconfig/filter.filter" \
	-intstyle $(INTSTYLE) \
	-v 3 \
	-s 3 \
	-n 3 \
	-fastpaths \
	-xml hdmi2usb.twx hdmi2usb.ncd \
	-o hdmi2usb.twr hdmi2usb.pcf 

bit:
	@echo "========================================================="
	@echo "                        Bitgen                           "
	@echo "========================================================="
	bitgen \
	-filter "../ise/iseconfig/filter.filter" \
	-intstyle $(INTSTYLE) \
	-f ../ise/hdmi2usb.ut hdmi2usb.ncd 

clean:

