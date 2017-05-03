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
#- File        : compile.do
#- Description : This file allows to compile the library files,
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

proc compvcom {fileName {lib tlmvm}} {

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

proc main {} {

	# Create the library
	vlib tlmvm

	compvcom ../src/heartbeat_pkg.vhd 
	compvcom ../src/heartbeat_env_pkg.vhd 
	compvcom ../src/objection_pkg.vhd
	compvcom ../src/objection_env_pkg.vhd
	compvcom ../src/simulation_end_pkg.vhd
	compvcom ../src/tlm_fifo_pkg.vhd
	compvcom ../src/tlm_unbounded_fifo_pkg.vhd
	compvcom ../src/tlm_fifo_array_pkg.vhd
	compvcom ../src/tlm_unbounded_fifo_array_pkg.vhd
	compvcom ../src/memory_object_pkg.vhd
	compvcom ../src/tlmvm_context.vhd

}



main

if {$shouldExit} {
	quit -code 0
}

