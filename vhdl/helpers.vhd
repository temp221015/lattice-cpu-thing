library IEEE;
use STD.TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;

--pragma translate_off
use STD.TEXTIO.ALL;
--pragma translate_on

package helpers is
	procedure my_write(str : string);
	impure function my_slv2str(slv : std_logic_vector) return string;
	impure function my_strnow return string;
end helpers;

package body helpers is

	procedure my_write(str : string) is
	begin
	--pragma translate_off
	write(output, str);
	--pragma translate_on
	end my_write;
	
	impure function my_slv2str(slv : std_logic_vector) return string is
	begin
		return integer'image(to_integer(unsigned(slv)));
	end my_slv2str;
	
	impure function my_strnow return string is
	begin
		return time'image(NOW);
	end my_strnow;

end helpers;