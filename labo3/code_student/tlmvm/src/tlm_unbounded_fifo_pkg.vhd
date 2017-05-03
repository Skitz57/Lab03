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
-- File        : tlm_unbounbed_fifo_pkg.vhd
-- Description : This package offers the concept of TLM FIFOs.
--               Transaction Level Modeling is widely used with languages such
--               as SystemC or SystemVerilog, but VHDL does not offer these
--               kinds of onstructs. So this package consists in a 
--               protected FIFO type allowing to share asynchronous
--               transactions between processes. These FIFOs use pointers in
--               order to be virtually unbounded.
--               There is possibility to raise an objection when the FIFO is
--               not empty.
--               This package is generic, and requires a 2008 compiler.
--               Please have a look at tlm_example_tb.vhd to see an
--               example of a correct use of these FIFOs.
--
-- Author      : Yann Thoma
-- Team        : REDS institute
-- Date        : 04.11.15
--
--
--| Modifications |------------------------------------------------------------
-- Ver  Date      Who   Description
-- 1.0  05.06.13  YTA   First version
-- 1.1  04.11.15  YTA   Added the blocking procedures
-- 
-------------------------------------------------------------------------------


package tlm_unbounded_fifo_pkg is
    
    generic (
        type             element_type;     -- Type of the element stored into the FIFOs
        nb_max_data    : integer := -1;    -- Maximum number of element stored.
                                           -- -1 means a virtually infinite number.
        use_objections : boolean := false; -- raises objections when not empty
        retry_delta    : time := 1 ns      -- time between two trials in blocking methods
    );

    -- This type corresponds to the FIFO and will be elaborated based on the
    -- specialization of the generic package.
    -- Being protected, it can be used as a shared variable
    type tlm_fifo_type is protected

        -- Puts a data into the FIFO.
        -- The second parameter is modified and indicates if there was enough
        -- space to store the data (true) or not (false). So basically if
        -- the FIFO is full, then ok will be false.
        procedure put(data: element_type;ok: out boolean);

        -- Gets a data from the FIFO.
        -- The second parameter is modified and indicates if there was data
        -- in the FIFO (true) or not (false).
        procedure get(data: out element_type;ok: out boolean);

        -- Indicates if the FIFO is empty
        impure function is_empty return boolean;

        -- Indicates if the FIFO is full
        impure function is_full return boolean;

        -- Returns the number of data available in the FIFO
        impure function nb_data_available return integer;

    end protected tlm_fifo_type;

    -- Puts a data to a FIFO.
    -- This procedure will block until there is space in the FIFO.
    -- The procedure will periodically try to put data, the period being
    -- defined by the generic parameter retry_delta.
    procedure blocking_put(fifo: inout tlm_fifo_type;
                           data : element_type);

    -- Gets a data from a FIFO.
    -- This procedure will block until there is space in the FIFO.
    -- The procedure will periodically try to put data, the period being
    -- defined by the generic parameter retry_delta.
    procedure blocking_get(fifo : inout tlm_fifo_type ;
                           data : out element_type);

    -- Puts a data to a FIFO.
    -- This procedure will block until there is space in the FIFO.
    -- The procedure will periodically try to put data, the period being
    -- defined by the generic parameter retry_delta.
    -- The procedure will return after a certain timeout if the insertion
    -- has not been successful.
    -- The last parameter is modified and indicates if there was enough
    -- space to store the data (true) or not (false). So basically if
    -- the FIFO is full and the timeout was reached, then ok will be false.
    procedure blocking_timeout_put(fifo          : inout tlm_fifo_type;
                                   data          : element_type;
                                   timeout       : time;
                                   ok            : out boolean);

    -- Gets a data from a FIFO.
    -- This procedure will block until there is space in the FIFO.
    -- The procedure will periodically try to put data, the period being
    -- defined by the generic parameter retry_delta.
    -- The procedure will return after a certain timeout if no data is
    -- available.
    -- The last parameter is modified and indicates if there was data
    -- in the FIFO (true) or not (false).
    procedure blocking_timeout_get(fifo          : inout tlm_fifo_type;
                                   data          : out element_type;
                                   timeout       : time;
                                   ok            : out boolean);
    
end tlm_unbounded_fifo_pkg;

library tlmvm;
use tlmvm.objection_env_pkg.all;

package body tlm_unbounded_fifo_pkg is
    
    type tlm_fifo_type is protected body

        -- A node corresponds to a node in a linked list.
        -- It is used to create the virtually unbounded FIFO by dynamically
        -- creating nodes during puts.
        type node;
        type node_pointer is access node;
        type node is
        record
            next_node: node_pointer;
            value : element_type;
        end record node;

        -- Number of data in the FIFO
        variable nb_data: integer := 0;

        -- Pointer to the first element in the linked list
        variable first: node_pointer := NULL;

        -- Pointer to the last element in the linked list
        variable last : node_pointer := NULL;


        -- Indicates if the FIFO is empty
        impure function is_empty return boolean is
        begin
            return nb_data = 0;
        end is_empty;

        -- Indicates if the FIFO is full
        impure function is_full return boolean is
        begin
            return false;
        end is_full;

        -- Returns the number of data available in the FIFO
        impure function nb_data_available return integer is
        begin
            return nb_data;
        end nb_data_available;


        -- Puts a data into the FIFO.
        -- The second parameter is modified and indicates if there was enough
        -- space to store the data (true) or not (false). So basically if
        -- the FIFO is full, then ok will be false.
        procedure put(data: element_type;ok: out boolean) is
            variable new_node : node_pointer;
        begin
            if ((nb_max_data/=-1) and (nb_data = nb_max_data)) then
                -- The FIFO is bounded, so let's consider this
                ok:=false;
                return;
            end if;
            new_node := new node;
            if (new_node = NULL) then
                -- Error at the node creation. Obviously memory troubles for
                -- the computer
                ok := false;
            else
                new_node.value := data;
                -- Update of the linked list
                if (nb_data = 0)  then
                    first := new_node;
                    last := new_node;
                else
                    last.next_node := new_node;
                    last := new_node;
                end if;
                nb_data := nb_data + 1;
                ok := true;
                if use_objections then
	                raise_objection;
	            end if;
            end if;
        end put;

        -- Gets a data from the FIFO.
        -- The second parameter is modified and indicates if there was data
        -- in the FIFO (true) or not (false).
        
        procedure get(data: out element_type;ok: out boolean) is
            variable tmp_pointer : node_pointer;
        begin
            if (nb_data <= 0) then
                -- Obviously no data in the FIFO
                ok := false;
            else
                data := first.value;
                nb_data := nb_data - 1;
                -- Update of the linked list
                tmp_pointer := first;
                if (nb_data = 0) then
                    first := NULL;
                    last := NULL;
                else
                    first := first.next_node;
                end if;
                if use_objections then
                    drop_objection;
                end if;
                -- Deallocation of the pointer
                deallocate(tmp_pointer);
                ok := true;
            end if; 
        end get;

    end protected body tlm_fifo_type;

    -- Puts a data to a FIFO.
    -- This procedure will block until there is space in the FIFO.
    -- The procedure will periodically try to put data, the period being
    -- defined by the generic parameter retry_delta.
    procedure blocking_put(fifo : inout tlm_fifo_type;
                           data: element_type) is
        variable ok: boolean;
    begin
        ok := false;
        loop
            fifo.put(data, ok);
            if (ok) then
                exit;
            else
                wait for retry_delta;
            end if;
        end loop;
    end blocking_put;

    -- Gets a data from a FIFO.
    -- This procedure will block until there is space in the FIFO.
    -- The procedure will periodically try to put data, the period being
    -- defined by the generic parameter retry_delta.
    procedure blocking_get(fifo : inout tlm_fifo_type;
                           data: out element_type) is
        variable ok: boolean;
    begin
        ok := false;
        loop
            fifo.get(data, ok);
            if (ok) then
                exit;
            else
                wait for retry_delta;
            end if;
        end loop;
    end blocking_get;

    -- Puts a data to a FIFO.
    -- This procedure will block until there is space in the FIFO.
    -- The procedure will periodically try to put data, the period being
    -- defined by the generic parameter retry_delta.
    -- The procedure will return after a certain timeout if the insertion
    -- has not been successful.
    -- The last parameter is modified and indicates if there was enough
    -- space to store the data (true) or not (false). So basically if
    -- the FIFO is full and the timeout was reached, then ok will be false.
    procedure blocking_timeout_put(fifo : inout tlm_fifo_type;
                                   data: element_type;
                                   timeout : time;
                                   ok: out boolean) is
        variable entry_time : time;
    begin
        entry_time := now;
        ok := false;
        loop
            fifo.put(data, ok);
            if (ok) or (now - entry_time > timeout) then
                exit;
            else
                wait for retry_delta;
            end if;
        end loop;
    end blocking_timeout_put;


    -- Gets a data from a FIFO.
    -- This procedure will block until there is space in the FIFO.
    -- The procedure will periodically try to put data, the period being
    -- defined by the generic parameter retry_delta.
    -- The procedure will return after a certain timeout if no data is
    -- available.
    -- The last parameter is modified and indicates if there was data
    -- in the FIFO (true) or not (false).
    procedure blocking_timeout_get(fifo : inout tlm_fifo_type;
                                   data: out element_type;
                                   timeout : time;
                                   ok: out boolean) is
        variable entry_time : time;
    begin
        entry_time := now;
        ok := false;
        loop
            fifo.get(data, ok);
            if (ok) or (now - entry_time > timeout)  then
                exit;
            else
                wait for retry_delta;
            end if;
        end loop;
    end blocking_timeout_get;

end tlm_unbounded_fifo_pkg;

