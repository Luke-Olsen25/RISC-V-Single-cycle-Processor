-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_barrelshifter.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  
use IEEE.numeric_std.all;
library std;
use std.env.all;                
use std.textio.all;             


entity tb_barrelShifter is
end tb_barrelShifter;

architecture mixed of tb_barrelShifter is

  component barrelShifter is
	port(
        i_SHIFT : in  std_logic_vector(4 downto 0);   -- shift amount
        ALUsel : in std_logic_vector(3 downto 0); --type of shift
	i_D   : in  std_logic_vector(31 downto 0);  -- input data
        o_O   : out std_logic_vector(31 downto 0)   -- shifted output
    );
  end component;


-- change input and output signals as needed.
  signal i_SHIFT : std_logic_vector(4 downto 0); 
  signal ALUsel : std_logic_vector(3 downto 0);
  signal i_D : std_logic_vector(31 downto 0);
  signal o_O : std_logic_vector(31 downto 0);

 begin

  -- Actually instantiate the component to test 
  DUT0 : barrelShifter
   port map(
	 i_SHIFT => i_SHIFT,
	 ALUsel => ALUsel,
	 i_D => i_D,
	 o_O => o_O);


  P_TEST_CASES: process
  begin

    -- TEST 1: Logical left shift
    -----------------------------------------------------------------
    i_D     <= x"000000F0";     -- 0000...11110000
    ALUsel  <= "0000";          -- logical left
    i_SHIFT <= "00001";         -- shift by 1
    wait for 100 ns;

    -- TEST 2: Logical right shift
    -----------------------------------------------------------------
    i_D     <= x"F0000000";     -- 1111...0000
    ALUsel  <= "0001";          -- logical right
    i_SHIFT <= "00010";         -- shift by 2
    wait for 100 ns;

    -- TEST 3: Arithmetic right shift (with sign bit 1)
    -----------------------------------------------------------------
    i_D     <= x"F0000000";     -- MSB = 1
    ALUsel  <= "1001";          -- arithmetic right
    i_SHIFT <= "00100";         -- shift by 4
    wait for 100 ns;

    -- TEST 4: Arithmetic right shift (with sign bit 0)
    -----------------------------------------------------------------
    i_D     <= x"0F000000";     -- MSB = 0
    ALUsel  <= "1001";
    i_SHIFT <= "00100";
    wait for 100 ns;

    -- TEST 5: Logical left shift by large amount (edge case)
    -----------------------------------------------------------------
    i_D     <= x"0000FFFF";
    ALUsel  <= "0000";
    i_SHIFT <= "11111";         -- shift by 31
    wait for 100 ns;

    -- TEST 6: Logical right shift by large amount
    -----------------------------------------------------------------
    i_D     <= x"80000000";     -- MSB = 1
    ALUsel  <= "0001";
    i_SHIFT <= "11111";         -- shift by 31
    wait for 100 ns;

    -- TEST 7: Arithmetic right shift by large amount
    -----------------------------------------------------------------
    i_D     <= x"80000000";     -- MSB = 1
    ALUsel  <= "1001";
    i_SHIFT <= "11111";         -- shift by 31
    wait for 100 ns;

    -- TEST 8: Zero input
    -----------------------------------------------------------------
    i_D     <= (others => '0');
    ALUsel  <= "0000";
    i_SHIFT <= "01010";         -- arbitrary shift
    wait for 100 ns;

    -- TEST 9: Random middle shift
    -----------------------------------------------------------------
    i_D     <= x"A5A5A5A5";     -- pattern test
    ALUsel  <= "0000";
    i_SHIFT <= "00101";         -- shift by 5
    wait for 100 ns;

    wait;
  end process;

end mixed;
