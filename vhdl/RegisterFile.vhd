library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RegisterFile is
    Port ( clk : in STD_LOGIC;
           reg_A : in STD_LOGIC_VECTOR (3 downto 0);
           reg_B : in STD_LOGIC_VECTOR (3 downto 0);
           reg_C : in STD_LOGIC_VECTOR (3 downto 0);
           data_A : out STD_LOGIC_VECTOR (31 downto 0);
           data_B : out STD_LOGIC_VECTOR (31 downto 0);
           data_C : in STD_LOGIC_VECTOR (31 downto 0);
           flags : out STD_LOGIC_VECTOR(15 downto 0);
           we_C : in STD_LOGIC);
end RegisterFile;

architecture Behavioral of RegisterFile is
begin

process(clk)
begin
	if rising_edge(clk) then
		data_B <= data_C;
	end if;
end process;

end Behavioral;
