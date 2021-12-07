set_false_path -from [get_clocks -of_objects [get_pins Drone_Cam_BD_inst/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0]] -to [get_clocks clk_fpga_2]
set_false_path -from [get_clocks clk_fpga_2] -to [get_clocks -of_objects [get_pins Drone_Cam_BD_inst/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins Drone_Cam_BD_inst/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT1]] -to [get_clocks clk_fpga_2]
set_false_path -from [get_clocks clk_fpga_2] -to [get_clocks -of_objects [get_pins Drone_Cam_BD_inst/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT1]]

create_pblock pblock_DDS_cont_0
add_cells_to_pblock [get_pblocks pblock_DDS_cont_0] [get_cells -quiet [list Drone_Cam_BD_inst/DDS_cont_0]]
resize_pblock [get_pblocks pblock_DDS_cont_0] -add {SLICE_X106Y50:SLICE_X113Y99}

set_property OFFCHIP_TERM NONE [get_ports je[8]]
create_pblock pblock_HDMIdebug_0
add_cells_to_pblock [get_pblocks pblock_HDMIdebug_0] [get_cells -quiet [list Drone_Cam_BD_inst/HDMIdebug_0]]
resize_pblock [get_pblocks pblock_HDMIdebug_0] -add {SLICE_X54Y75:SLICE_X67Y87}

set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
