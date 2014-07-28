COLORMAKETOOL = "../tools/colormake.pl"

INTSTYLE = ise
# INTSTYLE = silent

BUILD_DIR = build # build directiry for temp files

# Top Level
all: syn tran map par trce bit

syn:
	@echo "========================================================="
	@echo "                       Synthesizing                      "
	@echo "========================================================="
	@mkdir -p $(BUILD_DIR)
	@cd $(BUILD_DIR); \
	xst \
	-intstyle $(INTSTYLE) \
	-filter "../ise/iseconfig/filter.filter" \
	-ifn "../ise/hdmi2usb.xst" \
	-ofn "hdmi2usb.syr" \
        | $(COLORMAKETOOL); (exit $${PIPESTATUS[0]})
	
tran:
	@echo "========================================================="
	@echo "                        Translate                        "
	@echo "========================================================="	
	@cd $(BUILD_DIR); \
	ngdbuild \
	-filter "../ise/iseconfig/filter.filter" \
	-intstyle $(INTSTYLE) \
	-dd _ngo \
	-sd ../ipcore_dir \
	-nt timestamp \
	-uc ../ucf/hdmi2usb.ucf \
	-p xc6slx45-csg324-3 hdmi2usb.ngc hdmi2usb.ngd \
        | $(COLORMAKETOOL); (exit $${PIPESTATUS[0]})

map:
	@echo "========================================================="
	@echo "                          Map                            "
	@echo "========================================================="
	@cd $(BUILD_DIR); \
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
	-o hdmi2usb_map.ncd hdmi2usb.ngd hdmi2usb.pcf \
        | $(COLORMAKETOOL); (exit $${PIPESTATUS[0]})

par:
	@echo "========================================================="
	@echo "                     Place & Route                       "
	@echo "========================================================="
	@cd $(BUILD_DIR); \
	par \
	-filter "../ise/iseconfig/filter.filter" -w \
	-intstyle $(INTSTYLE) \
	-ol high \
	-xe n \
	-mt off hdmi2usb_map.ncd hdmi2usb.ncd hdmi2usb.pcf \
        | $(COLORMAKETOOL); (exit $${PIPESTATUS[0]})

trce:
	@echo "========================================================="
	@echo "                        Trace                            "
	@echo "========================================================="
	@cd $(BUILD_DIR); \
	trce \
	-filter "../ise/iseconfig/filter.filter" \
	-intstyle $(INTSTYLE) \
	-v 3 \
	-s 3 \
	-n 3 \
	-fastpaths \
	-xml hdmi2usb.twx hdmi2usb.ncd \
	-o hdmi2usb.twr hdmi2usb.pcf \
        | $(COLORMAKETOOL); (exit $${PIPESTATUS[0]})

bit:
	@echo "========================================================="
	@echo "                        Bitgen                           "
	@echo "========================================================="
	@cd $(BUILD_DIR); \
	bitgen \
	-filter "../ise/iseconfig/filter.filter" \
	-intstyle $(INTSTYLE) \
	-f ../ise/hdmi2usb.ut hdmi2usb.ncd \
        | $(COLORMAKETOOL); (exit $${PIPESTATUS[0]})

xsvf:
	@echo "========================================================="
	@echo "                        xsvf file                        "
	@echo "========================================================="
	@cd $(BUILD_DIR); \
	impact -batch ../ucf/hdmi2usb.batch \
        | $(COLORMAKETOOL); (exit $${PIPESTATUS[0]})

clean:
	rm -R $(BUILD_DIR)

