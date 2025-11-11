-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_FetchLogic.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: this is the test bench for the fetch logic
--              
-- 10/07/2025
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_FetchLogic is
end tb_FetchLogic;

architecture behavior of tb_FetchLogic is

    -- DUT component
    component FetchLogic is
        port(
            rst    : in  std_logic;
            clk    : in  std_logic;
            imm    : in  std_logic_vector(31 downto 0);
            ALUo   : in  std_logic_vector(31 downto 0);
            PCsrc  : in  std_logic_vector(1 downto 0);
            currPC : out std_logic_vector(31 downto 0);
            instr  : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Internal test signals
    signal rst, clk : std_logic := '0';
    signal imm, ALUo, currPC, instr : std_logic_vector(31 downto 0);
    signal PCsrc : std_logic_vector(1 downto 0) := "00";

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: FetchLogic
    port map(
        rst    => rst,
        clk    => clk,
        imm    => imm,
        ALUo   => ALUo,
        PCsrc  => PCsrc,
        currPC => currPC,
        instr  => instr
    );

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;




    stim_proc : process
        begin
            -- Initialize
            rst <= '1';
            imm <= (others => '0');
            ALUo <= (others => '0');
            wait for 20 ns;
            rst <= '0';
            wait for clk_period * 2;

            -- Normal sequential PC increment (PCsrc = "00")
            PCsrc <= "00";
            wait for clk_period * 4;

            -- Branch test (PCsrc = "01")
            imm <= x"00000010";  -- forward branch of +8 bytes
            PCsrc <= "01";
            wait for clk_period * 2;

            -- Jump test (PCsrc = "10")
            imm <= x"FFFFFFF8";  -- backward jump (-8 bytes)
            PCsrc <= "10";
            wait for clk_period * 2;

            -- Jalr test (PCsrc = "11")
            ALUo <= x"00000040";  -- absolute jump to 0x40
            PCsrc <= "11";
            wait for clk_period * 2;



            wait;
        end process;

    end behavior;


