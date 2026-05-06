library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
--use IEEE.NUMERIC_STD.ALL;

entity Main_sim is
end Main_sim;

architecture Main_sim_arch of Main_sim is

	signal sys_clock     : STD_LOGIC;
	signal ram_clock     : STD_LOGIC;
		
	signal io_write_data : STD_LOGIC_VECTOR(31 downto 0);
	signal io_write_addr : STD_LOGIC_VECTOR(15 downto 0);
	signal io_write_en   : STD_LOGIC;
begin

	main_i : entity work.Main
	port map (
		sys_clock => sys_clock,
		ram_clock => ram_clock,
	
		io_write_data => io_write_data,
		io_write_addr => io_write_addr,
		io_write_en   => io_write_en
	);
	
	process
	begin
		-- Load some data into InstrRAM first
		io_write_data <= x"70000000";         -- Bit 31 is 0, so it's a NOP
		io_write_addr <= x"0000";
		io_write_en   <= '1';
		wait for 5 ns; ram_clock <= '1';
		wait for 5 ns; ram_clock <= '0';
		wait for 3 ns;
		io_write_data <= x"70000001";         -- NOP
		io_write_addr <= x"0001";
		wait for 2 ns; ram_clock <= '1';
		wait for 5 ns; ram_clock <= '0';
		wait for 3 ns;
		io_write_data <= x"70000002";         -- NOP
		io_write_addr <= x"0002";
		wait for 2 ns; ram_clock <= '1';
		wait for 5 ns; ram_clock <= '0';
		wait for 3 ns;
		io_write_data <= x"70000003";         -- NOP
		io_write_addr <= x"0003";
		wait for 2 ns; ram_clock <= '1';
		wait for 5 ns; ram_clock <= '0';
		wait for 3 ns;
		io_write_data <= x"FFFF0000";         -- BRANCH to the lower 16 bits
		io_write_addr <= x"0004";
		wait for 2 ns; ram_clock <= '1';
		wait for 5 ns; ram_clock <= '0';
		wait for 35 ns;
		io_write_en   <= '0';
		
		-- Now run 30 cycles with ram_clock and sys_clock
		for i in 0 to 30 loop
			wait for 5 ns; ram_clock <= '1'; sys_clock <= '1';
			wait for 5 ns; ram_clock <= '0'; sys_clock <= '0';
		end loop;

		wait;
	
	end process;
	
end Main_sim_arch;
