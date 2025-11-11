-----------------------------------------------
--Mux 3 to 1: Used for selecting between PC+4, ALUOut, s_DMemOut
-----------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux3t1_N is
	port(
	i_S	: in std_logic_vector(1 downto 0);
	i_D0	: in std_logic_vector(31 downto 0);
	i_D1	: in std_logic_vector(31 downto 0);
	i_D2	: in std_logic_vector(31 downto 0);
	o_O	: out std_logic_vector(31 downto 0)
	);
end entity;

architecture behavioral of mux3t1_N is
begin
	with i_S select
	  o_O <= i_D0 when "00",
	  	 i_D1 when "01",
		 i_D2 when "10",
		 (others => '0') when others;
end architecture behavioral;