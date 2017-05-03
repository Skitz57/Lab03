library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.math_computer_pkg.all;

entity math_computer_control is
	port (
		clk_i    : in    std_logic;
		rst_i    : in    std_logic;
		control_to_datapath_o : out control_to_datapath_t;
		datapath_to_control_i : in datapath_to_control_t;
		start_i : in std_logic; -- valid_i
		ready_i : in std_logic;
		valid_o : out std_logic;
		ready_o : out std_logic
	);
end math_computer_control;

architecture behave of math_computer_control is

	type state_t is (sInit, s1, s2, s3, s4);

	signal state_s : state_t;
	signal next_state_s : state_t;

begin

	process(start_i, ready_i, datapath_to_control_i, state_s) is
	begin
		ready_o <= '0';
		valid_o <= '0';
		test

		control_to_datapath_o.sel0 <= "000";
		control_to_datapath_o.sel1 <= "000";
		control_to_datapath_o.sel2 <= "000";
		control_to_datapath_o.sel3 <= "000";
		control_to_datapath_o.sel_output <= "000";

		next_state_s <= state_s;
		-- Product -> a+a
		case state_s is
			when sInit =>
			ready_o <= '1';
			control_to_datapath_o.sel0 <= "001";
			control_to_datapath_o.sel1 <= "001";
			if start_i = '1' then
				next_state_s <= s1;
			end if;
		-- Summation -> +b
		when s1 =>
			control_to_datapath_o.sel0 <= "100";
			control_to_datapath_o.sel1 <= "010";
			next_state_s <= s2;
		-- Subtraction -> -c
		when s2 =>
			control_to_datapath_o.sel1 <= "100";
			control_to_datapath_o.sel2 <= "011";
			next_state_s <= s3;
		when s3 =>
			control_to_datapath_o.sel0 <= "101";
			control_to_datapath_o.sel_output <= "000";
			next_state_s <= s4;
		when s4 =>
			valid_o <= '1';
			if ready_i = '1' then
				next_state_s <= sInit;
			end if;
		end case;
	end process;

	process(clk_i, rst_i) is
	begin
		if rst_i = '1' then
			state_s <= sInit;
		elsif rising_edge(clk_i) then
			state_s <= next_state_s;
		end if;
	end process;

end behave;
