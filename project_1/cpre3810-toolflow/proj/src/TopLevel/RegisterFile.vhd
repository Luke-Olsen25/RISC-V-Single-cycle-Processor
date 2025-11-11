-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- RegisterFile.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: Structural implementation of a register file 
-- NOTES:
-- 9/15/2025
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RegisterFile is 
    port(
        i_RD1   : in std_logic_vector(4 downto 0);
        i_RS1   : in std_logic_vector(4 downto 0);
        i_RS2   : in std_logic_vector(4 downto 0);
        i_RST   : in STD_LOGIC;
        i_CLK   : in STD_LOGIC;
        wr_EN   : in STD_LOGIC;
        wr_DATA : in std_logic_vector(31 downto 0);
        o_RS1   : out std_logic_vector(31 downto 0);
        o_RS2   : out std_logic_vector(31 downto 0)
    );
end RegisterFile;

architecture regFile of RegisterFile is 
    
    -- component declaration --        
        component Reg_N 
            generic(N : integer := 32);
            port(
                i_CLK : in STD_LOGIC; -- clock input - 1 bit    
                i_RST : in STD_LOGIC; -- reset input - 1 bit
                i_WE  : in STD_LOGIC;
                i_D   : in std_logic_vector(N-1 downto 0);
                o_Q   : out std_logic_vector(N-1 downto 0)
                );
        end component;
       
        component mux32t1_N
            generic(N : integer := 32);
            port(
            i_S   : in  std_logic_vector(4 downto 0); 
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
        end component;
       
        component decoder_5to32
            port(
                i_I : in std_logic_vector(4 downto 0);
                o_O : out std_logic_vector(31 downto 0)
            );
        end component;
       
       
        -- signals --
        signal write_select_raw : std_logic_vector(31 downto 0) := (others => '0'); -- the output of the decoder 
        signal write_select : std_logic_vector(31 downto 0) := (others => '0'); -- the output of the decoder 
        type RegArray is array (0 to 31) of std_logic_vector(31 downto 0); -- the array of the 32 registers
        signal registers : RegArray; 
       
       
        begin

           
            -- stage 1 decoder --
            Decoder: decoder_5to32
                port map(
                    i_I => i_RD1,   
                    o_O => write_select_raw
                );
           
           
            write_select(0) <= '0'; 
            write_select(31 downto 1) <= write_select_raw(31 downto 1) when wr_EN = '1' else (others => '0');
           
            -- stage 2 registers --
            gen_registers: for i in 0 to 31 generate
            REG: Reg_N
                generic map(N => 32)
                port map(
                i_CLK => i_CLK,
                i_RST => i_RST,
                i_WE  => write_select(i),
                i_D   => wr_DATA,
                o_Q   => registers(i)
                );
        end generate;
       
            -- stage 3 mux1 --
            mux_1: mux32t1_N
                generic map(N => 32)
                port map(
                    i_S   => i_RS1,
                    i_D0  => (others => '0'), -- This correctly handles reads from x0
                    i_D1  => registers(1),
                    i_D2  => registers(2),
                    i_D3  => registers(3),
                    i_D4  => registers(4),
                    i_D5  => registers(5),
                    i_D6  => registers(6),
                    i_D7  => registers(7),
                    i_D8  => registers(8),
                    i_D9  => registers(9),
                    i_D10 => registers(10),
                    i_D11 => registers(11),
                    i_D12 => registers(12),
                    i_D13 => registers(13),
                    i_D14 => registers(14),
                    i_D15 => registers(15),
                    i_D16 => registers(16),
                    i_D17 => registers(17),
                    i_D18 => registers(18),
                    i_D19 => registers(19),
                    i_D20 => registers(20),
                    i_D21 => registers(21),
                    i_D22 => registers(22),
                    i_D23 => registers(23),
                    i_D24 => registers(24),
                    i_D25 => registers(25),
                    i_D26 => registers(26),
                    i_D27 => registers(27),
                    i_D28 => registers(28),
                    i_D29 => registers(29),
                    i_D30 => registers(30),
                    i_D31 => registers(31),
                    o_O   => o_RS1
                );
               
               
           
            -- stage 4 mux2 --
            mux_2: mux32t1_N
                generic map(N => 32)
                port map(
                    i_S   => i_RS2,
                    i_D0  => (others => '0'), -- This correctly handles reads from x0
                    i_D1  => registers(1),
                    i_D2  => registers(2),
                    i_D3  => registers(3),
                    i_D4  => registers(4),
                    i_D5  => registers(5),
                    i_D6  => registers(6),
                    i_D7  => registers(7),
                    i_D8  => registers(8),
                    i_D9  => registers(9),
                    i_D10 => registers(10),
                    i_D11 => registers(11),
                    i_D12 => registers(12),
                    i_D13 => registers(13),
                    i_D14 => registers(14),
                    i_D15 => registers(15),
                    i_D16 => registers(16),
                    i_D17 => registers(17),
                    i_D18 => registers(18),
                    i_D19 => registers(19),
                    i_D20 => registers(20),
                    i_D21 => registers(21),
                    i_D22 => registers(22),
                    i_D23 => registers(23),
                    i_D24 => registers(24),
                    i_D25 => registers(25),
                    i_D26 => registers(26),
                    i_D27 => registers(27),
                    i_D28 => registers(28),
                    i_D29 => registers(29),
                    i_D30 => registers(30),
                    i_D31 => registers(31),
                    o_O   => o_RS2
                );
           
end regFile;


