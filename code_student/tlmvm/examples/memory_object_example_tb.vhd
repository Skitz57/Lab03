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
-- File        : memory_object_example_tb.vhd
-- Description : This package offers an example of how to use the memory_object
--               in order to serve as a reference for a real memory interface.
--
-- Author      : Yann Thoma
-- Team        : REDS institute
-- Date        : 09.03.16
--
--
--| Modifications |------------------------------------------------------------
-- Ver  Date      Who   Description
-- 1.0  09.03.16  YTA   First version
-- 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library tlmvm;
use tlmvm.memory_object_pkg;

-- Create a specialized package that will offer a memory with the specific
-- user type of data in it
package memory_specialized_pkg is new memory_object_pkg
  generic map (element_type => std_logic_vector(31 downto 0),
               ADDR_SIZE => 10);


library ieee;
use ieee.std_logic_1164.all;
use work.memory_specialized_pkg.all;


entity memory_object_example_tb is
end memory_object_example_tb;


architecture testbench of memory_object_example_tb is

	shared variable memory : work.memory_specialized_pkg.memory_type;
		
begin

	process is
		variable addr_sti : std_logic_vector(9 downto 0);
		variable data_sti : std_logic_vector(31 downto 0);
		variable data_get : std_logic_vector(31 downto 0);
	begin
	
		report "Starting simulation";
		addr_sti := (1=>'Z',others => '0');
		data_sti := (others => '1');
		memory.write(addr_sti, data_sti);
		data_get := memory.read(addr_sti);
		assert data_get = data_sti report "Erreur";

		addr_sti := (1=>'1',others => '0');
		data_sti := (others => '1');
		memory.write(addr_sti, data_sti);
		data_get := memory.read(addr_sti);
		assert data_get = data_sti report "Erreur";


		memory.set_verbosity(1);

		addr_sti := (2=>'1',others => '0');
		data_sti := (others => '1');
		memory.write(addr_sti, data_sti);
		data_get := memory.read(addr_sti);
		assert data_get = data_sti report "Erreur";

		report "Ending simulation";
		wait;
	end process;

end testbench;


