-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- InstructionMemory.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: this is the Instruction memory go to instructionmem.vhd to get the memory with hardcoded instructions for testing
--              
-- 10/07/2025
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity InstructionMemory is
	port(
        	clk          :   in std_logic;
		s_IMemAddr   :   in std_logic_vector(11 downto 2); -- PC[11:2]
		s_Inst       :   out std_logic_vector(31 downto 0); -- Instruction
		iInstLd	     :	 in std_logic;
		iInstExt     :	 in std_logic_vector(31 downto 0)
	);
end InstructionMemory;
architecture behavioral of InstructionMemory is

begin
 iMEM: entity work.mem
     port map(
         clk  => clk,
         addr => s_IMemAddr,
         data => iInstExt,
         we   => iInstLd,
         q    => s_Inst
     );
end behavioral;
        	
