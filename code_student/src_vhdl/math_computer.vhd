library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.math_computer_pkg.all;

entity math_computer is
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
end math_computer;

architecture struct of math_computer is

		signal result_s : std_logic_vector(DATASIZE-1 downto 0);
		signal a_s : std_logic_vector(DATASIZE-1 downto 0);
		signal b_s : std_logic_vector(DATASIZE-1 downto 0);
		signal c_s : std_logic_vector(DATASIZE-1 downto 0);

		signal general_enable : std_logic;
    signal add_1 : std_logic_vector(DATASIZE-1 downto 0);
		signal add_1_fut : std_logic_vector(DATASIZE-1 downto 0);
		signal add_2 : std_logic_vector(DATASIZE-1 downto 0);
		signal add_2_fut : std_logic_vector(DATASIZE-1 downto 0);
		signal sub_1 : std_logic_vector(DATASIZE-1 downto 0);
		signal sub_1_fut : std_logic_vector(DATASIZE-1 downto 0);
		signal valid_fut : std_logic_vector(DATASIZE-1 downto 0);
		signal valid_fut_fut : std_logic;

begin

	-- variables assignments
	a_s <= input_itf_in_i.a;
	b_s <= input_itf_in_i.b;
	c_s <= input_itf_in_i.c;
	output_itf_out_o.result <= result_s;

	-- process synchrone
	synch : process (clk_i)
	begin
		if rising_edge(clk_i) then
			-- Reset
			if (rst_i = '1') then
				-- enable
				if (general_enable = '1') then
					add_2 = add_2_fut;
					add_1 = add_1_fut;
					sub_1 = sub_1_fut;
					valid_fut = start_i;
					valid_o = valid_fut;
				end if
			end if;
		end if;
	end process;

		comb : process (valid_o, ready_i,valid_i,ready_o)
		begin

			if(valid_o and (not ready_i) then
				general_enable <= '0';
			else
				general_enable <= '1';
			end if;
			if (valid_i and ready_o) then
				add_1_fut <= std_logic_vector(unsigned(a_s) + unsigned(a_s));
				sub_1_fut <= std_logic_vector(unsigned(b_s) - unsigned(c_s));
				add_2_fut <= std_logic_vector(unsigned(add_1_fut) + unsigned(sub_1_fut));
			end if;
		end process;
end struct;
