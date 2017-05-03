-------------------------------------------------------------------------------
--    Copyright 2016 HES-SO HEIG-VD REDS
--    All Rights Reserved Worldwide
--
--    Licensed under the Apache License, Version 2.0 (the "License");
--    you may not use this file except in compliance with the License.
--    You may obtain a copy of the License at
--
--        http://www.apache.org/licenses/LICENSE-2.0
--
--    Unless required by applicable law or agreed to in writing, software
--    distributed under the License is distributed on an "AS IS" BASIS,
--    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--    See the License for the specific language governing permissions and
--    limitations under the License.
-------------------------------------------------------------------------------
--
-- File        : memory_object_pkg.vhd
-- Description : This package offers the abstraction of a memory.
--               It exploits a protected type to offer write and read methods
--               and is generic for the size of the memory and the type of
--               data stored in it.
--               This package is generic, and requires a 2008 compiler.
--               Please have a look at memory_object_example_tb.vhd to see an
--               example of a correct use of this object.
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
context ieee.ieee_std_context;

package memory_object_pkg is
    
    generic (
        type        element_type;   -- Type of the element stored in the memory
        ADDR_SIZE : integer := 8    -- Size of the address bus
    );

    subtype verbosity_t is integer range 0 to 1;

    -- This type corresponds to the memory and will be elaborated based on the
    -- specialization of the generic package.
    -- Being protected, it can be used as a shared variable
    type memory_type is protected

        -- Writes a data in the memory at a specific address
        -- If the address is invalid (contains 'Z','U' or 'X') or if it is out of the
        -- memory range a warning is reported
        procedure write(addr: in std_logic_vector; data: element_type);

        -- Reads a data from the memory at a specific address
        -- If the address is invalid (contains 'Z','U' or 'X') or if it is out of the
        -- memory range a warning is reported
        impure function read(addr: in std_logic_vector) return element_type;

        -- Sets the verbosity of the object.
        -- When 0, no messages except the warnings
        procedure set_verbosity(verb: in verbosity_t);

    end protected memory_type;

end memory_object_pkg;

package body memory_object_pkg is
    
    type memory_type is protected body

        -- Type of the memory array used to store the data
        type memory_t is array(0 to 2**ADDR_SIZE-1) of element_type;

        -- The memory array used to store the data
        variable mem: memory_t;

        -- Verbosity tested to display or not messages
        variable verbosity : verbosity_t;

        -- Writes a data in the memory at a specific address
        -- If the address is invalid (contains 'Z','U' or 'X') or if it is out of the
        -- memory range a warning is reported
        procedure write(addr: in std_logic_vector; data: element_type) is
        begin
            if is_x(addr) then
                report "The address contains an unknown value: " & to_bstring(addr) severity warning;
                return;
            end if;
            if unsigned(addr) >= 2**ADDR_SIZE then
                report "The address is out of range: " & to_hstring(addr) &
                       "while the memory contains " & integer'image(2**ADDR_SIZE) &
                       " elements" severity warning;
                return;
            end if;
            if verbosity > 0 then
                report "Writing a value to the emulated memory";
            end if;
        	mem(to_integer(unsigned(addr))) := data;
        end write;

        -- Reads a data from the memory at a specific address
        -- If the address is invalid (contains 'Z','U' or 'X') or if it is out of the
        -- memory range a warning is reported
        impure function read(addr: in std_logic_vector) return element_type is
            variable element: element_type;
        begin
            if is_x(addr) then
                report "The address contains an unknown value: " & to_bstring(addr) severity warning;
                return element;
            end if;
            if unsigned(addr) >= 2**ADDR_SIZE then
                report "The address is out of range: " & to_hstring(addr) &
                       "while the memory contains " & integer'image(2**ADDR_SIZE) &
                       " elements" severity warning;
                return element;
            end if;
            if verbosity > 0 then
                report "Reading a value from the emulated memory";
            end if;
        	return mem(to_integer(unsigned(addr)));
        end read;

        -- Sets the verbosity of the object.
        -- When 0, no messages except the warnings
        procedure set_verbosity(verb: in verbosity_t) is
        begin
            verbosity := verb;
        end set_verbosity;

    end protected body memory_type;

end memory_object_pkg;

