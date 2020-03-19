
#script to get input arguments
if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--project_name" { incr i; set project_name [lindex $::argv $i] }
      "--dir" { incr i; set project_path [lindex $::argv $i] }
      "--pr_dir" { incr i; set pr_dir [lindex $::argv $i] }
      "--app_name" { incr i; set app_name [lindex $::argv $i] }
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

if { ! [info exists app_name] } {
    puts "Please specify an app name"
    return 1
}
set top_part xcu200-fsgd2104-2-e
#set pr_dir packet_loopback 

set top_dir .


open_project $top_dir/$project_path/$project_name.xpr


source $top_dir/tclscripts/reconfig_region.tcl
