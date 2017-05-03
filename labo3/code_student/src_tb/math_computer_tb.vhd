-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : math_computer_tb.vhd
--
-- Description  : Ce banc de test vérifie le bon fonctionnement d'un calculateur
--                séquentiel. Il ne stress pas particulièrement le design
--
-- Auteur       : Yann Thoma
-- Date         : 29.03.2017
-- Version      : 1.0
--
-- Utilise      :
--              :
--
--| Modifications |------------------------------------------------------------
-- Version   Auteur      Date               Description
-- 1.0       YTA         see header         First version.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tlmvm;
context tlmvm.tlmvm_context;

use work.RNG.all;

use work.math_computer_pkg.all;
use work.math_computer_verif_pkg.all;

------------
-- Entity --
------------
entity math_computer_tb is
    generic (DATASIZE : integer := 8);
end math_computer_tb;

------------------
-- Architecture --
------------------
architecture test_bench of math_computer_tb is


    subtype input_transaction_t is  math_computer_input_transaction_t(
                                    a(DATASIZE-1 downto 0),
                                    b(DATASIZE-1 downto 0),
                                    c(DATASIZE-1 downto 0));

    subtype output_transaction_t is
        math_computer_output_transaction_t (result(DATASIZE-1 downto 0));

    subtype input_t is  math_input_itf_in_t(
                                    a(DATASIZE-1 downto 0),
                                    b(DATASIZE-1 downto 0),
                                    c(DATASIZE-1 downto 0));

    subtype output_t is
        math_output_itf_out_t (result(DATASIZE-1 downto 0));


-- Create a specialized FIFO package with the same data width for holding
-- the transaction (requests and responses) they are of the same type.
-- Very importan: Use the specialized subtypes, not the generic ones
    package input_transaction_pkg is new tlm_unbounded_fifo_pkg
        generic map (element_type => input_transaction_t);


    package output_transaction_pkg is new tlm_unbounded_fifo_pkg
        generic map (element_type => output_transaction_t);


    ---------------
    -- Constants --
    ---------------
    constant CLK_PERIOD : time := 10 ns;
    constant NUMBER_OF_TRANSACTIONS : integer := 100;

    ----------------
    -- Components --
    ----------------

    component math_computer is
    	generic (
    		DATASIZE   : integer := 8
    	);
    	port (
    		clk_i            : in  std_logic;
    		rst_i            : in  std_logic;
            input_itf_in_i   : in  math_input_itf_in_t;
            input_itf_out_o  : out math_input_itf_out_t;
            output_itf_in_i  : in  math_output_itf_in_t;
            output_itf_out_o : out math_output_itf_out_t
    	);
    end component;

    ----------------------
    -- Shared Variables --
    ---------------------- -- May be accessed by more than one process at the time
    shared variable fifo_sti : input_transaction_pkg.tlm_fifo_type; -- Stimuli transactions
    shared variable fifo_obs : output_transaction_pkg.tlm_fifo_type; -- Responses
    shared variable fifo_ref : output_transaction_pkg.tlm_fifo_type; -- Reference

    -------------
    -- Signals --
    -------------
    signal clk_sti      : std_logic;
    signal rst_sti      : std_logic;



    signal input_itf_in_sti   : input_t;
    signal input_itf_out_obs  : math_input_itf_out_t;
    signal output_itf_in_sti  : math_output_itf_in_t;
    signal output_itf_out_obs : output_t;


    type simulation_info_t is protected

        procedure new_input;

        procedure new_output;

        procedure add_error;

        procedure log_end;

    end protected simulation_info_t;

    type simulation_info_t is protected body

        variable nb_input : integer := 0;
        variable nb_output : integer := 0;
        variable nb_error : integer := 0;

        procedure new_input is
        begin
            nb_input := nb_input + 1;
        end new_input;

        procedure new_output is
        begin
            nb_output := nb_output + 1;
        end new_output;

        procedure add_error is
        begin
            nb_error := nb_error + 1;
        end add_error;

        procedure log_end is
        begin
            if nb_output /= nb_input then
                report LF & "************************************" & LF &
                       "Simulation error" & LF &
                       "Nb of output (" & integer'image(nb_output) &
                        ") do not match nb of input (" &
                        integer'image(nb_input) & ")" & LF &
                        "************************************";
            else
                report LF & "************************************" & LF &
                       "Simulation successful" & LF &
                       "Nb of output matches nb of input" & LF &
                       "************************************";
            end if;


        end log_end;

    end protected body simulation_info_t;

    shared variable simulation_info : simulation_info_t;

    ----------------
    -- Procedures --
    ----------------
    procedure rep(status : finish_status_t) is
    begin
        simulation_info.log_end;
    end rep;


    procedure generate_reference(variable stimulus: input_transaction_t; variable ref: out output_transaction_t) is
    begin
        ref.result := std_logic_vector(unsigned(stimulus.a) + unsigned(stimulus.b));
    end procedure generate_reference;

begin

    -- Simulation monitor
    monitor : simulation_monitor
    generic map (
        drain_time => 2000 ns, -- Timeout (objections)
        beat_time => 2000 ns, -- Timeout (heart beat)
        final_reporting => rep
    );

    -- Clock generation
    clock_generator(clk_sti, CLK_PERIOD);

    -- Reset generation
    simple_startup_reset(rst_sti, CLK_PERIOD * 10);

    -- Device under test
    DUT : math_computer
    generic map(
        DATASIZE => DATASIZE
    )
    port map(
        clk_i            => clk_sti,
        rst_i            => rst_sti,
        input_itf_in_i   => input_itf_in_sti,
        input_itf_out_o  => input_itf_out_obs,
        output_itf_in_i  => output_itf_in_sti,
        output_itf_out_o => output_itf_out_obs
    );

    -- Driver process : will take transactions from the stimulation FIFO and
    -- administer them to the DUT
    driver_process : process is
        variable data_v : input_transaction_t;
    begin

        input_itf_in_sti.valid <= '0';
        input_itf_in_sti.a <= (others => '0');
        input_itf_in_sti.b <= (others => '0');
        input_itf_in_sti.c <= (others => '0');

        wait until falling_edge(rst_sti);

        loop
            input_itf_in_sti.valid <= '0';

            -- Get a word from the stimuli FIFO
            input_transaction_pkg.blocking_get(fifo_sti, data_v);

            wait until falling_edge(clk_sti);
            -- If the DUT if full, wait
            if input_itf_out_obs.ready /= '1' then
                wait until input_itf_out_obs.ready = '1';
            end if;
            -- Write to DUT
            input_itf_in_sti.a  <= data_v.a;
            input_itf_in_sti.b  <= data_v.b;
            input_itf_in_sti.c  <= data_v.c;
            input_itf_in_sti.valid <= '1';

            simulation_info.new_input;

            wait until rising_edge(clk_sti);
        end loop;
    end process driver_process;

    -- Reader process : Once the DUT is full this process will read from the DUT
    -- forever, if the DUT is not empty this process will put the word read in
    -- the obs FIFO for review by the verification process
    reader_process : process is
        --                                      Seed, Mean, Var
        variable rnd_100 : Uniform := InitUniform(7, 0.0, 3.0);
        variable ok : boolean;

        variable output_transaction_v : output_transaction_t;
    begin
        output_itf_in_sti.ready <= '0';

        loop
            -- Random wait
            GenRnd(rnd_100);
            wait for (integer(rnd_100.rnd))*CLK_PERIOD;

            wait until falling_edge(clk_sti);

            output_itf_in_sti.ready <= '1';
            while (output_itf_out_obs.valid /= '1') loop
                wait until falling_edge(clk_sti);
            end loop;

            output_transaction_v.result := output_itf_out_obs.result;

            simulation_info.new_output;

            output_transaction_pkg.blocking_put(fifo_obs,output_transaction_v);


            wait until falling_edge(clk_sti);

            output_itf_in_sti.ready <= '0';
            wait until falling_edge(clk_sti);

        end loop;
    end process reader_process;


    -- Stimulation process : This will generate data to the stimuli and
    -- reference FIFOs for the Driver to send to the DUT and for the
    -- verification process as a reference
    stimulation_process : process is
        variable stimulus : input_transaction_t;
        variable reference : output_transaction_t;
    begin
        -- This will send a given number of data packets to the driver and the
        -- reference FIFO (for verification)

        for i in 1 to NUMBER_OF_TRANSACTIONS loop
            raise_objection; -- Check usage of objections

            stimulus.a := std_logic_vector(to_unsigned(i, stimulus.a'length));
            stimulus.b := std_logic_vector(to_unsigned(i+1, stimulus.a'length));
            stimulus.c := std_logic_vector(to_unsigned(i+2, stimulus.a'length));

            generate_reference(stimulus, reference);

            input_transaction_pkg.blocking_put(fifo_sti, stimulus);
            drop_objection; -- Check usage of objections
            output_transaction_pkg.blocking_put(fifo_ref, reference);
        end loop;

        wait;
    end process stimulation_process;

    -- Verification process : This will check the data reader from the DUT by
    -- the reader process and compare them in contents to the reference, this
    -- will also warn if more data has been read as expected, If the simulation
    -- ends without showing the message that all data was read there is a problem
    verification_process : process is
        variable data_obs_v  : output_transaction_t;
        variable data_ref_v  : output_transaction_t;
        variable read_data_v : integer := 0;
    begin
        -- This will check the data from the reader against the reference data

        loop
            output_transaction_pkg.blocking_get(fifo_obs, data_obs_v);
            read_data_v := read_data_v + 1;

            if read_data_v = NUMBER_OF_TRANSACTIONS then
                report "All data was read" severity note;
            end if;

            if read_data_v > NUMBER_OF_TRANSACTIONS then
                -- Problem !
                report "More data was read than expected !" severity error;
            end if;

            output_transaction_pkg.blocking_get(fifo_ref, data_ref_v);

            -- To self-test the verification procedure, uncomment the next lines
            -- data_ref_v.result := (others => '0');
            if data_obs_v /= data_ref_v then
                -- Problem !
                simulation_info.add_error;

                report "Unexpected data!";
--                report "Unexpected data ! Expected : " & to_hstring(data_ref_v) & " But got : " & to_hstring(data_obs_v) severity error;
            end if;
        end loop;

    end process verification_process;

end test_bench;
