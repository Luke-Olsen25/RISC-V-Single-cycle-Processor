-----------------------------------------------
-- Immediate Generator based on lab 2 extender
-----------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ImmGen is
    port(
	i_ImmSel   : in std_logic_vector(2 downto 0);
        i_ImmType : in std_logic_vector(31 downto 0);
	o_Imm    : out std_logic_vector(31 downto 0)
	);
end entity ImmGen;

architecture behavioral of ImmGen is
	signal type_I  : std_logic_vector(31 downto 0);
	signal type_S  : std_logic_vector(31 downto 0);
	signal type_SB : std_logic_vector(31 downto 0);
	signal type_U  : std_logic_vector(31 downto 0);
	signal type_UJ : std_logic_vector(31 downto 0);
  begin
	type_I  <= (31 downto 12 => i_ImmType(31)) & i_ImmType(31 downto 20);
	type_S  <= (31 downto 12 => i_ImmType(31)) & i_ImmType(31 downto 25) & i_ImmType(11 downto 7);
	type_SB <= (31 downto 12 => i_ImmType(31)) & i_ImmType(7) & i_ImmType(30 downto 25) & i_ImmType(11 downto 8) & '0';
	--type_U  <= i_ImmType(31 downto 12) & (11 downto 0 => '0');
	type_U <= (31 downto 31 => i_ImmType(31)) & i_ImmType(30 downto 12) & (11 downto 0 => '0');
	type_UJ <= (31 downto 20 => i_ImmType(31)) & i_ImmType(19 downto 12) & i_ImmType(20) & i_ImmType(30 downto 21) & '0';
	
	with i_ImmSel select
	  o_Imm <= type_I when "001",
		   type_S when "010",
		   type_SB when "011",
		   type_U when "100",
		   type_UJ when "101",
		   (others => '0') when others;
end behavioral;
