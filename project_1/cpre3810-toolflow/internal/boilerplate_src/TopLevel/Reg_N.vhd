-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- Reg_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: this file is the N bit implementation of a register using a d flip flop
--
--
-- NOTES:
-- 9/9/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity Reg_N is 
	generic(N : integer := 32);
	port(
		i_CLK : in STD_LOGIC; -- clock input - 1 bit	
		i_RST : in STD_LOGIC; -- reset input - 1 bit
		i_WE  : in STD_LOGIC;
		i_D   : in std_logic_vector(N-1 downto 0);
		o_Q   : out std_logic_vector(N-1 downto 0)
	);
end Reg_N;

architecture structure of Reg_N is 
  component dffg is
  	port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic;     -- Data value input
       o_Q          : out std_logic);   -- Data value output

  end component;

	begin
	G_Nbit_Reg: for i in 0 to N-1 generate 
		Reg_N: dffg
			port map(
				i_CLK => i_CLK,
				i_RST => i_RST,
				i_WE  => i_WE, 
				i_D   => i_D(i),
				o_Q   => o_Q(i)
			);
	end generate G_Nbit_Reg;
end structure;
	
	
