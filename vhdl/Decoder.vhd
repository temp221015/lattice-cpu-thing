library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity Decoder is
    Port ( clk    : in STD_LOGIC;
           instr1 : in STD_LOGIC_VECTOR (31 downto 0);
           pc1    : in STD_LOGIC_VECTOR (15 downto 0);
           miss   : out STD_LOGIC;
           exp_pc : out STD_LOGIC_VECTOR (15 downto 0);
           opcode : out STD_LOGIC_VECTOR (7 downto 0);
           
           reg_A  : out STD_LOGIC_VECTOR (3 downto 0);
           reg_B  : out STD_LOGIC_VECTOR (3 downto 0);
           reg_C  : out STD_LOGIC_VECTOR (3 downto 0);
           
           flags  : in STD_LOGIC_VECTOR(15 downto 0)
    );
           
end Decoder;

architecture Behavioral of Decoder is

    -- send a branch misprediction to BranchPredictor, tell it we want PC=0000
    signal reg_exp_pc : std_logic_vector(15 downto 0) := x"0000";
    signal reg_miss   : std_logic := '1';
    
    -- send NOPs to Executor stage until we receive the first instruction
    signal reg_opcode : std_logic_vector(7 downto 0) := x"00";

begin
    process(clk)
	begin
        if rising_edge(clk) then
            if pc1 = reg_exp_pc then
                reg_miss <= '0';
                
                opcode <= instr1(7 downto 0);
                reg_A  <= instr1(11 downto 8);
                reg_B  <= instr1(15 downto 12);
                reg_C  <= instr1(19 downto 16);
                
                -- Bit 31 means unconditional jump, set PC <= lower 16 bits of instr
                if instr1(31) = '1' then
                    --write(output, "(" & time'image(NOW) & ")         Decoder: Branching "
					--	& "from pc=" & integer'image(to_integer(unsigned(pc1)))
					--	& " to pc="  & integer'image(to_integer(unsigned(instr1(15 downto 0)))) & LF
					--);
                    reg_exp_pc <= std_logic_vector(unsigned(instr1(15 downto 0)));
                -- All other instructions just increase the PC by 1
                else
                    reg_exp_pc <= std_logic_vector(unsigned(reg_exp_pc) + 1);
                end if;
            else
                --write(output, "(" & time'image(NOW) & ")         Decoder: Mispredict ("
				--	& "exp_pc=" & integer'image(to_integer(unsigned(reg_exp_pc)))
				--	& " pc1="   & integer'image(to_integer(unsigned(pc1)))
				--	& ")" & LF
				--);
                reg_miss <= '1';
                opcode <= x"00"; -- Send a NOP to the Executor stage
            end if;
        end if; 
    end process;
    
    exp_pc <= reg_exp_pc;   
    opcode <= reg_opcode;
    miss   <= reg_miss;
    
end Behavioral;
