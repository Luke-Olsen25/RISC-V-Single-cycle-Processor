-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux2to1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 2:1
-- mux using structural VHDL, 2andg, 2org, notg
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux2t1 is
  port(i_S          : in std_logic;
       i_D0         : in std_logic;
       i_D1         : in std_logic;
       o_O          : out std_logic);
end mux2t1;

architecture structural of mux2t1 is

  component andg2 is
    port(i_A                 : in std_logic;
         i_B                 : in std_logic;
         o_F                  : out std_logic);
  end component;

  component org2 is
    port(i_A                 : in std_logic;
         i_B                 : in std_logic;
         o_F                  : out std_logic);
  end component;

  component invg is
    port(i_A                  : in std_logic;
         o_F                   : out std_logic);
  end component;

  signal s_nS	: std_logic;
  signal s_and0 : std_logic;
  signal s_and1 : std_logic;

begin

  g_and1: andg2
	port MAP(i_A	=>	s_nS,
		 i_B	=>	i_D0,
		 o_F	=>	s_and0);

  g_and2: andg2
	port MAP(i_A	=>	i_S,
		 i_B	=>	i_D1,
		 o_F	=>	s_and1);

  g_not: invg
	port MAP(i_A	=>	i_S,
		 o_F	=>	s_nS);

  g_or: org2
	port MAP(i_A	=>	s_and0,
		 i_B	=>	s_and1,
		 o_F	=>	o_O);
  
end structural;
