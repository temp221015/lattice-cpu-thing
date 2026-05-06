library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstrRAM is
    Port ( clk        : in  STD_LOGIC;
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

    signal reg_read_data : std_logic_vector(31 downto 0);
    
begin

process(clk)
begin
    if falling_edge(clk) then
        if write_en = '1' then
            instr(to_integer(unsigned(write_addr))) <= write_data;
        end if;    
    
        read_data <= reg_read_data;
        reg_read_data <= instr(to_integer(unsigned(read_addr(11 downto 0))));        
    end if;
    
    
end process;


end Behavioral;
