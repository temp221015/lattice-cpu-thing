library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstrRAM is
	port (
		clk        : in  STD_LOGIC;
		read_addr  : in  STD_LOGIC_VECTOR (15 downto 0);
		read_data  : out STD_LOGIC_VECTOR (31 downto 0);
		write_addr : in  STD_LOGIC_VECTOR (15 downto 0);
		write_data : in  STD_LOGIC_VECTOR (31 downto 0);
		write_en   : in  STD_LOGIC
	);
end InstrRAM;

architecture Behavioral of InstrRAM is

	type instr_type is array(4095 downto 0) of std_logic_vector(31 downto 0);  
	signal instr : instr_type;

	attribute ram_style : string;
	attribute ram_style of instr: signal is "block_ram";

	signal reg_data : std_logic_vector(31 downto 0);
	
	signal reg_addr : std_logic_vector(15 downto 0);
	
	
begin

process(clk)
begin
	if falling_edge(clk) then
		reg_addr <= read_addr;
		
		if write_en = '1' then
			instr(to_integer(unsigned(write_addr(11 downto 0)))) <= write_data;
		else
			reg_data <= instr(to_integer(unsigned(reg_addr(11 downto 0))));
		end if;
	
		read_data <= reg_data;
	end if;


end process;


end Behavioral;
