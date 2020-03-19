
#script to get input arguments
if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--project_name" { incr i; set project_name [lindex $::argv $i] }
      "--dir" { incr i; set project_path [lindex $::argv $i] }
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

#set default project path
if { ! [info exists project_path] } {
    puts "Please enter project path"
    return 1
}

if { ! [info exists project_name] } {
    puts "Please specify a project name"
    return 1
}

set top_dir .

set bitstream $top_dir/$project_path/$project_name.runs/impl_1/top_shell.bit
source $top_dir/tclscripts/program_bitstream.tcl
