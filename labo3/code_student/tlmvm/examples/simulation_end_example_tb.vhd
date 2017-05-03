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
context tlmvm.tlmvm_context;


entity simulation_end_example_tb is
end simulation_end_example_tb;


architecture testbench of simulation_end_example_tb is

 
	-- Clock period
	constant CLK_PERIOD : time := 10 ns;

	-- Clock signal
	signal clk_sti : std_logic;

	-- Reset signal
	signal rst_sti : std_logic;
	
	-- A potential output of a DUT
	signal an_output_o : std_logic := '0';
	
	signal an_output_obs : std_logic := '0';
	
	
	procedure cycle(number : integer := 1) is
	begin
		for i in 1 to number loop
			wait until falling_edge(clk_sti);
		end loop;
	end cycle;
		
  	procedure rep(finish_status: finish_status_t) is
  	begin
  		report "I finished, yepee";
  	end rep;

begin

	monitor: simulation_monitor
	generic map (drain_time => 50 ns,beat_time => 400 ns,final_reporting => rep);
	

	an_output_obs <= transport an_output_o after 100 ns;

	-- Generation of a clock, while there is at least an objection raised
--	clk_proc: process is
--	begin
--		clk_sti <= '0';
--		wait for CLK_PERIOD/2;
--		clk_sti <= '1';
--		wait for CLK_PERIOD/2;
--	end process;

	clk_proc : clock_generator(clk_sti, CLK_PERIOD);

	rst_proc : simple_startup_reset(rst_sti, 2*CLK_PERIOD);
	
	-- Stimuli process number 1
	sti1_proc: process is
	begin
	
		-- We define the drain time to stop 200 ns after the last objection 
		-- is dropped
		--set_drain_time(50 ns);
		
		for i in 1 to 2 loop
			-- We do not want to be interrupted
			raise_objection;

			-- Let's stimulate the design
			for c in 1 to 100 loop
				cycle(1);
				beat;
			end loop;
--			cycle(100);
			report "Stimulating the DUT. Number " & integer'image(i);
			an_output_o <= '1';
			cycle(1);
			an_output_o <= '0';
		
			-- OK, we are over with the stimulation from this process
			drop_objection;
			cycle(20);
		end loop;
		
		wait;
	end process;
	
	-- Stimuli process number 2
	sti2_proc: process is
	begin
		-- We do not want to be interrupted
		raise_objection;
		
		-- Let's stimulate the design
		cycle(10);
		
		-- OK, we are over with the stimulation from this process
		drop_objection;
		wait;
	end process;

	-- Verification process
	-- Here, the idea is to raise an objection when we start to verify a
	-- coherent output on multiple clock cycles, and to drop it when this
	-- verification is done
	verif_proc: process is
		variable check_number : integer := 0;
	begin
		--set_beattime(400 ns);
		while (true) loop
			-- Wait for a transaction, or something to check
			wait on clk_sti until an_output_obs = '1';
			
			-- We do not want to be interrupted during the checking
			raise_objection;
			
			check_number := check_number + 1;
			
			report "Checking the DUT output. Number " & integer'image(check_number);
			-- Some processing with the output, maybe on a couple of clock
			-- cycles
			cycle(5);
			
			-- OK, we are over with this verification, let's allow the
			-- simulation to end if no more stimuli are available
			drop_objection;
			
			-- Or, something went terribly wrong:
			if (false) then
				drop_all_objections;
			end if;
		end loop;
	end process;

end testbench;


