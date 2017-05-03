#!/usr/bin/tclsh

# Main proc at the end #

proc tlmvm_compil { } {

  set currentDir [pwd]

  cd ../tlmvm/comp
  do ../scripts/compile.do
  cd $currentDir

  vmap tlmvm ../tlmvm/comp/tlmvm
}

#------------------------------------------------------------------------------
proc vhdl_compil { } {
  global Path_VHDL
  global Path_TB
  puts "\nVHDL compilation :"

  vcom -2008 $Path_VHDL/math_computer_pkg.vhd
  vcom -2008 $Path_VHDL/math_computer_control.vhd
  vcom -2008 $Path_VHDL/math_computer_datapath.vhd
  vcom -2008 $Path_VHDL/math_computer.vhd
  vcom -2008 $Path_TB/random_pkg.vhd
  vcom -2008 $Path_TB/math_computer_verif_pkg.vhd
  vcom -2008 $Path_TB/math_computer_tb.vhd
}

#------------------------------------------------------------------------------
proc sim_start { } {

  vsim -t 1ns -novopt -GDATASIZE=8 work.math_computer_tb
#  do wave.do
  add wave -r *
  wave refresh
  run -all
}

#------------------------------------------------------------------------------
proc do_all { } {
  vhdl_compil
  sim_start
}

## MAIN #######################################################################

# Compile folder ----------------------------------------------------
if {[file exists work] == 0} {
  vlib work
}

# tlmvm_compil

puts -nonewline "  Path_VHDL => "
set Path_VHDL     "../src_vhdl"
set Path_TB       "../src_tb"

global Path_VHDL
global Path_TB

# start of sequence -------------------------------------------------

if {$argc==1} {
  if {[string compare $1 "all"] == 0} {
    do_all
  } elseif {[string compare $1 "comp_vhdl"] == 0} {
    vhdl_compil
  } elseif {[string compare $1 "sim"] == 0} {
    sim_start
  }

} else {
  do_all
}
