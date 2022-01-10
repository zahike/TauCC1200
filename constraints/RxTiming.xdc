#
set_false_path -from [get_clocks -of_objects [get_pins TauDesignRx_BD_inst/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins TauDesignRx_BD_inst/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins TauDesignRx_BD_inst/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins TauDesignRx_BD_inst/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0]]

set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
