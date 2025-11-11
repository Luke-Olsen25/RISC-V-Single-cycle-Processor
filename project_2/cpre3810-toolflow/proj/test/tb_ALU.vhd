-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_ALU.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: this is the testbench for the ALU
--              
-- 10/20/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity tb_ALU is
end tb_ALU;

architecture test of tb_ALU is

	component ALU is
		port(
			A	:	in std_logic_vector(31 downto 0); -- first data input
			B	:	in std_logic_vector(31 downto 0); -- second data input
			ALUCtrl	:	in std_logic_vector(3 downto 0); -- output of the alu control
			Result	:	out std_logic_vector(31 downto 0);
			zero	:	out std_logic
		);
	end component;
	signal i_A,i_B,ALU_Result : std_logic_vector(31 downto 0):= (others => '0');
	signal Ctrl : std_logic_vector(3 downto 0);
	signal o_zero : std_logic;
	
	begin
		
		DUT: ALU
			port map(
				A => i_A,
				B => i_B,
				ALUCtrl => Ctrl,
				Result => ALU_Result,
				zero => o_zero
			);
			
			
		stim_proc: process
			begin
			
			
			
				-- AND (ALUCtrl = "0010")
				-- Test1 
				Ctrl <= "0010";
				i_A <= x"F0F0F0F0";
				i_B <= x"F0F0F0F0";
				wait for 10 ns;
				-- Result = "F0F0F0F0"
				
				-- Test2 
				Ctrl <= "0010";
				i_A <= x"F0F0F0F0";
				i_B <= x"0F0F0F0F";
				wait for 10 ns;
				-- Result = "00000000"
				
				
				
				-- OR (ALUCtrl = "0011")
				-- Test1 
				Ctrl <= "0011";
				i_A <= x"F0F0F0F0";
				i_B <= x"0F0F0F0F";
				wait for 10 ns;
				-- Result = "FFFFFFFF"
				
				-- Test2 
				Ctrl <= "0011";
				i_A <= x"12345678";
				i_B <= x"30080000";
				wait for 10 ns;
				-- Result = "323C5678"
				
				
				
				-- XOR (ALUCtrl = "0100")
				-- Test1 
				Ctrl <= "0100";
				i_A <= x"AAAA5555";
				i_B <= x"AAAA5555";
				wait for 10 ns;
				-- Result = "00000000"
				
				-- Test2 
				Ctrl <= "0100";
				i_A <= x"F0F0F0F0";
				i_B <= x"0F0F0F0F";
				wait for 10 ns;
				-- Result = "FFFFFFFF"
				
				
				
				-- ADD (ALUCtrl = "0000")
				-- Test 
				Ctrl <= "0000";
				i_A <= x"00000005";
				i_B <= x"0000000A";
				wait for 10 ns;
				-- Result = "0000000F"
				
				
				
				-- SUB (ALUCtrl = "0001")
				-- Test 
				Ctrl <= "0001";
				i_A <= x"00000005";
				i_B <= x"0000000A";
				wait for 10 ns;
				-- Result = "FFFFFFFB"
				
				
				
				-- SLT A < B signed (ALUCtrl = "0101")
				-- Test1 
				Ctrl <= "0101";
				i_A <= x"FFFFFFFF";
				i_B <= x"0000000A";
				wait for 10 ns;
				-- Result = "00000001"
				
				-- Test2 
				Ctrl <= "0101";
				i_A <= x"0000000B";
				i_B <= x"0000000A";
				wait for 10 ns;
				-- Result = "0000000"
				
				
				
				-- SLTU A < B unsigned (ALUCtrl = "0110")
				-- Test1 
				Ctrl <= "0110";
				i_A <= x"FFFFFFFF";
				i_B <= x"0000000A";
				wait for 10 ns;
				-- Result = "0"
				
				-- Test2 
				Ctrl <= "0110";
				i_A <= x"0000000B";
				i_B <= x"FFFFFFFF";
				wait for 10 ns;
				-- Result = "1"
				
				
				
				-- SLL (ALUCtrl = "0111")
				-- Test1
				Ctrl <= "0111";
				i_A <= x"00000001";
				i_B <= x"00000001";
				wait for 10 ns;
				-- Result = "00000002"
				
				-- Test2
				Ctrl <= "0111";
				i_A <= x"00000001";
				i_B <= x"00000004";
				wait for 10 ns;
				-- Result = "00000010"

				
				
				-- SRL (ALUCtrl = "1000")
				-- Test1
				Ctrl <= "1000";
				i_A <= x"80000000";
				i_B <= x"00000001";
				wait for 10 ns;
				-- Result = "40000000"
				
				-- Test2 
				Ctrl <= "1000";
				i_A <= x"F0000000";
				i_B <= x"00000004";
				wait for 10 ns;
				-- Result = "0F000000"
				
				
				
				-- SRA (ALUCtrl = "1001")
				-- Test1 (sign extended)
				Ctrl <= "1001";
				i_A <= x"80000000";
				i_B <= x"00000001";
				wait for 10 ns;
				-- Result = "C0000000"
				
				-- Test2 (preserves sign)
				Ctrl <= "1001";
				i_A <= x"F0000000";
				i_B <= x"00000004";
				wait for 10 ns;
				-- Result = "FF000000"
				
				-- Test3 (no sign extended)
				Ctrl <= "1001";
				i_A <= x"7FFFFFFF";
				i_B <= x"00000004";
				wait for 10 ns;
				-- Result = "07FFFFFF"
			wait;
				
		end process;
end test;
			