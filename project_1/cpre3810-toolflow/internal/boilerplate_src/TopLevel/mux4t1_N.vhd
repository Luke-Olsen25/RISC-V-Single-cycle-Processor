-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux4t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file is the implementation of a 4 to 1 multiplexor
-- using a structural design with three 2 to 1 multiplexors 
--
-- NOTES:
-- 9/13/2025
------------------------------------------------------------------------- 
library IEEE;
use IEEE.std_logic_1164.all;

entity mux4t1_N is 
	generic(N : integer := 16);
	port(		
		i_S  : in  std_logic_vector(1 downto 0);  -- 2-bit select
		i_D0 : in  std_logic_vector(N-1 downto 0);
		i_D1 : in  std_logic_vector(N-1 downto 0);
		i_D2 : in  std_logic_vector(N-1 downto 0);
		i_D3 : in  std_logic_vector(N-1 downto 0);
		o_O  : out std_logic_vector(N-1 downto 0)
	);
end mux4t1_N;

architecture structural of mux4t1_N is
	component mux2t1 is
	port(i_S          : in std_logic;
       i_D0         : in std_logic;
       i_D1         : in std_logic;
       o_O          : out std_logic);
	end component;

  signal w_Y0, w_Y1 : std_logic_vector(N-1 downto 0);
begin
  -- First stage: select between D0/D1 and D2/D3
  G_LOW: for i in 0 to N-1 generate
    MUXI_LOW: mux2t1
      port map(
        i_S  => i_S(0),
        i_D0 => i_D0(i),
        i_D1 => i_D1(i),
        o_O  => w_Y0(i)
      );
  end generate;

  G_HIGH: for i in 0 to N-1 generate
    MUXI_HIGH: mux2t1
      port map(
        i_S  => i_S(0),
        i_D0 => i_D2(i),
        i_D1 => i_D3(i),
        o_O  => w_Y1(i)
      );
  end generate;

  -- Second stage: select between the two results
  G_OUT: for i in 0 to N-1 generate
    MUXI_OUT: mux2t1
      port map(
        i_S  => i_S(1),
        i_D0 => w_Y0(i),
        i_D1 => w_Y1(i),
        o_O  => o_O(i)
      );
  end generate;

end structural;




