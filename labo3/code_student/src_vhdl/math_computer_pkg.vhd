library ieee;
use ieee.std_logic_1164.all;

package math_computer_pkg is

    type math_input_itf_in_t is
    record
        valid : std_logic;
        a : std_logic_vector;
        b : std_logic_vector;
        c : std_logic_vector;
    end record;

    type math_input_itf_out_t is
    record
        ready : std_logic;
    end record;

    type math_output_itf_out_t is
    record
        valid : std_logic;
        result : std_logic_vector;
    end record;

    type math_output_itf_in_t is
    record
        ready : std_logic;
    end record;

    type control_to_datapath_t is
    record
        sel0       : std_logic_vector(2 downto 0);
        sel1       : std_logic_vector(2 downto 0);
        sel2       : std_logic_vector(2 downto 0);
        sel3       : std_logic_vector(2 downto 0);
        sel_output : std_logic_vector(2 downto 0);
    end record;

    type datapath_to_control_t is
    record
        a_greater_than_b : std_logic;
    end record;


end package math_computer_pkg;
