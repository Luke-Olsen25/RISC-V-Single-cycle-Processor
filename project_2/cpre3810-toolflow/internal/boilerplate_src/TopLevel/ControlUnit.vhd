-------------------------------------------------------------------
-- Control Unit:
-- Reference Schematic for signals
-------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity controlUnit is 
    port(
        c_IN     : in  std_logic_vector(31 downto 0);
        ImmSel   : out std_logic_vector(2 downto 0);
        s_RegWr  : out std_logic;
        BrUn     : out std_logic;
        Asel     : out std_logic;
        Bsel     : out std_logic;
	o_funct3 : out std_logic_vector(2 downto 0);
        ALUSel   : out std_logic_vector(3 downto 0);
        s_DMemWr : out std_logic;
        WBSel    : out std_logic_vector(1 downto 0);
	s_HALT	 : out std_logic;
	BR	 : out std_logic --indicates a branch is taken to be sent to and gate with result of branch comp logic
    );
end controlUnit;

architecture dataflow of controlUnit is
    signal opcode  : std_logic_vector(6 downto 0); -- bits 6:0
    signal funct3  : std_logic_vector(2 downto 0); -- bits 14:12
    signal funct7  : std_logic;                    -- bit 30
begin
    opcode <= c_IN(6 downto 0);
    funct3 <= c_IN(14 downto 12);
    funct7 <= c_IN(30);
    
    process(opcode, funct3)
    begin
        -- default values
        ImmSel   <= "000";
        s_RegWr  <= '0';
        BrUn     <= '0';
        Asel     <= '0';
        Bsel     <= '0';
        s_DMemWr <= '0';
        WBSel    <= "00";
	BR       <= '0';
	s_HALT <= '0';
	o_funct3 <= funct3;

        case opcode is
            when "0110011" =>  -- R-type
                s_RegWr <= '1';

            when "0010011" =>  -- I-type 
                ImmSel  <= "001";
                s_RegWr <= '1';
                Bsel    <= '1';
		WBSel <= "01";

            when "0000011" =>  -- Load 
                ImmSel  <= "010";
                s_RegWr <= '1';
                Bsel    <= '1';
                WBSel   <= "01";

            when "0100011" =>  -- Store 
                ImmSel   <= "011";
                Bsel     <= '1';
                s_DMemWr <= '1';

            when "1100011" =>  -- Branch 
                ImmSel <= "100";
                Asel   <= '1';
                WBSel  <= "00";
		BR     <= '1';
                if funct3 = "110" or funct3 = "111" then
                    BrUn <= '1';
                else
                    BrUn <= '0';
                end if;

            when "1101111" =>  -- JAL
                ImmSel  <= "101";
                s_RegWr <= '1';
                Asel    <= '1';
                Bsel    <= '1';
                WBSel   <= "10";

            when "1100111" =>  -- JALR
                ImmSel  <= "110";
                s_RegWr <= '1';
                Asel    <= '1';
                Bsel    <= '1';
                WBSel   <= "10";

            when "0110111" =>  -- LUI
                ImmSel  <= "111";
                s_RegWr <= '1';
                Asel    <= '1';
                Bsel    <= '1';
                WBSel   <= "10";

            when "0010111" =>  -- AUIPC
                ImmSel  <= "111";
                s_RegWr <= '1';
                Asel    <= '1';
                Bsel    <= '1';
                WBSel   <= "10";

            when "0010100" =>  -- HALT  (double check wanted Halt opcode in req)
		s_HALT   <= '1';

            when others =>
                ImmSel   <= "000";
        	s_RegWr  <= '0';
        	BrUn     <= '0';
        	Asel     <= '0';
        	Bsel     <= '0';
        	s_DMemWr <= '0';
        	WBSel    <= "00";
		s_HALT   <= '0';
        end case;
    end process;

    process(opcode, funct3, funct7)
    begin
        -- default ALU op
        ALUSel <= "0000";

        case opcode is
            when "0110011" =>  -- R-type 
                case funct3 is
                    when "000" =>
                        if funct7 = '1' then
                            ALUSel <= "0001"; -- sub
                        else
                            ALUSel <= "0000"; -- add
                        end if;
                    when "111" => ALUSel <= "0010"; -- and
                    when "110" => ALUSel <= "0011"; -- or
                    when "100" => ALUSel <= "0100"; -- xor
                    when "010" => ALUSel <= "0101"; -- slt
                    when "011" => ALUSel <= "0110"; -- sltu
                    when "001" => ALUSel <= "0111"; -- sll
                    when "101" =>  -- srl / sra for R-type
                        if funct7 = '1' then
                            ALUSel <= "1001"; -- sra
                        else
                            ALUSel <= "1000"; -- srl
                        end if;
                    when others => ALUSel <= "0000";
                end case;

            when "0010011" =>  -- I-type
                case funct3 is
                    when "000" => ALUSel <= "0000"; -- addi
                    when "010" => ALUSel <= "0101"; -- slti
                    when "011" => ALUSel <= "0110"; -- sltiu
                    when "111" => ALUSel <= "0010"; -- andi
                    when "110" => ALUSel <= "0011"; -- ori
                    when "100" => ALUSel <= "0100"; -- xori
                    when "001" => ALUSel <= "0111"; -- slli
                    when "101" =>  -- srli / srai for I-type
                        if funct7 = '1' then
                            ALUSel <= "1001"; -- srai
                        else
                            ALUSel <= "1000"; -- srli
                        end if;
                    when others => ALUSel <= "0000";
                end case;

            when others =>
                ALUSel <= "0000";
        end case;
    end process;
end dataflow;