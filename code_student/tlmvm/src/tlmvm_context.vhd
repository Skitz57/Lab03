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
-- File        : tlmvm_context.vhd
-- Description : This context offers all the packages and components of the
--               tlmvm library. It can be used instead of importing each
--               specific package when required.
--
-- Author      : Yann Thoma
-- Team        : REDS institute
-- Date        : 04.11.15
--
--
--| Modifications |------------------------------------------------------------
-- Ver  Date      Who   Description
-- 1.0  04.11.15  YTA   First version
-- 
-------------------------------------------------------------------------------

-- This context should be compiled into library tlmvm
context tlmvm_context is
	library tlmvm;
    use tlmvm.heartbeat_pkg.all;
    use tlmvm.heartbeat_env_pkg.all;
    use tlmvm.objection_pkg.all;
    use tlmvm.objection_env_pkg.all;
    use tlmvm.simulation_end_pkg.all;
    use tlmvm.tlm_fifo_pkg;
    use tlmvm.tlm_unbounded_fifo_pkg;
end context;
