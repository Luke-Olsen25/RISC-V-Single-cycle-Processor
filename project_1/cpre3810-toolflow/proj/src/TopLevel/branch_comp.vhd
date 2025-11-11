--------------------------------------------------
--Branch compare logic block
--------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity branch_comp is 
  port(
    i_A : in std_logic_vector(31 downto 0);
    i_B : in std_logic_vector(31 downto 0);
    i_funct3 : in std_logic_vector(2 downto 0);
    i_BrUn : in std_logic;
    o_Branch : out std_logic
  );
end branch_comp;

architecture dataflow of branch_comp is
    signal signed_A, signed_B : signed(31 downto 0);     
    signal unsigned_A, unsigned_B : unsigned(31 downto 0);
begin
    signed_A <= signed(i_A);
    signed_B <= signed(i_B);
    unsigned_A <= unsigned(i_A);
    unsigned_B <= unsigned(i_B);
    
  process(i_funct3, i_BrUn, signed_A, signed_B, unsigned_A, unsigned_B, i_A, i_B)
  begin
    o_Branch <= '0'; -- Default to no branch
    
    case i_funct3 is 
      when "000" =>  -- beq
        if i_A = i_B then
          o_Branch <= '1';
        end if;

      when "001" =>  -- bne
        if i_A /= i_B then
          o_Branch <= '1';
        end if;

      when "100" =>  -- blt (signed)
        if signed_A < signed_B then
          o_Branch <= '1';
        end if;

      when "101" =>  -- bge (signed)
        if signed_A >= signed_B then
          o_Branch <= '1';
        end if;

      when "110" => -- bltu (unsigned)
        if unsigned_A < unsigned_B then
          o_Branch <= '1';
        end if;

      when "111" => -- bgeu (unsigned)
        if unsigned_A >= unsigned_B then
          o_Branch <= '1';
        end if;

      when others =>
        o_Branch <= '0';
    end case;
  end process;
end dataflow;

