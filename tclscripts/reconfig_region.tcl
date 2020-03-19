
create_reconfig_module -name $app_name -partition_def [get_partition_defs pr ]  -top $app_name 
#foreach source_file [glob $top_dir/misc_rtl/*] {
#    add_files -norecurse $source_file -of_objects [get_reconfig_modules $app_name]
#}
foreach source_file [glob $top_dir/$pr_dir/$app_name/*] {
    add_files -norecurse $source_file -of_objects [get_reconfig_modules $app_name]
}
create_pr_configuration -name config_$app_name -partitions [list app_reg_inst/pr_inst:$app_name ]
create_run impl_$app_name -parent_run impl_1 -flow {Vivado Implementation 2019} -pr_config config_$app_name

set run_name $app_name
append run_name "_synth_1"

launch_runs $run_name -jobs 12
wait_on_run $run_name

launch_runs impl_$app_name -to_step write_bitstream -jobs 12
wait_on_run impl_$app_name

#create_reconfig_module -name packet_loopback_1 -partition_def [get_partition_defs pr ]  -top packet_loopback
#add_files -norecurse /home/tarafdar/workDir/fpga_virtualization/apps/packet_loopback_1/packet_ctrl_fifo.sv /home/tarafdar/workDir/fpga_virtualization/apps/packet_loopback_1/packet_loopback_app.v /home/tarafdar/workDir/fpga_virtualization/misc_rtl/axi_stream_fifo.sv  -of_objects [get_reconfig_modules packet_loopback_1]
#create_pr_configuration -name config_packet_loopback_1 -partitions [list app_reg_inst/packet_loopback_inst:packet_loopback_1 ]
#create_run impl_packet_loopback_1 -parent_run impl_1 -flow {Vivado Implementation 2019} -pr_config config_packet_loopback_1

#create_reconfig_module -name $app_name -partition_def [get_partition_defs app_region ]  -top app_region
#foreach source_file [glob $top_dir/$pr_dir/$app_name/*] {
#    add_files -norecurse $source_file -of_objects [get_reconfig_modules $app_name]
#}
#foreach source_file [glob $top_dir/misc_rtl/*] {
#    add_files -norecurse $source_file -of_objects [get_reconfig_modules $app_name]
#}
#add_files $top_dir/shell_solo_net_only/xilinx_ip/axi_lite_clock_cross_reconfig/axi_lite_clock_cross_reconfig.xci -of_objects [get_reconfig_modules $app_name]
#add_files -norecurse $top_dir/shell_solo_net_only/app_region.sv  -of_objects [get_reconfig_modules $app_name]
#create_pr_configuration -name config_$app_name -partitions [list app_reg_inst:$app_name ]
#create_run impl_$app_name -parent_run impl_1 -flow {Vivado Implementation 2019} -pr_config config_$app_name
#
#update_compile_order -fileset $app_name 
