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
-- File        : objection_env_pkg.vhd
-- Description : This package offers the concept of objections, as proposed in
--               SystemVerilog within the UVM methodology.
--               Their purpose is to easily stop a simulation when no more
--               process needs to be executed, and is particularly suitable
--               for multi-process testbenches, where the simulation should
--               stop only when all stimuli and verification processes have
--               finished.
--               The objection object is defined in objection_pkg.vhd, the
--               current package offering a single objection that can be
--               accessed via procedure calls throughout the testbench.
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
-- 1.0  01.11.15  YTA   First version
-- 
-------------------------------------------------------------------------------

library tlmvm;
use tlmvm.objection_pkg.all;

package objection_env_pkg is
    
    -- The following subprograms access a single objection object, and so
    -- can be used by the entire testbench, without the need of declaring an
    -- objection object. Basically they are offered for convenience.
    
    -- Raises an objection on the singleton
    procedure raise_objection(nb_obj: integer := 1);
    
    -- Drops an objection on the singleton
    procedure drop_objection(nb_obj: integer := 1);
    
    -- Drops all objections on the singleton
    procedure drop_all_objections;

    -- Indicates if all objections have been dropped on the singleton
    impure function no_objection return boolean;

    -- Sets the drain time
    procedure set_drain_time(new_drain_time : time := 0 ns);

    -- Gets the drain time
    impure function get_drain_time return time;
        
    -- Returns true if the simulation should stop.
    -- This is the case when there is no objection for at least a time
    -- corresponding to drain_time
    impure function objections_end_of_simulation return boolean;
        
end objection_env_pkg;

use work.heartbeat_pkg.all;

package body objection_env_pkg is

    -- This private singleton allows to directly use the subprograms
    -- without the need of declaring a shared objection. This objection
    -- will be shared by the entire simulation
    shared variable single_objection : objection_type;

    
    procedure raise_objection(nb_obj: integer := 1) is
    begin
        single_objection.raise_objection(nb_obj);
    end raise_objection;
    
    procedure drop_objection(nb_obj: integer := 1) is
    begin
        single_objection.drop_objection(nb_obj);
    end drop_objection;
    
    procedure drop_all_objections is
    begin
        single_objection.drop_all_objections;
    end drop_all_objections;

    impure function no_objection return boolean is
    begin
        return single_objection.no_objection;
    end no_objection;
        
    procedure set_drain_time(new_drain_time : time := 0 ns) is
    begin
        single_objection.set_drain_time(new_drain_time);
    end set_drain_time;

    impure function get_drain_time return time is
    begin
        return single_objection.get_drain_time;
    end get_drain_time;
    
    impure function objections_end_of_simulation return boolean is
    begin
        return single_objection.end_of_simulation;
    end objections_end_of_simulation;

end objection_env_pkg;
