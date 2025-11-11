-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- full_adder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file is the structural implementation of a full adder
--              
-- 09/01/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Full_Adder is 
	port(
		i_A, i_B : in STD_LOGIC;
		i_C : in STD_LOGIC;
		o_S : out STD_LOGIC;
		o_C : out STD_LOGIC
	);
end Full_Adder;

architecture structure of Full_Adder is

	-- or gate --
	component org2
		port(
			i_A, i_B : in STD_LOGIC;
			o_F : out STD_LOGIC
		);
	end component;
	
	-- and gate --
	component andg2
		port(
			i_A, i_B : in STD_LOGIC;
			o_F : out STD_LOGIC
		);
	end component;
	
	-- xor gate --
	component xorg2
		port(
			i_A, i_B : in STD_LOGIC;
			o_F : out STD_LOGIC
		);
	end component;
	
	-- internal signals --
	signal AxorB : STD_LOGIC;
	signal AandB : STD_LOGIC;
	signal Cfinal  : STD_LOGIC;
	
begin 
	-- A xor B --
	U1: xorg2 port map( i_A => i_A, i_B => i_B, o_F => AxorB);
	
	-- A xor B xor C --
	U2: xorg2 port map(i_A => AxorB, i_B => i_C, o_F => o_S);
	
	-- A and B --
	U3: andg2 port map(i_A => i_A, i_B => i_B, o_F => AandB);
	
	-- A xor B and C --
	U4: andg2 port map(i_A => AxorB, i_B => i_C, o_F => Cfinal);
	
	-- A and B or A xor B and C --
	U5: org2 port map(i_A => AandB, i_B => Cfinal, o_F => o_C);

end structure; 
	