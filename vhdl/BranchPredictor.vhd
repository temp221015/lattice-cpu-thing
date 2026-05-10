library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.helpers.ALL;

entity BranchPredictor is
	port (
		clk    : in  STD_LOGIC;
		exp_pc : in  STD_LOGIC_VECTOR (15 downto 0);
		miss   : in  STD_LOGIC;
		pc0    : out STD_LOGIC_VECTOR (15 downto 0);
		pc1    : out STD_LOGIC_VECTOR (15 downto 0)
	);
end BranchPredictor;

architecture Behavioral of BranchPredictor is
	
	signal reg_pc0 : STD_LOGIC_VECTOR (15 downto 0) := x"FFFF";
	signal reg_pc1 : STD_LOGIC_VECTOR (15 downto 0) := x"FFFF";
	signal reg_pc2 : STD_LOGIC_VECTOR (15 downto 0) := x"FFFF";
	signal reg_pc3 : STD_LOGIC_VECTOR (15 downto 0) := x"FFFF";
	
	signal reg_miss1 : std_logic := '0';
	
	-- Branch Target Buffer:
	--  (0.. 7) = "tag" (upper byte of source PC)
	--  (8..23) = target PC
	type LUT_type is array(255 downto 0) of std_logic_vector(23 downto 0);   
	signal LUT : LUT_type;
	
	--attribute ram_style : string;
	--attribute ram_style of LUT: signal is "distributed";    
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
		
		-- On a miss from the Decoder we need to fetch exp_pc *once*. Since the InstrRAM
		-- has a 2-cycle latency, we'll probably get another miss in the second cycle. We
		-- need to ignore that one to prevent a second misprediction after the branch.
		if miss = '1' and reg_miss1 /= '1' then
			my_write("(" & my_strnow & ") BranchPredictor: Storing branch from pc=" & my_slv2str(reg_pc3) & " to pc"  & my_slv2str(exp_pc) & LF);

			-- Update the BTB record
			idx := to_integer(unsigned(reg_pc3(7 downto 0)));           
			LUT(idx)(7 downto 0)  <= reg_pc3(15 downto 8);
			LUT(idx)(23 downto 8) <= exp_pc;
			-- And pass exp_pc to the InstrRAM 
			reg_pc0 <= exp_pc;
		-- No branch miss, so perform a prediction
		else
			   idx := to_integer(unsigned(reg_pc0(7 downto 0)));
			
			   -- We index using the lower 8 bits of the 16-bit PC, and have a branch table hit
			   -- when the "tag" holds the upper 8 bits.
			   if LUT(idx)(7 downto 0) = reg_pc0(15 downto 8) then
				   my_write("(" & my_strnow & ") BranchPredictor: Predicting branch from pc=" & my_slv2str(reg_pc0) & " to pc="  & my_slv2str(LUT(idx)(23 downto 8)) & LF);
					reg_pc0 <= LUT(idx)(23 downto 8);
			   else
					-- Otherwise we just increase the PC by 1
					reg_pc0 <= std_logic_vector( unsigned(reg_pc0) + 1);
			   end if;
		end if;        
	end if;
end process;

	pc0 <= reg_pc0;
	pc1 <= reg_pc1;

end Behavioral;
