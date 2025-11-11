-------------------------------------------------------------------------
-- Matthew Estes
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ALU.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: this is the structural implementation of the ALU
--              
-- 10/19/2025
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity ALU is 
	port(
		A	:	in std_logic_vector(31 downto 0); -- first data input
		B	:	in std_logic_vector(31 downto 0); -- second data input
		ALUCtrl	:	in std_logic_vector(3 downto 0); -- output of the alu control
		Result	:	out std_logic_vector(31 downto 0);
		zero	:	out std_logic;
		Cout	:	out std_logic
	);
end ALU;

architecture structural of ALU is 


	component org2
		port(
			i_A	: in std_logic;
			i_B	: in std_logic;
			o_F	: out std_logic
		);
	end component;
	
	component xorg2
		port(
			i_A          : in std_logic;
		        i_B          : in std_logic;
		        o_F          : out std_logic
		);
	end component;
	
	component andg2
		port(
			i_A          : in std_logic;
       			i_B          : in std_logic;
       			o_F          : out std_logic
		);
	end component;
	
	component nAdd_Sub
		generic(N : integer := 32);
		port(
			i_A, i_B : in std_logic_vector(N-1 downto 0);
			nAdd_sub : in STD_LOGIC;
			Sum : out std_logic_vector(N-1 downto 0);
			Cout : out STD_LOGIC
		);
	end component;
	
	component BarrelShifter
		port(
			i_SHIFT   : in  std_logic_vector(4 downto 0);   -- shift amount
			ALUsel : in std_logic_vector(3 downto 0);
			i_D   : in  std_logic_vector(31 downto 0);  -- input data
			o_O   : out std_logic_vector(31 downto 0)   -- shifted output
		);
	end component;

		signal and_result : std_logic_vector(31 downto 0);
		signal or_result : std_logic_vector(31 downto 0);
		signal xor_result : std_logic_vector(31 downto 0);
        signal add_result : std_logic_vector(31 downto 0);
        signal sub_result : std_logic_vector(31 downto 0);
		signal sll_result : std_logic_vector(31 downto 0);
		signal srl_result : std_logic_vector(31 downto 0);
		signal sra_result : std_logic_vector(31 downto 0);
        signal temp_carry_out : std_logic;
        signal add_ctrl, sub_ctrl : std_logic;
        signal slt_out, sltu_out : std_logic_vector(31 downto 0);
		signal sll_ctrl : std_logic_vector(3 downto 0);
		signal srl_ctrl : std_logic_vector(3 downto 0);
		signal sra_ctrl : std_logic_vector(3 downto 0);
		signal shift_amount : std_logic_vector(4 downto 0);
		signal temp_result, zero_result, u_A : std_logic_vector(31 downto 0);
	
		

begin
		sll_ctrl <= "0000";
		srl_ctrl <= "0001";
		sra_ctrl <= "1001";
	    add_ctrl <= '0';
	    sub_ctrl <= '1';
		shift_amount <= B(4 downto 0);
		zero_result <= (others => '0');
		
	    -- and
	    and_gen: for i in 0 to 31 generate
		and_inst: andg2 
		port map(
		    i_A => A(i),
		    i_B => B(i),
		    o_F => and_result(i)
		);
	    end generate;

	    -- or
	    or_gen: for i in 0 to 31 generate
		or_inst: org2 
		port map(
		    i_A => A(i),
		    i_B => B(i),
		    o_F => or_result(i)
		);
	    end generate;
	    
	    -- xor
	    xor_gen: for i in 0 to 31 generate
		xor_inst: xorg2 
		port map(
		    i_A => A(i),
		    i_B => B(i),
		    o_F => xor_result(i)
		);
	    end generate;

	    -- add/sub
	    add_inst: nAdd_Sub
		generic map(N => 32)
		port map(
		    i_A => A,
		    i_B => B,
		    nAdd_sub => add_ctrl,
		    Sum => add_result,
		    Cout => temp_carry_out
		);
	   sub_inst: nAdd_Sub
		generic map(N => 32)
		port map(
		    i_A => A,
		    i_B => B,
		    nAdd_sub => sub_ctrl,
		    Sum => sub_result,
		    Cout => temp_carry_out
		);
		
		-- SLL == 1001, SRL = 1010, SRA = 1011
		-- SLT
			
		slt_logic_proc : process (A, B)
		begin
			-- First, set the default for all bits
			slt_out <= (others => '0');
			
			-- Then, override bit 0 if the condition is true
			if (signed(A) < signed(B)) then
				slt_out(0) <= '1';
			end if;
		end process slt_logic_proc;

		-- SLTU
		-- SLTU
		sltu_logic_proc : process (A, B)
		begin
			-- First, set the default for all bits
			sltu_out <= (others => '0');

			-- Then, override bit 0 if the condition is true
			if (unsigned(A) < unsigned(B)) then
				sltu_out(0) <= '1';
			end if;
		end process sltu_logic_proc;

		
		-- SLL
		sll_inst: BarrelShifter
			port map(
				i_SHIFT => shift_amount,
				ALUsel => sll_ctrl,
				i_D => A,
				o_O => sll_result
			);
		
		-- SRL
		srl_inst: BarrelShifter
			port map(
				i_SHIFT => shift_amount,
				ALUsel => srl_ctrl,
				i_D => A,
				o_O => srl_result
			);
		
		-- SRA
		sra_inst: BarrelShifter
			port map(
				i_SHIFT => shift_amount,
				ALUsel => sra_ctrl,
				i_D => A,
				o_O => sra_result
			);
		
		
	    with ALUCtrl select
			temp_result <= and_result when "0010", -- and
					  or_result  when "0011", -- or
					  add_result when "0000", -- add
					  sub_result when "0001", -- sub 
					  xor_result when "0100", -- xor
					  slt_out when "0101", -- SLT
					  sltu_out when "0110", -- SLTU
					  sll_result when "0111", -- SLL
					  srl_result when "1000", -- SRL
					  sra_result when "1001", -- SRA
					  (others => '0') when others;
					  
					  
		process(temp_result)
		begin
			if temp_result = zero_result then
				zero <= '1'; 
			else
				zero <= '0';  
			end if;
		end process;
		
		Result <= temp_result;
		Cout <= temp_carry_out;
		
    
end structural;

