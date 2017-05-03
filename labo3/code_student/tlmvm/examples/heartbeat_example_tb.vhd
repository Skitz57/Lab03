-------------------------------------------------------------------------------
--	Copyright 2015 HES-SO HEIG-VD REDS
--	All Rights Reserved Worldwide
--
--	Licensed under the Apache License, Version 2.0 (the "License");
--	you may not use this file except in compliance with the License.
--	You may obtain a copy of the License at
--
--		http://www.apache.org/licenses/LICENSE-2.0
--
--	Unless required by applicable law or agreed to in writing, software
--	distributed under the License is distributed on an "AS IS" BASIS,
--	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--	See the License for the specific language governing permissions and
--	limitations under the License.
-------------------------------------------------------------------------------
--
-- File        : objections_example_tb.vhd
-- Description : This package offers an example of how to use objections in
--               order to automatically end up the simulation. It uses the
--               functions declared in objection_pkg.vhd.
--               This fake testbench is composed of two processes generating
--               stimuli, and a process performing verification.
--               The simulation will stop when all stimuli processes have
--               finished, and that there is no verification under way.
--               The goal is to stop the clock in order to stop the simulation.
--
-- Author      : Yann Thoma
-- Team        : REDS institute
-- Date        : 22.05.13
--
--
--| Modifications |------------------------------------------------------------
-- Ver  Date      Who   Description
-- 1.0  22.05.13  YTA   First version
-- 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library tlmvm;
--use tlmvm.heartbeat_env_pkg.all;
context tlmvm.tlmvm_context;

entity heartbeat_example_tb is
end heartbeat_example_tb;


architecture testbench of heartbeat_example_tb is

	-- Clock period
	constant CLK_PERIOD : time := 10 ns;

	-- Clock signal
	signal clk_sti : std_logic;
	
	-- A potential output of a DUT
	signal an_output_o : std_logic := '0';
	
	
begin

	-- Generation of a clock, while there is at least an objection raised
	clk_proc: process is
	begin
		clk_sti <= '0';
		wait for CLK_PERIOD/2;
		clk_sti <= '1';
		wait for CLK_PERIOD/2;
		if heartbeat_end_of_simulation then
			report "The testbench seems to be stuck somewhere, nothing is happening";
			wait;
		end if;
	end process;
	
	-- Stimuli process number 1
	sti1_proc: process is
	begin
		for i in 0 to 9 loop
			-- Let's stimulate the design
			beat;
			wait until rising_edge(clk_sti);
			an_output_o <= '1';
		end loop;
		wait;
	end process;
	
	-- Verification process
	-- Here, the idea is to raise an objection when we start to verify a
	-- coherent output on multiple clock cycles, and to drop it when this
	-- verification is done
	verif_proc: process is
	begin
		set_beattime(300 ns);
		while (true) loop
			-- Wait for a transaction, or something to check
			wait on clk_sti until an_output_o = '1';

			--beat;
			
			-- Some processing with the output, maybe on a couple of clock
			-- cycles
			wait for 100 ns;
			
		end loop;
	end process;

end testbench;


