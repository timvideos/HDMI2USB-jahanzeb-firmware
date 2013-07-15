# Synplicity, Inc. constraint file
# Written on Mon Jun 27 15:50:39 2005

define_attribute          {v:work.ddr2ram} syn_hier {hard}
define_attribute          {v:work.iodrp_controller} syn_hier {hard}
define_attribute          {v:work.iodrp_mcb_controller} syn_hier {hard}
define_attribute          {v:work.mcb_raw_wrapper} syn_hier {hard}
define_attribute          {v:work.mcb_soft_calibration} syn_hier {hard}
define_attribute          {v:work.mcb_soft_calibration_top} syn_hier {hard}
define_attribute          {v:work.memc3_infrastructure} syn_hier {hard}
define_attribute          {v:work.memc3_wrapper} syn_hier {hard}

# clock Constraints
define_clock -disable -name {memc3_infrastructure_inst} -period 3200 -clockgroup default_clkgroup_1
define_clock          -name {memc3_infrastructure_inst.SYS_CLK_INST} -period 3200 -clockgroup default_clkgroup_2
define_clock -disable -name {memc3_infrastructure_inst.u_pll_adv} -period 3200 -clockgroup default_clkgroup_3




