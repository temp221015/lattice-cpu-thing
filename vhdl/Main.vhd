library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 

entity Main is
	port (
		sys_clock  : in STD_LOGIC;
		ram_clock  : in STD_LOGIC;
		
		io_write_data : in STD_LOGIC_VECTOR(31 downto 0);
		io_write_addr : in STD_LOGIC_VECTOR(15 downto 0);
		io_write_en   : in STD_LOGIC;
		
		io_debugport  : out STD_LOGIC_VECTOR(7 downto 0)
	);
end Main;

architecture Behavioral of Main is

	-- Decoder => BranchPredictor (signals a branch miss, and the correct PC)
	signal exp_pc : STD_LOGIC_VECTOR(15 downto 0);
	signal miss   : STD_LOGIC;
	
	-- InstrRAM/BranchPredictor => Decoder (the current instruction and its PC)
	signal instr1 : STD_LOGIC_VECTOR(31 downto 0);
	signal pc1    : STD_LOGIC_VECTOR(15 downto 0);
	
	-- InstrRAM
	signal read_addr : STD_LOGIC_VECTOR (15 downto 0);
	
	-- RegisterFile
	signal reg_A  : STD_LOGIC_VECTOR (3 downto 0) := "0000";
	signal reg_B  : STD_LOGIC_VECTOR (3 downto 0) := "0000";
	signal reg_C  : STD_LOGIC_VECTOR (3 downto 0);
	signal data_A : STD_LOGIC_VECTOR (31 downto 0);
	signal data_B : STD_LOGIC_VECTOR (31 downto 0);
	signal data_C : STD_LOGIC_VECTOR (31 downto 0);
	signal flags  : STD_LOGIC_VECTOR (15 downto 0);
	signal we_C   : STD_LOGIC;
	
	signal opcode : STD_LOGIC_VECTOR (7 downto 0);
begin

	bp : entity work.BranchPredictor
	port map (
		clk => sys_clock,
		pc0 => read_addr,
		pc1 => pc1,
		exp_pc => exp_pc,
		miss => miss
	);
	
	decoder : entity work.Decoder
	port map (
		clk => sys_clock,
		instr1 => instr1,
		pc1 => pc1,
		flags => flags,
		miss => miss,
		exp_pc => exp_pc,
		reg_A => reg_A,
		reg_B => reg_B,
		reg_C => reg_C,
		opcode => opcode
	);
	
	instr_ram : entity work.InstrRAM
	port map (
		clk => ram_clock,
		read_addr  => read_addr,
		read_data  => instr1,
		write_addr => io_write_addr,
		write_data => io_write_data,
		write_en   => io_write_en
	);
	
	regfile : entity work.RegisterFile
	port map (
		clk => sys_clock,
		
		reg_A  => reg_A,
		reg_B  => reg_B,
		reg_C  => reg_C,
		data_A => data_A,
		data_B => data_B,
		data_C => data_C,
		
		flags  => flags,
		we_C   => we_C
	);
	
	exec : entity work.Executor
	port map (
		clk => sys_clock,
		opcode => opcode,
		data_A => data_A,
		data_B => data_B,
		data_C => data_C,
		we_C => we_C
	);
	
	io_debugport <= opcode;
	
end Behavioral;
