
#script to get input arguments
if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--project_name" { incr i; set project_name [lindex $::argv $i] }
      "--start_synth" { incr i; set start_synth [lindex $::argv $i] }
      "--dir" { incr i; set project_path [lindex $::argv $i] }
      "--pr_dir" { incr i; set pr_dir [lindex $::argv $i] }
      "--app_name" { incr i; set app_name [lindex $::argv $i] }
      "--pr_enable" { incr i; set pr_enable [lindex $::argv $i] }
      "--start_impl" { incr i; set start_impl [lindex $::argv $i] }
      "--num_jobs" { incr i; set num_jobs [lindex $::argv $i] }
      "--help"         { help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
} else {
  puts "ERROR: no arguments specified to make_shell.tcl"
  return 1
}


# assert project name exists
if { ! [info exists project_name] } {
    puts "Please specify a project name"
    return 1
}

#set default project path
if { ! [info exists project_path] } {
    set project_path prj_2019.1
}

#set project_path prj_2019.1

#set default starting pr 
if { ! [info exists pr_dir] } {
    set pr_dir apps 
}

if { ! [info exists start_synth] } {
  set start_synth 0
}

if { ! [info exists pr_enable] } {
  set pr_enable 0
}

if { ! [info exists start_impl] } {
  set start_impl 0
}

if { ! [info exists num_jobs] } {
  set num_jobs 12
}

set top_part xcu200-fsgd2104-2-e
#set pr_dir packet_loopback 

set top_dir .

create_project $project_name $project_path -part $top_part -force
set_property board_part xilinx.com:au200:part0:1.3 [current_project]
create_bd_design "phy_bd"
source $top_dir/tclscripts/phy_bd.tcl
make_wrapper -files [get_files $top_dir/$project_path/$project_name.srcs/sources_1/bd/phy_bd/phy_bd.bd] -top
add_files -norecurse $top_dir/$project_path/$project_name.srcs/sources_1/bd/phy_bd/hdl/phy_bd_wrapper.v
add_files -norecurse $top_dir/shell_solo_net_only/top_shell.sv 
add_files -norecurse $top_dir/shell_solo_net_only/interface_shell.sv
add_files -norecurse $top_dir/shell_solo_net_only/app_region.sv
add_files -norecurse $top_dir/shell_solo_net_only/alveo_u200/phy_shell_alveo_u200.sv
add_files -norecurse $top_dir/shell_solo_net_only/alveo_u200/phy_signals.svh
add_files -norecurse $top_dir/misc_rtl/axi_stream_fifo.sv
add_files -norecurse $top_dir/misc_rtl/reg_slice_full.sv
add_files -norecurse $top_dir/misc_rtl/reg_slice_full_light.sv



#add control_iso
add_files -norecurse $top_dir/ctrl_isolation/axi_lite_slave_decoupler.sv
add_files -norecurse $top_dir/ctrl_isolation/axi_lite_slave_verifier.sv
add_files -norecurse $top_dir/ctrl_isolation/ctrl_iso_reg_file.sv
add_files -norecurse $top_dir/ctrl_isolation/ctrl_iso_reg_file.sv
add_files -norecurse $top_dir/ctrl_isolation/ctrl_iso_top.sv



#add interfaces
add_files -norecurse $top_dir/interfaces/axil_intfc.sv

#add net_interfaces
add_files -norecurse $top_dir/net_isolation/axi_stream_master_decoupler.sv 
add_files -norecurse $top_dir/net_isolation/axi_stream_slave_verifier.sv 
add_files -norecurse $top_dir/net_isolation/net_iso_top.sv 
add_files -norecurse $top_dir/net_isolation/axi_stream_slave_decoupler.sv 
add_files -norecurse $top_dir/net_isolation/axi_stream_master_verifier.sv
add_files -norecurse $top_dir/net_isolation/net_iso_reg_file.v 
add_files -norecurse $top_dir/net_isolation/axi_stream_bw_shaper.sv



#add ip
add_files -norecurse $top_dir/shell_solo_net_only/xilinx_ip/axi_lite_clock_cross/axi_lite_clock_cross.xci
add_files -norecurse $top_dir/shell_solo_net_only/xilinx_ip/intfc_axi_lite_crossbar/intfc_axi_lite_crossbar.xci
add_files -norecurse $top_dir/shell_solo_net_only/xilinx_ip/two_clock_decouple/two_clock_decouple.xci

add_files -norecurse $top_dir/reset_decouple/clock_reset_decoupler_driver.h
add_files -norecurse $top_dir/reset_decouple/clock_reset_decouple_controller.sv

foreach source_file [glob $top_dir/$pr_dir/$app_name/*] {
    add_files -norecurse $source_file
}

set_property top top_shell [current_fileset]

if { $pr_enable != 0 } {
    set_property PR_FLOW 1 [current_project] 
    create_partition_def -name pr -module packet_loopback_app
    create_reconfig_module -name packet_loopback_app -partition_def [get_partition_defs pr ]  -define_from packet_loopback_app
    create_pr_configuration -name config_1 -partitions [list app_reg_inst/pr_inst:packet_loopback_app ]
    set_property PR_CONFIGURATION config_1 [get_runs impl_1]
    
    #set_property PR_FLOW 1 [current_project]
    #create_partition_def -name app_region -module app_region
    #create_reconfig_module -name $app_name -partition_def [get_partition_defs app_region ]  -define_from app_region
    #foreach source_file [glob $top_dir/$pr_dir/$app_name/*] {
    #    add_files -norecurse $source_file -of_objects [get_reconfig_modules $app_name]
    #}
    #foreach source_file [glob $top_dir/misc_rtl/*] {
    #    add_files -norecurse $source_file -of_objects [get_reconfig_modules $app_name]
    #}
    #add_files $top_dir/shell_solo_net_only/xilinx_ip/axi_lite_clock_cross_reconfig/axi_lite_clock_cross_reconfig.xci -of_objects [get_reconfig_modules $app_name]
    #add_files -norecurse $top_dir/shell_solo_net_only/app_region.sv  -of_objects [get_reconfig_modules $app_name]
    #create_pr_configuration -name config_1 -partitions [list app_reg_inst:$app_name ]
    #set_property PR_CONFIGURATION config_1 [get_runs impl_1]
}

if { $start_synth != 0 } {
    launch_runs synth_1 -jobs $num_jobs 
    wait_on_run synth_1
    if { $pr_enable != 0 } {
        open_run synth_1 -name synth_1
        startgroup
        create_pblock pblock_pr_inst
        resize_pblock pblock_pr_inst -add {SLICE_X35Y664:SLICE_X140Y832 DSP48E2_X5Y266:DSP48E2_X15Y331 RAMB18_X3Y266:RAMB18_X9Y331 RAMB36_X3Y133:RAMB36_X9Y165 URAM288_X0Y180:URAM288_X3Y219}
        add_cells_to_pblock pblock_pr_inst [get_cells [list app_reg_inst/pr_inst]] -clear_locs
        endgroup
        
        #create_pblock pblock_packet_loopback_app_inst
        #resize_pblock pblock_packet_loopback_app_inst -add {SLICE_X31Y665:SLICE_X142Y835 DSP48E2_X4Y266:DSP48E2_X16Y333 RAMB18_X3Y266:RAMB18_X9Y333 RAMB36_X3Y133:RAMB36_X9Y166 URAM288_X0Y180:URAM288_X3Y219}
        #resize_pblock pblock_app_reg_inst -add {SLICE_X31Y785:SLICE_X142Y835 DSP48E2_X4Y314:DSP48E2_X16Y333 RAMB18_X3Y314:RAMB18_X9Y333 RAMB36_X3Y157:RAMB36_X9Y166 URAM288_X0Y212:URAM288_X3Y219}
        #resize_pblock pblock_app_reg_inst -add {SLICE_X31Y675:SLICE_X140Y830 DSP48E2_X5Y270:DSP48E2_X15Y331 RAMB18_X3Y270:RAMB18_X9Y331 RAMB36_X3Y135:RAMB36_X9Y165 URAM288_X0Y180:URAM288_X3Y219}
        #add_cells_to_pblock pblock_packet_loopback_app_inst [get_cells [list packet_loopback_app_inst]] -clear_locs
        
        #save constraints for floorplan
        file mkdir $top_dir/$project_path/$project_name.srcs/constrs_1/new
        close [ open $top_dir/$project_path/$project_name.srcs/constrs_1/new/synth.xdc w  ]
        add_files -fileset constrs_1 $top_dir/$project_path/$project_name.srcs/constrs_1/new/synth.xdc
        set_property target_constrs_file $top_dir/$project_path/$project_name.srcs/constrs_1/new/synth.xdc [current_fileset -constrset]
        save_constraints -force
        close_design

        #rerun synth for placement
        reset_run synth_1
        launch_runs synth_1 -jobs $num_jobs
        wait_on_run synth_1
    }
}


if { $start_impl != 0 } {
    wait_on_run synth_1
    launch_runs impl_1 -to_step write_bitstream -jobs $num_jobs 
}

#remove_files  [get_files -of_objects [get_reconfig_modules $app_name] $top_dir/shell_solo_net_only/xilinx_ip/axi_lite_clock_cross_reconfig/axi_lite_clock_cross_reconfig.xci]

