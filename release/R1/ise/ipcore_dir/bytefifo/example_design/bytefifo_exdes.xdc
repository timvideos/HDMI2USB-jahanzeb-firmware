################################################################################
# (c) Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.
# 
# This file contains confidential and proprietary information
# of Xilinx, Inc. and is protected under U.S. and
# international copyright and other intellectual property
# laws.
# 
# DISCLAIMER
# This disclaimer is not a license and does not grant any
# rights to the materials distributed herewith. Except as
# otherwise provided in a valid license issued to you by
# Xilinx, and to the maximum extent permitted by applicable
# law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
# WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
# AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
# BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
# INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
# (2) Xilinx shall not be liable (whether in contract or tort,
# including negligence, or under any other theory of
# liability) for any loss or damage of any kind or nature
# related to, arising under or in connection with these
# materials, including for any direct, or any indirect,
# special, incidental, or consequential loss or damage
# (including loss of data, profits, goodwill, or any type of
# loss or damage suffered as a result of any action brought
# by a third party) even if such damage or loss was
# reasonably foreseeable or Xilinx had been advised of the
# possibility of the same.
# 
# CRITICAL APPLICATIONS
# Xilinx products are not designed or intended to be fail-
# safe, or for use in any application requiring fail-safe
# performance, such as life-support or safety devices or
# systems, Class III medical devices, nuclear facilities,
# applications related to the deployment of airbags, or any
# other applications that could lead to death, personal
# injury, or severe property or environmental damage
# (individually and collectively, "Critical
# Applications"). Customer assumes the sole risk and
# liability of any use of Xilinx products in Critical
# Applications, subject only to applicable laws and
# regulations governing limitations on product liability.
# 
# THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
# PART OF THIS FILE AT ALL TIMES.
#
################################################################################

# Core Period Constraint. This constraint can be modified, and is
# valid as long as it is met after place and route.
create_clock -name "TS_RD_CLK" -period 1000.0 [ get_ports RD_CLK ]
create_clock -name "TS_WR_CLK" -period 1000.0 [ get_ports WR_CLK ]
  
# Following are the constrains for Fifo Generator to eleminate setup/hold violation warnings in simulations
# This example is using the Set False Path constrains we can also make use of the Max Delay constrains, 
# to use them just un-comment them and comment the False Path constrains

##set wr_q_nets [get_nets -hier -filter { NAME =~ */xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_q?0?* }]
set wr_q_cell [get_cells -hier -filter { NAME =~ */xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_? }]
  
##set rd_q_nets [get_nets -hier -filter { NAME =~ */xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_q?0?* }]
set rd_q_cell [get_cells -hier -filter { NAME =~ */xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_? }]

set_false_path -from $rd_q_cell -through $rd_q_cell -to $rd_q_cell
set_false_path -from $wr_q_cell -through $wr_q_cell -to $wr_q_cell

##set_max_delay -through $wr_q_nets -datapath_only 2000.0##set_max_delay -through $rd_q_nets -datapath_only 2000.0################################################################################
