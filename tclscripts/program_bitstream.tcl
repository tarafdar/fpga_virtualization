#might not work if you have multiple differents kinds of devices in one server

open_hw
connect_hw_server

#loop through until we find correct fpga
foreach hw_targ [get_hw_targets] {
    set str "hw target: "
    append str $hw_targ
    puts $str
    
    open_hw_target $hw_targ
    set hw_dev [get_hw_devices ]
    if { $hw_dev=="xcu200_0"  } {
        set str "opening hw target: "
        append str $hw_targ
        puts $str
        break
    }
    close_hw_target $hw_targ
}

current_hw_device [get_hw_devices xcu200_0]
refresh_hw_device [lindex [get_hw_devices xcu200_0] 0]
set_property PROGRAM.FILE $bitstream [get_hw_devices xcu200_0]
program_hw_devices [get_hw_devices xcu200_0]
refresh_hw_device [lindex [get_hw_devices xcu200_0] 0]
