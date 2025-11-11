-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_ControlUnit.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  
use IEEE.numeric_std.all;
library std;
use std.env.all;                
use std.textio.all;             


entity tb_ControlUnit is

end tb_controlUnit;

architecture mixed of tb_ControlUnit is

  component ControlUnit is
		-- control data will grab these bits from bus 9[6:0] & 9[30, 14:12]. Reference schematic
	port(   c_IN : in std_logic_vector(31 downto 0); 
		ImmSel : out std_logic_vector(2 downto 0);
		s_RegWr : out std_logic;
		BrUn : out std_logic;
		Asel : out std_logic;
		Bsel : out std_logic;
		ALUSel : out std_logic_vector(3 downto 0);
		s_DMemWr : out std_logic;
		WBSel : out std_logic_vector(1 downto 0));
  end component;


-- change input and output signals as needed.
  signal c_IN : std_logic_vector(31 downto 0) := (others => '0'); 
  signal ImmSel : std_logic_vector(2 downto 0);
  signal s_RegWr : std_logic;
  signal BrUn : std_logic;
  signal Asel : std_logic;
  signal Bsel : std_logic;
  signal ALUSel : std_logic_vector(3 downto 0);
  signal s_DMemWr : std_logic;
  signal WBSel : std_logic_vector(1 downto 0);

 begin

  -- Actually instantiate the component to test 
  DUT0 : ControlUnit
   port map(
	 c_IN => c_IN,  
	 ImmSel => ImmSel,
	 s_RegWr => s_RegWr,
	 BrUn => BrUn,
	 Asel => Asel,
	 BSel => Bsel,
	 s_DMemWr => s_DMemWr,
	 WBSel => WBSel,
	 ALUSel => ALUSel);


  P_TEST_CASES: process
  begin

	-- Test cases consist of testing control for each instr type
	-- add, addi, and, andi, lui, lw, xor, xori, or, ori, slt, slti, sltiu, sll
	-- srl, sra, sw, sub, beq, bne, blt, bge, bltu, bgeu, jal, jalr, lb, lh, lbu,
	-- lhu, slli, srli, srai, auipc, wfi (or HALT)

        -- add
        c_IN <= x"003100b3"; wait for 100 ns;
        -- addi
        c_IN <= x"00510093"; wait for 100 ns;
        -- and
        c_IN <= x"003170b3"; wait for 100 ns;
        -- andi
        c_IN <= x"00517093"; wait for 100 ns;
        -- lui
        c_IN <= x"123450b7"; wait for 100 ns;
        -- lw
        c_IN <= x"00012083"; wait for 100 ns;
        -- xor
        c_IN <= x"003140b3"; wait for 100 ns;
        -- xori
        c_IN <= x"00514093"; wait for 100 ns;
        -- or
        c_IN <= x"003160b3"; wait for 100 ns;
        -- ori
        c_IN <= x"00516093"; wait for 100 ns;
        -- slt
        c_IN <= x"003120b3"; wait for 100 ns;
        -- slti
        c_IN <= x"00512093"; wait for 100 ns;
        -- sltiu
        c_IN <= x"00513093"; wait for 100 ns;
        -- sll
        c_IN <= x"003110b3"; wait for 100 ns;
        -- srl
        c_IN <= x"003150b3"; wait for 100 ns;
        -- sra
        c_IN <= x"403150b3"; wait for 100 ns;
        -- sw
        c_IN <= x"00112023"; wait for 100 ns;
        -- sub
        c_IN <= x"403100b3"; wait for 100 ns;
        -- beq
        c_IN <= x"00310263"; wait for 100 ns;
        -- bne
        c_IN <= x"00311263"; wait for 100 ns;
        -- blt
        c_IN <= x"00314263"; wait for 100 ns;
        -- bge
        c_IN <= x"00315263"; wait for 100 ns;
        -- bltu
        c_IN <= x"00316263"; wait for 100 ns;
        -- bgeu
        c_IN <= x"00317263"; wait for 100 ns;
        -- jal
        c_IN <= x"004000ef"; wait for 100 ns;
        -- jalr
        c_IN <= x"000100e7"; wait for 100 ns;
        -- lb
        c_IN <= x"00010083"; wait for 100 ns;
        -- lh
        c_IN <= x"00011083"; wait for 100 ns;
        -- lbu
        c_IN <= x"00014083"; wait for 100 ns;
        -- lhu
        c_IN <= x"00015083"; wait for 100 ns;
        -- slli
        c_IN <= x"02011093"; wait for 100 ns;
        -- srli
        c_IN <= x"02015093"; wait for 100 ns;
        -- srai
        c_IN <= x"42015093"; wait for 100 ns;
        -- auipc
        c_IN <= x"12345097"; wait for 100 ns;
        -- wfi
        c_IN <= x"10500073"; wait for 100 ns;

    wait;
  end process;

end mixed;
