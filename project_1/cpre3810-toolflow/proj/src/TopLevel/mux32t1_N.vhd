-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux32t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 32-to-1 N-bit wide multiplexer using 4:1 and 2:1 muxes
-- NOTES:
-- 9/13/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux32t1_N is
    generic(N : integer := 32);
    port(
        i_S  : in  std_logic_vector(4 downto 0); 
        i_D0  : in  std_logic_vector(N-1 downto 0);
        i_D1  : in  std_logic_vector(N-1 downto 0);
        i_D2  : in  std_logic_vector(N-1 downto 0);
        i_D3  : in  std_logic_vector(N-1 downto 0);
        i_D4  : in  std_logic_vector(N-1 downto 0);
        i_D5  : in  std_logic_vector(N-1 downto 0);
        i_D6  : in  std_logic_vector(N-1 downto 0);
        i_D7  : in  std_logic_vector(N-1 downto 0);
        i_D8  : in  std_logic_vector(N-1 downto 0);
        i_D9  : in  std_logic_vector(N-1 downto 0);
        i_D10 : in  std_logic_vector(N-1 downto 0);
        i_D11 : in  std_logic_vector(N-1 downto 0);
        i_D12 : in  std_logic_vector(N-1 downto 0);
        i_D13 : in  std_logic_vector(N-1 downto 0);
        i_D14 : in  std_logic_vector(N-1 downto 0);
        i_D15 : in  std_logic_vector(N-1 downto 0);
        i_D16 : in  std_logic_vector(N-1 downto 0);
        i_D17 : in  std_logic_vector(N-1 downto 0);
        i_D18 : in  std_logic_vector(N-1 downto 0);
        i_D19 : in  std_logic_vector(N-1 downto 0);
        i_D20 : in  std_logic_vector(N-1 downto 0);
        i_D21 : in  std_logic_vector(N-1 downto 0);
        i_D22 : in  std_logic_vector(N-1 downto 0);
        i_D23 : in  std_logic_vector(N-1 downto 0);
        i_D24 : in  std_logic_vector(N-1 downto 0);
        i_D25 : in  std_logic_vector(N-1 downto 0);
        i_D26 : in  std_logic_vector(N-1 downto 0);
        i_D27 : in  std_logic_vector(N-1 downto 0);
        i_D28 : in  std_logic_vector(N-1 downto 0);
        i_D29 : in  std_logic_vector(N-1 downto 0);
        i_D30 : in  std_logic_vector(N-1 downto 0);
        i_D31 : in  std_logic_vector(N-1 downto 0);
        o_O   : out std_logic_vector(N-1 downto 0)
    );
end mux32t1_N;

architecture structural of mux32t1_N is
	component mux2t1_N is
  	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  	port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0)
	);

	end component;

	component mux4t1_N is 
	generic(N : integer := 16);
	port(		
		i_S  : in  std_logic_vector(1 downto 0);  -- 2-bit select
		i_D0 : in  std_logic_vector(N-1 downto 0);
		i_D1 : in  std_logic_vector(N-1 downto 0);
		i_D2 : in  std_logic_vector(N-1 downto 0);
		i_D3 : in  std_logic_vector(N-1 downto 0);
		o_O  : out std_logic_vector(N-1 downto 0)
	);
	end component;
    

    type stage1_array is array (0 to 7) of std_logic_vector(N-1 downto 0);
    type stage2_array is array (0 to 1) of std_logic_vector(N-1 downto 0);
    signal stage1 : stage1_array;
    signal stage2 : stage2_array;
    type input_array is array (0 to 31) of std_logic_vector(N-1 downto 0);
    signal inputs : input_array;

begin


    inputs(0)  <= i_D0;   inputs(1)  <= i_D1;   inputs(2)  <= i_D2;   inputs(3)  <= i_D3;
    inputs(4)  <= i_D4;   inputs(5)  <= i_D5;   inputs(6)  <= i_D6;   inputs(7)  <= i_D7;
    inputs(8)  <= i_D8;   inputs(9)  <= i_D9;   inputs(10) <= i_D10;  inputs(11) <= i_D11;
    inputs(12) <= i_D12;  inputs(13) <= i_D13;  inputs(14) <= i_D14;  inputs(15) <= i_D15;
    inputs(16) <= i_D16;  inputs(17) <= i_D17;  inputs(18) <= i_D18;  inputs(19) <= i_D19;
    inputs(20) <= i_D20;  inputs(21) <= i_D21;  inputs(22) <= i_D22;  inputs(23) <= i_D23;
    inputs(24) <= i_D24;  inputs(25) <= i_D25;  inputs(26) <= i_D26;  inputs(27) <= i_D27;
    inputs(28) <= i_D28;  inputs(29) <= i_D29;  inputs(30) <= i_D30;  inputs(31) <= i_D31;

    gen_stage1: for i in 0 to 7 generate
        MUX4_STAGE1: mux4t1_N
            generic map(N => N)
            port map(
                i_S  => i_S(1 downto 0),
                i_D0 => inputs(i*4 + 0),
                i_D1 => inputs(i*4 + 1),
                i_D2 => inputs(i*4 + 2),
                i_D3 => inputs(i*4 + 3),
                o_O  => stage1(i)
            );
    end generate;


    gen_stage2: for i in 0 to 1 generate
        MUX4_STAGE2: mux4t1_N
            generic map(N => N)
            port map(
                i_S  => i_S(3 downto 2),
                i_D0 => stage1(i*4 + 0),
                i_D1 => stage1(i*4 + 1),
                i_D2 => stage1(i*4 + 2),
                i_D3 => stage1(i*4 + 3),
                o_O  => stage2(i)
            );
    end generate;

    MUX_FINAL: mux2t1_N
        generic map(N => N)
        port map(
            i_S  => i_S(4),
            i_D0 => stage2(0),
            i_D1 => stage2(1),
            o_O  => o_O
        );

end structural;
