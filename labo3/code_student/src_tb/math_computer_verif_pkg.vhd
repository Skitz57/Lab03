library ieee;
use ieee.std_logic_1164.all;

package math_computer_verif_pkg is

    -- This type represents an input transaction for math_computer.
    -- It is independent from the DUT interaction protocol
    type math_computer_input_transaction_t is
    record
        a : std_logic_vector;
        b : std_logic_vector;
        c : std_logic_vector;
    end record;

    -- This type represents an output transaction for math_computer
    type math_computer_output_transaction_t is
    record
        result : std_logic_vector;
    end record;

end package math_computer_verif_pkg;
