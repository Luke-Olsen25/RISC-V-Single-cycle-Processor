-------------------------------------------------------------------------
-- Luke Olsen
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- barrelShifter.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 2:1
-- mux using structural VHDL, 2andg, 2org, notg
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity barrelShifter is
    port(
        i_SHIFT   : in  std_logic_vector(4 downto 0);   -- shift amount
        ALUsel : in std_logic_vector(3 downto 0);
	i_D   : in  std_logic_vector(31 downto 0);  -- input data
        o_O   : out std_logic_vector(31 downto 0)   -- shifted output
    );
end barrelShifter;

architecture structural of barrelShifter is

    component mux2t1
        port(
            i_S  : in  std_logic;
            i_D0 : in  std_logic;
            i_D1 : in  std_logic;
            o_O  : out std_logic
        );
    end component;

    signal fill_bit : std_logic;
    signal i_DIR: std_logic;

    signal s2, s4, s8, s16     : std_logic_vector(31 downto 0) := (others => '0');
    signal i_flipped, o_flipped, s_SHIFTIN, s_SHIFTOUT : std_logic_vector(31 downto 0) := (others => '0');

begin

    -- Fill bit: type shift
    --fill_bit <= ALUsel(3) and i_D(31);
    fill_bit <= i_D(31) when (ALUsel(3) = '1' and i_DIR = '1') else
		i_D(0) when (ALUsel(3) = '1' and i_DIR = '0') else
		'0';

    i_DIR <= ALUsel(0); --check ALUsrc in control unit for correct bits for dir and fill

    -- flipped input as hinted to in the porject pdf
    gen_f_input: for i in 0 to 31 generate
        i_flipped(i) <=  i_D(31-i);
    end generate;

    -- input mux
    gen_input: for i in 0 to 31 generate
	mux_input: component mux2t1
	    port map(
		i_S => i_DIR,
		i_D0 => i_D(i),
		i_D1 => i_flipped(i),
		o_O => s_SHIFTIN(i)
	    );
    end generate;


    -- Stage 4: 
    gen_s4: for i in 0 to 31 generate
	signal s16_t : std_logic;
    begin
	gen_shift_16: if i >= 16 generate
        	s16_t <= s_SHIFTIN(i-16);
    	end generate gen_shift_16;
    	gen_fill_16: if i < 16 generate
            s16_t <= fill_bit;
        end generate gen_fill_16;
        mux4: mux2t1
            port map(
                i_S  => i_SHIFT(4),
                i_D0 => s_SHIFTIN(i),
                i_D1 => s16_t,
                o_O  => s16(i)
            );
    end generate;

   -- Stage 3: 
    gen_s3: for i in 0 to 31 generate
	signal s8_t : std_logic;
    begin
	gen_shift_8: if i >= 8 generate
            s8_t <= s16(i-8);
        end generate gen_shift_8;
        gen_fill_8: if i < 8 generate
            s8_t <= fill_bit;
        end generate gen_fill_8;
        mux4: mux2t1
            port map(
                i_S  => i_SHIFT(3),
                i_D0 => s16(i),
                i_D1 => s8_t,
                o_O  => s8(i)
            );
    end generate;

  -- Stage 2: 
    gen_s2: for i in 0 to 31 generate
	signal s4_t : std_logic;
    begin
	gen_shift_4: if i >= 4 generate
            s4_t <= s8(i-4);
        end generate gen_shift_4;
        gen_fill_4: if i < 4 generate
            s4_t <= fill_bit;
        end generate gen_fill_4;
        mux4: mux2t1
            port map(
                i_S  => i_SHIFT(2),
                i_D0 => s8(i),
                i_D1 => s4_t,
                o_O  => s4(i)
            );
    end generate;

  -- Stage 1: 
    gen_s1: for i in 0 to 31 generate
	signal s2_t : std_logic;
    begin
	gen_shift_2: if i >= 2 generate
            s2_t <= s4(i-2);
        end generate gen_shift_2;
        gen_fill_2: if i < 2 generate
            s2_t <= fill_bit;
        end generate gen_fill_2;
        mux4: mux2t1
            port map(
                i_S  => i_SHIFT(1),
                i_D0 => s4(i),
                i_D1 => s2_t,
                o_O  => s2(i)
            );
    end generate;

  -- Stage 0: 
    gen_s0: for i in 0 to 31 generate
	signal s1_t : std_logic;
    begin
	gen_shift_1: if i >= 1 generate
            s1_t <= s2(i-1);
        end generate gen_shift_1;
        gen_fill_1: if i < 1 generate
            s1_t <= fill_bit;
        end generate gen_fill_1;
        mux4: mux2t1
            port map(
                i_S  => i_SHIFT(0),
                i_D0 => s2(i),
                i_D1 => s1_t,
                o_O  => s_SHIFTOUT(i)
            );
    end generate;

      -- flipped input as hinted to in the project pdf
    gen_f_output: for i in 0 to 31 generate
        o_flipped(i) <=  s_SHIFTOUT(31-i);
    end generate;  

    gen_output: for i in 0 to 31 generate
	mux_output: component mux2t1
	    port map(
		i_S => i_DIR,
		i_D0 => s_SHIFTOUT(i), --normal right shift
		i_D1 => o_flipped(i), --flipped left shift
		o_O => o_O(i)
	    );
    end generate;

end structural;
