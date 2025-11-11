-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- decoder_5to32.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file is of a 5 to 32 decoder used to select a register in the register file
--
--
-- NOTES:
-- 9/13/2025
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity decoder_5to32 is 
	port(
		i_I : in std_logic_vector(4 downto 0);
		o_O : out std_logic_vector(31 downto 0)
	);
end decoder_5to32;

architecture behavior of decoder_5to32 is
begin
	
	process(i_I)
		variable index : integer;
		begin
			o_O <= (others => '0'); -- clear the output bits
			index := to_integer(unsigned(i_I)); -- converts the bits into decimal
			o_O(index) <= '1'; -- sets the value at the index to 1
	end process;
end behavior;













