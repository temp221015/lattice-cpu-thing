library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity BranchPredictor is
    Port ( clk     : in  STD_LOGIC;
           exp_pc  : in  STD_LOGIC_VECTOR (15 downto 0);
           miss    : in  STD_LOGIC;
           pc0     : out STD_LOGIC_VECTOR (15 downto 0);
           pc1     : out STD_LOGIC_VECTOR (15 downto 0)
    );
end BranchPredictor;

architecture Behavioral of BranchPredictor is

    signal reg_pc_next : STD_LOGIC_VECTOR (15 downto 0) := x"0000";
    
    signal reg_pc0 : STD_LOGIC_VECTOR (15 downto 0) := x"FFFF";
    signal reg_pc1 : STD_LOGIC_VECTOR (15 downto 0) := x"FFFF";
    signal reg_pc2 : STD_LOGIC_VECTOR (15 downto 0) := x"FFFF";
    signal reg_pc3 : STD_LOGIC_VECTOR (15 downto 0) := x"FFFF";
    
    signal reg_miss1 : std_logic := '0';
    
    -- Branch Target Buffer:
    --  (0.. 7) = upper byte of source PC
    --  (8..23) = target PC
    --  (24)    = record enabled
    type LUT_type is array(255 downto 0) of std_logic_vector(31 downto 0);
    
    signal LUT : LUT_type;
    
begin


process(clk)

    variable entry : std_logic_vector(31 downto 0); -- std_logic_vector(31 downto 0);
    
    variable idx : integer;
    
begin
    if rising_edge(clk) then       
        reg_pc3 <= reg_pc2;
        reg_pc2 <= reg_pc1;
        reg_pc1 <= reg_pc0;

        reg_miss1 <= miss;
        
        -- On branch miss from the Decoder
        if miss = '1' and reg_miss1 /= '1' then
			write(output, "(" & time'image(NOW) & ") BranchPredictor: Storing branch "
				& "from pc=" & integer'image(to_integer(unsigned(reg_pc3)))
				& " to pc"  & integer'image(to_integer(unsigned(exp_pc))) & LF
			);

            -- Update the BTB record
            idx := to_integer(unsigned(reg_pc3(7 downto 0)));           
            LUT(idx)(7 downto 0)  <= reg_pc3(15 downto 8);
            LUT(idx)(23 downto 8) <= exp_pc;
            LUT(idx)(24)          <= '1';            
            -- And pass exp_pc to the InstrRAM 
            reg_pc0 <= exp_pc;
        -- No branch miss, so perform a prediction
        else
               idx := to_integer(unsigned(reg_pc0(7 downto 0)));
            
               -- We have a BTB hit when:
               -- 1) the "tag" bits match the upper bits of reg_pc0 
               -- 2) the "enabled" bit (at index 24) is '1'
               if LUT(idx)(7 downto 0) = reg_pc0(15 downto 8) and LUT(idx)(24) = '1' then

                    write(output, "(" & time'image(NOW) & ") BranchPredictor: Predicting branch "
						& "from pc=" & integer'image(to_integer(unsigned(reg_pc0)))
						& " to pc="  & integer'image(to_integer(unsigned(LUT(idx)(23 downto 8)))) & LF
					);

                    reg_pc0 <= LUT(idx)(23 downto 8);
               -- Otherwise we just increase the PC by 1
               else
                    reg_pc0 <= std_logic_vector( unsigned(reg_pc0) + 1);
               end if;
        end if;        
    end if;
end process;

    pc0 <= reg_pc0;
    pc1 <= reg_pc1;

end Behavioral;
