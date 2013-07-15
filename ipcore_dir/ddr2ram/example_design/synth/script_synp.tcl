project -new 
add_file -vhdl "../rtl/example_top.vhd"
add_file -vhdl "../rtl/iodrp_controller.vhd"
add_file -vhdl "../rtl/iodrp_mcb_controller.vhd"
add_file -vhdl "../rtl/mcb_raw_wrapper.vhd"
add_file -vhdl "../rtl/mcb_soft_calibration.vhd"
add_file -vhdl "../rtl/mcb_soft_calibration_top.vhd"
add_file -vhdl "../rtl/memc3_infrastructure.vhd"
add_file -vhdl "../rtl/memc3_tb_top.vhd"
add_file -vhdl "../rtl/memc3_wrapper.vhd"
add_file -vhdl "../rtl/traffic_gen/afifo.vhd"
add_file -vhdl "../rtl/traffic_gen/cmd_gen.vhd"
add_file -vhdl "../rtl/traffic_gen/cmd_prbs_gen.vhd"
add_file -vhdl "../rtl/traffic_gen/data_prbs_gen.vhd"
add_file -vhdl "../rtl/traffic_gen/init_mem_pattern_ctr.vhd"
add_file -vhdl "../rtl/traffic_gen/mcb_flow_control.vhd"
add_file -vhdl "../rtl/traffic_gen/mcb_traffic_gen.vhd"
add_file -vhdl "../rtl/traffic_gen/rd_data_gen.vhd"
add_file -vhdl "../rtl/traffic_gen/read_data_path.vhd"
add_file -vhdl "../rtl/traffic_gen/read_posted_fifo.vhd"
add_file -vhdl "../rtl/traffic_gen/sp6_data_gen.vhd"
add_file -vhdl "../rtl/traffic_gen/tg_status.vhd"
add_file -vhdl "../rtl/traffic_gen/v6_data_gen.vhd"
add_file -vhdl "../rtl/traffic_gen/wr_data_gen.vhd"
add_file -vhdl "../rtl/traffic_gen/write_data_path.vhd"
add_file -constraint "../synth/mem_interface_top_synp.sdc"
impl -add rev_1
set_option -technology spartan6
set_option -part xc6slx45
set_option -package csg324
set_option -speed_grade -3
set_option -default_enum_encoding default
#AXI_ENABLE synp definition is not required for user_design
set_option -symbolic_fsm_compiler 1
set_option -resource_sharing 0
set_option -use_fsm_explorer 0
set_option -top_module "example_top"
set_option -frequency 312.5
set_option -fanout_limit 1000
set_option -disable_io_insertion 0
set_option -pipe 1
set_option -fixgatedclocks 0
set_option -retiming 0
set_option -modular 0
set_option -update_models_cp 0
set_option -verification_mode 0
set_option -write_verilog 0
set_option -write_vhdl 0
set_option -write_apr_constraint 0
project -result_file "../synth/rev_1/example_top.edf"
set_option -vlog_std v2001
set_option -auto_constrain_io 0
impl -active "../synth/rev_1"
project -run
project -save

