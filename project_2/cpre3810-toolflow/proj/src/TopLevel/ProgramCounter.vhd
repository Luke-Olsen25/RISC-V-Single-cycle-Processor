-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ProgramCounter.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: this is the program counter
--              
-- 10/07/2025
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity ProgramCounter is
	port(
		clk	 	 :   in std_logic;
		rst      :   in std_logic;
		pc_in    :   in std_logic_vector(31 downto 0);
		pc_out   :   out std_logic_vector(31 downto 0)
	);
end ProgramCounter;

architecture behavioral of ProgramCounter is
	signal pc_reg : std_logic_vector(31 downto 0) := (others => '0'); -- register that holds pc value
begin
	process(rst,clk)
	begin 
		if rst = '1' then
			--pc_reg <= (others => '0');
			pc_reg <= x"00400000";
		elsif rising_edge(clk) then
			pc_reg <= pc_in;
		end if;
	end process;
	pc_out <= pc_reg;
	
end behavioral;
