library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Executor is
	port ( clk : in STD_LOGIC;
		   opcode : in STD_LOGIC_VECTOR (7 downto 0);
		   data_A : in STD_LOGIC_VECTOR (31 downto 0);
		   data_B : in STD_LOGIC_VECTOR (31 downto 0);
		   data_C : out STD_LOGIC_VECTOR (31 downto 0);
		   we_C : out STD_LOGIC
	);
end Executor;

architecture Behavioral of Executor is

begin

	we_C <= '0';
	data_C <= x"00000000";

end Behavioral;
