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
-- File        : heartbeat_env_pkg.vhd
-- Description : This package offers the concept of heart beat, as proposed in
--               SystemVerilog within the UVM methodology.
--               A heart beat is used to detect if nothing happens during
--               a simulation. Some modules have to tell the system they are
--               alive, and if noone is, then the simulation could stop.
--               The heartbeat object is declared in heartbeat_pkg.vhd, this
--               package only offers the concept of a single heartbeat to
--               be shared throughout the testbench via procedures and
--               functions.
--               Please have a look at heartbeat_example_tb.vhd to see an
--               example of a correct use of heart beats.
--
-- Author      : Yann Thoma
-- Team        : REDS institute
-- Date        : 22.10.15
--
--
--| Modifications |------------------------------------------------------------
-- Ver  Date      Who   Description
-- 1.0  22.10.15  YTA   First version
-- 
-------------------------------------------------------------------------------

library tlmvm;
use tlmvm.heartbeat_pkg.all;

package heartbeat_env_pkg is

    -- This procedure should be called to tell the system that a component is
    -- still alive.
    procedure beat;

    -- This procedure allows to set the beat time, i.e. the interval in which
    -- there should be at least one call to the beat procedure in order not
    -- to stop the simulation.
    procedure set_beattime(t: in time);

    -- Returns the beat time that was set by the user
    impure function get_beattime return time;


    -- Returns true if there hasn't been a beat during the last
    -- beat time interval.
    impure function heartbeat_end_of_simulation return boolean;
    
end heartbeat_env_pkg;

package body heartbeat_env_pkg is

	-- singleton heartbeat
    shared variable single_heartbeat : heartbeat_type;

    procedure beat is
    begin
        single_heartbeat.beat;
    end beat;

    procedure set_beattime(t: in time) is
    begin
        single_heartbeat.set_beattime(t);
    end set_beattime;

    impure function get_beattime return time is
    begin
        return single_heartbeat.get_beattime;
    end get_beattime;

    impure function heartbeat_end_of_simulation return boolean is
    begin
        return single_heartbeat.end_of_simulation;
    end heartbeat_end_of_simulation;

end heartbeat_env_pkg;
