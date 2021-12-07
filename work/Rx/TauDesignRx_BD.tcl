
################################################################
# This is a generated script based on design: TauDesignRx_BD
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source TauDesignRx_BD_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# RxHDMI, RxMem, RxSyncPic

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg400-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name TauDesignRx_BD

# This script was generated for a remote BD. To create a non-remote design,
# change the variable <run_remote_bd_flow> to <0>.

set run_remote_bd_flow 1
if { $run_remote_bd_flow == 1 } {
  # Set the reference directory for source file relative paths (by default 
  # the value is script directory path)
  set origin_dir ./Rx

  # Use origin directory path location variable, if specified in the tcl shell
  if { [info exists ::origin_dir_loc] } {
     set origin_dir $::origin_dir_loc
  }

  set str_bd_folder [file normalize ${origin_dir}]
  set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

  # Check if remote design exists on disk
  if { [file exists $str_bd_filepath ] == 1 } {
     catch {common::send_msg_id "BD_TCL-110" "ERROR" "The remote BD file path <$str_bd_filepath> already exists!"}
     common::send_msg_id "BD_TCL-008" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0>."
     common::send_msg_id "BD_TCL-009" "INFO" "Also make sure there is no design <$design_name> existing in your current project."

     return 1
  }

  # Check if design exists in memory
  set list_existing_designs [get_bd_designs -quiet $design_name]
  if { $list_existing_designs ne "" } {
     catch {common::send_msg_id "BD_TCL-111" "ERROR" "The design <$design_name> already exists in this project! Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_msg_id "BD_TCL-010" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Check if design exists on disk within project
  set list_existing_designs [get_files -quiet */${design_name}.bd]
  if { $list_existing_designs ne "" } {
     catch {common::send_msg_id "BD_TCL-112" "ERROR" "The design <$design_name> already exists in this project at location:
    $list_existing_designs"}
     catch {common::send_msg_id "BD_TCL-113" "ERROR" "Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_msg_id "BD_TCL-011" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Now can create the remote BD
  # NOTE - usage of <-dir> will create <$str_bd_folder/$design_name/$design_name.bd>
  create_bd_design -dir $str_bd_folder $design_name
} else {

  # Create regular design
  if { [catch {create_bd_design $design_name} errmsg] } {
     common::send_msg_id "BD_TCL-012" "INFO" "Please set a different value to variable <design_name>."

     return 1
  }
}

current_bd_design $design_name

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:ila:6.2\
xilinx.com:ip:proc_sys_reset:5.0\
digilentinc.com:ip:rgb2dvi:1.4\
xilinx.com:ip:xlconstant:1.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
RxHDMI\
RxMem\
RxSyncPic\
"

   set list_mods_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_msg_id "BD_TCL-008" "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set CS_n_0 [ create_bd_port -dir I -from 3 -to 0 CS_n_0 ]
  set MISO_0 [ create_bd_port -dir O -from 3 -to 0 MISO_0 ]
  set MOSI_0 [ create_bd_port -dir I -from 3 -to 0 MOSI_0 ]
  set SCLK_0 [ create_bd_port -dir I -from 3 -to 0 SCLK_0 ]
  set TMDS_Clk_n_0 [ create_bd_port -dir O TMDS_Clk_n_0 ]
  set TMDS_Clk_p_0 [ create_bd_port -dir O TMDS_Clk_p_0 ]
  set TMDS_Data_n_0 [ create_bd_port -dir O -from 2 -to 0 TMDS_Data_n_0 ]
  set TMDS_Data_p_0 [ create_bd_port -dir O -from 2 -to 0 TMDS_Data_p_0 ]
  set sysclk [ create_bd_port -dir I -type clk sysclk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
 ] $sysclk

  # Create instance: RxHDMI_0, and set properties
  set block_name RxHDMI
  set block_cell_name RxHDMI_0
  if { [catch {set RxHDMI_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $RxHDMI_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: RxMem_0, and set properties
  set block_name RxMem
  set block_cell_name RxMem_0
  if { [catch {set RxMem_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $RxMem_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: RxSyncPic_0, and set properties
  set block_name RxSyncPic
  set block_cell_name RxSyncPic_0
  if { [catch {set RxSyncPic_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $RxSyncPic_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {143.688} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50} \
   CONFIG.CLKOUT2_JITTER {119.348} \
   CONFIG.CLKOUT2_PHASE_ERROR {96.948} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {20.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {8} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {2} \
   CONFIG.USE_RESET {false} \
 ] $clk_wiz_0

  # Create instance: ila_0, and set properties
  set ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_0 ]
  set_property -dict [ list \
   CONFIG.C_DATA_DEPTH {8192} \
   CONFIG.C_ENABLE_ILA_AXI_MON {false} \
   CONFIG.C_MONITOR_TYPE {Native} \
   CONFIG.C_NUM_OF_PROBES {4} \
   CONFIG.C_PROBE0_WIDTH {4} \
   CONFIG.C_PROBE1_WIDTH {4} \
   CONFIG.C_PROBE2_WIDTH {4} \
   CONFIG.C_PROBE3_WIDTH {4} \
 ] $ila_0

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: rgb2dvi_0, and set properties
  set rgb2dvi_0 [ create_bd_cell -type ip -vlnv digilentinc.com:ip:rgb2dvi:1.4 rgb2dvi_0 ]
  set_property -dict [ list \
   CONFIG.kGenerateSerialClk {false} \
   CONFIG.kRstActiveHigh {false} \
 ] $rgb2dvi_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {3} \
   CONFIG.CONST_WIDTH {2} \
 ] $xlconstant_0

  # Create port connections
  connect_bd_net -net CS_n_0_1 [get_bd_ports CS_n_0] [get_bd_pins RxMem_0/CS_n] [get_bd_pins ila_0/probe3]
  connect_bd_net -net MOSI_0_1 [get_bd_ports MOSI_0] [get_bd_pins RxMem_0/MOSI] [get_bd_pins ila_0/probe1]
  connect_bd_net -net RxHDMI_0_Mem_Read [get_bd_pins RxHDMI_0/Mem_Read] [get_bd_pins RxMem_0/HMemRead] [get_bd_pins RxSyncPic_0/HMemRead]
  connect_bd_net -net RxHDMI_0_Out_pData [get_bd_pins RxHDMI_0/Out_pData] [get_bd_pins rgb2dvi_0/vid_pData]
  connect_bd_net -net RxHDMI_0_Out_pHSync [get_bd_pins RxHDMI_0/Out_pHSync] [get_bd_pins rgb2dvi_0/vid_pVSync]
  connect_bd_net -net RxHDMI_0_Out_pVDE [get_bd_pins RxHDMI_0/Out_pVDE] [get_bd_pins RxMem_0/pVDE] [get_bd_pins RxSyncPic_0/pVDE] [get_bd_pins rgb2dvi_0/vid_pVDE]
  connect_bd_net -net RxHDMI_0_Out_pVSync [get_bd_pins RxHDMI_0/Out_pVSync] [get_bd_pins RxMem_0/HVsync] [get_bd_pins RxSyncPic_0/HVsync] [get_bd_pins rgb2dvi_0/vid_pHSync]
  connect_bd_net -net RxMem_0_HDMIdata [get_bd_pins RxHDMI_0/Mem_Data] [get_bd_pins RxMem_0/HDMIdata]
  connect_bd_net -net RxMem_0_MISO [get_bd_ports MISO_0] [get_bd_pins RxMem_0/MISO] [get_bd_pins ila_0/probe2]
  connect_bd_net -net RxSyncPic_0_PixelClk [get_bd_pins RxHDMI_0/clk] [get_bd_pins RxMem_0/PixelClk] [get_bd_pins rgb2dvi_0/PixelClk]
  connect_bd_net -net SCLK_0_1 [get_bd_ports SCLK_0] [get_bd_pins RxMem_0/SCLK] [get_bd_pins ila_0/probe0]
  connect_bd_net -net clk_wiz_0_clk_out2 [get_bd_pins RxMem_0/Cclk] [get_bd_pins RxSyncPic_0/clk] [get_bd_pins clk_wiz_0/clk_out2] [get_bd_pins ila_0/clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins rgb2dvi_0/SerialClk]
  connect_bd_net -net clk_wiz_0_locked [get_bd_pins clk_wiz_0/locked] [get_bd_pins proc_sys_reset_0/dcm_locked] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins RxHDMI_0/rstn] [get_bd_pins RxMem_0/rstn] [get_bd_pins RxSyncPic_0/rstn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins rgb2dvi_0/aRst_n]
  connect_bd_net -net rgb2dvi_0_TMDS_Clk_n [get_bd_ports TMDS_Clk_n_0] [get_bd_pins rgb2dvi_0/TMDS_Clk_n]
  connect_bd_net -net rgb2dvi_0_TMDS_Clk_p [get_bd_ports TMDS_Clk_p_0] [get_bd_pins rgb2dvi_0/TMDS_Clk_p]
  connect_bd_net -net rgb2dvi_0_TMDS_Data_n [get_bd_ports TMDS_Data_n_0] [get_bd_pins rgb2dvi_0/TMDS_Data_n]
  connect_bd_net -net rgb2dvi_0_TMDS_Data_p [get_bd_ports TMDS_Data_p_0] [get_bd_pins rgb2dvi_0/TMDS_Data_p]
  connect_bd_net -net sysclk_1 [get_bd_ports sysclk] [get_bd_pins clk_wiz_0/clk_in1]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins RxMem_0/FraimSel] [get_bd_pins xlconstant_0/dout]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


