-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- nAdd_Sub.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: this file recieves a select bit for either addition or subtraction
--              
-- 09/06/2025
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity nAdd_Sub is 
	generic(N : integer := 16);
	port(
		i_A, i_B : in std_logic_vector(N-1 downto 0);
		nAdd_sub : in STD_LOGIC;
		Sum : out std_logic_vector(N-1 downto 0);
		Cout : out STD_LOGIC
	);
end nAdd_Sub;

architecture structure of nAdd_Sub is

	signal B_not : std_logic_vector(N-1 downto 0);
    signal Bx    : std_logic_vector(N-1 downto 0);
 
		

		
		component mux2t1_N
			generic(N : integer := 16);
			port(
				i_S : in STD_LOGIC;
				i_D0, i_D1 : in std_logic_vector(N-1 downto 0);
				o_O : out std_logic_vector(N-1 downto 0)
			);
		end component;
		
		component N_Full_Adder
			generic(N : integer := 16);
			port(
				i_A, i_B : in std_logic_vector(N-1 downto 0);
				i_C : in STD_LOGIC;
				o_S : out std_logic_vector(N-1 downto 0);
				o_C : out STD_LOGIC
			);
		end component;
		
		
		begin
		
		
		  
		B_not <= not i_B;

		

		  
		mux_inst : mux2t1_N
			generic map(N => N)
			port map(
			  i_S  => nAdd_sub,
			  i_D0 => i_B,      
			  i_D1 => B_not,    
			  o_O  => Bx
			);

		  
		adder_inst : N_Full_Adder
			generic map(N => N)
			port map(
			  i_A => i_A,
			  i_B => Bx,
			  i_C => nAdd_sub,  
			  o_S => Sum,
			  o_C => Cout
			);

end architecture structure;

	