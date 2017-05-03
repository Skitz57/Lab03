-------------------------------------------------------------------------------
--    Copyright 2015 HES-SO HEIG-VD REDS
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
-- File        : objection_pkg.vhd
-- Description : This package offers the concept of objections, as proposed in
--               SystemVerilog within the UVM methodology.
--               Their purpose is to easily stop a simulation when no more
--               process needs to be executed, and is particularly suitable
--               for multi-process testbenches, where the simulation should
--               stop only when all stimuli and verification processes have
--               finished.
--               Please have a look at objections_example_tb.vhd to see an
--               example of a correct use of objections.
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

package objection_pkg is

    -- This type corresponds to an objection manager. It offers 4 functions
    -- to raise, drop, and check the objections.
    type objection_type is protected
    
        -- Raises a number of objections (default: 1)
        procedure raise_objection(nb_obj: integer := 1);
        
        -- Drops a number of objections (default: 1)
        procedure drop_objection(nb_obj: integer := 1);
        
        -- Drops all objections
        procedure drop_all_objections;
        
        -- Returns true if there is no more objection raised
        impure function no_objection return boolean;    
        
        -- Sets the drain time
        procedure set_drain_time(new_drain_time : time := 0 ns);

        -- Gets the drain time
        impure function get_drain_time return time;

        -- Returns true if the simulation should stop.
        -- This is the case when there is no objection for at least a time
        -- corresponding to drain_time
        impure function end_of_simulation return boolean;
        
    end protected objection_type;
            
end objection_pkg;

library tlmvm;
use tlmvm.heartbeat_env_pkg.all;

package body objection_pkg is

    type objection_type is protected body
    
        -- Number of objections raised
        variable nb_objections : integer := 0;
        
        -- The time at which the last objection was dropped
        variable dropping_time : time := 0 ns;
        
        -- Drain time to wait for after the last objection was dropped
        variable drain_time : time := 0 ns;

        procedure raise_objection(nb_obj: integer := 1) is
        begin
            nb_objections := nb_objections + nb_obj;
            beat;
        end raise_objection;
    
        procedure drop_objection(nb_obj: integer := 1) is
        begin
            nb_objections := nb_objections - nb_obj;
            if (nb_objections = 0) then
                dropping_time := now;
            end if;
            beat;
        end drop_objection;
    
        procedure drop_all_objections is
        begin
            if (nb_objections > 0) then
                nb_objections := 0;
                dropping_time := now;
            end if;
            beat;
        end drop_all_objections;

        impure function no_objection return boolean is
        begin
            return nb_objections <= 0;
        end no_objection;

        procedure set_drain_time(new_drain_time : time := 0 ns) is
        begin
            drain_time := new_drain_time;
        end set_drain_time;
        
        impure function get_drain_time return time is
        begin
            return drain_time;
        end get_drain_time;

        impure function end_of_simulation return boolean is
        begin
            return no_objection and (now - dropping_time > drain_time);
        end end_of_simulation;
        
    end protected body objection_type;

end objection_pkg;
