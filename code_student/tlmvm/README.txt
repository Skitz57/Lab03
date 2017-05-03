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

The TLMVM library offers some mechanisms to help designing a VHDL testbench.
To compile the library, create a folder called comp in the tlmvm folder.
Then from this folder run:
	vsim -c -do ../scripts/compile.do

Then to simulate the examples, run:
	vsim -do ../scripts/sim_examples.do