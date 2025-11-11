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

entity N_Full_Adder is 
	generic(N : integer := 16);
	port(
		i_A, i_B : in std_logic_vector(N-1 downto 0);
		i_C : in STD_LOGIC;
		o_S : out std_logic_vector(N-1 downto 0);
		o_C : out STD_LOGIC
	);
end N_Full_Adder;

architecture structure of N_Full_Adder is
	
	component Full_Adder
		port(
			i_A, i_B, i_C : in STD_LOGIC;
            o_S, o_C : out STD_LOGIC
		);
	end component;
	
	signal carry : std_logic_vector(N downto 0);
	
	
begin 
	
	carry(0) <= i_C;
	
	gen_adders: for i in 0 to N-1 generate
		ADDI: Full_Adder
			port map(
				i_A => i_A(i),
                i_B => i_B(i),
                i_C => carry(i),
                o_S => o_S(i),
                o_C => carry(i+1)
			);
	
	end generate;
	o_C <= carry(N);

end structure; 
	