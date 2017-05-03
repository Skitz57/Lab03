#------------------------------------------------------------------------------
#-	Copyright 2015 HES-SO HEIG-VD REDS
#-	All Rights Reserved Worldwide
#-
#-	Licensed under the Apache License, Version 2.0 (the "License");
#-	you may not use this file except in compliance with the License.
#-	You may obtain a copy of the License at
#-
#-		http://www.apache.org/licenses/LICENSE-2.0
#-
#-	Unless required by applicable law or agreed to in writing, software
#-	distributed under the License is distributed on an "AS IS" BASIS,
#-	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#-	See the License for the specific language governing permissions and
#-	limitations under the License.
#
#- File        : sim.do
#- Description : This file allows to compile the files and start a simulation,
#-               using Questasim or Modelsim
#-
#- Author      : Yann Thoma
#- Team        : REDS institute
#- Date        : 10.02.16
#------------------------------------------------------------------------------

global shouldExit

set shouldExit 0

if {$argc==1} {
  if {[string compare $1 "auto"] == 0} {
	set shouldExit 1
}
}

puts "Should exit $shouldExit\n"

proc intexit {value} {
	global shouldExit
	if {$shouldExit == 1} {
		quit -code $value
	} else {
		return 1
	}
}

proc compvcom {fileName {lib work}} {

	global shouldExit
	set result [catch {vcom -2008 -work $lib $fileName}]
	if { $result != 0} {
		if {$shouldExit == 1} {
			quit -code $result
		} else {
			# Do it again. It will cause the script to stop
			vcom -quiet -2008 -work $lib $fileName
		}
	}
	return $result
}

proc do_example {entityName} {
	compvcom ../examples/$entityName.vhd
	vsim -novopt work.$entityName
    run -all
}

proc main {} {

	# Create the library
	vlib work

#	do_example memory_object_example_tb
	do_example tlm_fifo_array_objections_example_tb
	do_example simulation_end_example_tb
	do_example heartbeat_example_tb
	do_example objections_example_tb
	do_example objections_no_heartbeat_example_tb
	do_example tlm_fifo_no_objection_example_tb
	do_example tlm_fifo_objections_example_tb

}


#	do_example memory_object_example_tb

main

if {$shouldExit} {
	quit -code 0
}

