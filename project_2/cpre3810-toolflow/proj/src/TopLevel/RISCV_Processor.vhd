-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;


entity RISCV_Processor is
  generic(N : integer := 32; DATA_WIDTH : integer := 32; ADDR_WIDTH : integer := 10);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  RISCV_Processor;


architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment
  -- control signals
  signal s_ALUSel : std_logic_vector(3 downto 0); --ALU control
  signal s_ASel   : std_logic;     		  --select Amux
  signal s_BSel   : std_logic; 			  --select Bmux
  signal s_ImmSel : std_logic_vector(2 downto 0); 	  --Type of ImmGen
  signal s_WBSel  : std_logic_vector(1 downto 0); 	  --mux3t1 selector
  signal s_BrUn   : std_logic;				-- unsinged/signed branch
  signal s_funct3 : std_logic_vector(2 downto 0); --funct3

  signal s_ALUOut : std_logic_vector(31 downto 0); --ALU output
  signal s_ALUOut_masked : std_logic_vector(N-1 downto 0); --helper for fetch logic

  signal s_Aout   : std_logic_vector(31 downto 0); --rs1 out
  signal s_Bout   : std_logic_vector(31 downto 0); --rs2 out

  signal s_ALUzero: std_logic; --zero from ALU
  signal s_Cout   : std_logic; --Carry out line / ovfl

  signal s_PCOut  : std_logic_vector(31 downto 0) := (others => '0'); -- Current PC from fetch
  signal s_ImmOut : std_logic_vector(31 downto 0); --imm out signal
  signal s_PCsrc  : std_logic_vector(1 downto 0); --PCsrc signal
  signal s_IMemInst : std_logic_vector(31 downto 0); --imem inst

  signal s_Amux   : std_logic_vector(31 downto 0); --Amux value
  signal s_Bmux   : std_logic_vector(31 downto 0); --Bmux value

  signal s_BranchCond : std_logic; --branch comp output
  signal s_BranchEn : std_logic; --branch control unit signal
  signal s_branch : std_logic; --gated branch for PCsrc
  
  signal s_LoadData_Ext : std_logic_vector(N-1 downto 0);
  
  component controlUnit is 
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
	BR	 : out std_logic 
    );
  end component;

  component ALU is 
    port(
	A	 : in std_logic_vector(31 downto 0); -- first data input
	B	 : in std_logic_vector(31 downto 0); -- second data input
	ALUCtrl	 : in std_logic_vector(3 downto 0); -- output of the alu control
	Result	 : out std_logic_vector(31 downto 0);
	zero	 : out std_logic;
	Cout	 : out std_logic
	);
  end component;

  component branch_comp is 
    port(
	i_A : in std_logic_vector(31 downto 0);
	i_B : in std_logic_vector(31 downto 0);
	i_funct3 : in std_logic_vector(2 downto 0);
	i_BrUn : in std_logic;
	o_Branch : out std_logic
        );
  end component;

  component FetchLogic is
    port(
	rst      : in std_logic;
	clk      : in std_logic;
	imm      : in std_logic_vector(31 downto 0); -- immediate value branch/jump
	ALUo     : in std_logic_vector(31 downto 0); -- jalr target from alu 
	PCsrc    : in std_logic_vector(1 downto 0); -- pc select 00 = pc+4, 01 = branch, 10 = jump, 11 = jalr
	instr_in : in std_logic_vector(31 downto 0); --instruction from imem
	PCP4     : out std_logic_vector(31 downto 0); -- PC + 4 output
	currPC   : out std_logic_vector(31 downto 0); -- current pc value
	instr    : out std_logic_vector(31 downto 0) -- fetched instruction
	);
  end component;

  component RegisterFile is 
    port(
	i_RD1    : in std_logic_vector(4 downto 0);
	i_RS1    : in std_logic_vector(4 downto 0);
	i_RS2    : in std_logic_vector(4 downto 0);
	i_RST    : in STD_LOGIC;
	i_CLK    : in STD_LOGIC;
	wr_EN    : in STD_LOGIC;
	wr_DATA  : in std_logic_vector(31 downto 0);
	o_RS1    : out std_logic_vector(31 downto 0);
	o_RS2    : out std_logic_vector(31 downto 0)
	);
  end component;


  component ImmGen is
    port(
	i_ImmSel   : in std_logic_vector(2 downto 0);
        i_ImmType : in std_logic_vector(31 downto 0);
	o_Imm    : out std_logic_vector(31 downto 0)
	);
  end component;

  component mux2t1_N is
    port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0)
	);
 end component;

  component mux4t1_N is 
	generic(N : integer := 32);
	port(		
		i_S  : in  std_logic_vector(1 downto 0);  -- 2-bit select
		i_D0 : in  std_logic_vector(N-1 downto 0); --dmemout
		i_D1 : in  std_logic_vector(N-1 downto 0); --aluout
		i_D2 : in  std_logic_vector(N-1 downto 0); --nextinstadd
		i_D3 : in  std_logic_vector(N-1 downto 0); --immval
		o_O  : out std_logic_vector(N-1 downto 0)
	);
  end component;
  
begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_PCOut when '0',
      iInstAddr when others;
  

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 
  s_Ovfl <= '0';

  FL: FetchLogic
	port map(
	rst  => iRST,   
	clk => iCLK,     
	imm  => s_ImmOut,    
	ALUo => s_ALUOut_masked,    
	PCsrc => s_PCsrc,
	instr_in => s_IMemInst,
	PCP4 => s_NextInstAddr,
	currPC => s_PCOut,
	instr => s_Inst
	);
	
  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_ImemAddr(ADDR_WIDTH+1 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_IMemInst);


  CU: controlUnit
	port map(
	c_IN => s_Inst,     
        ImmSel => s_ImmSel,
        s_RegWr => s_RegWr,
        BrUn => s_BrUn,
        Asel => s_Asel,   
        Bsel => s_Bsel,   
	o_funct3 => s_funct3,
        ALUSel => s_ALUSel,   
        s_DMemWr => s_DMemWr, 
        WBSel => s_WBSel,   
	s_HALT => s_Halt, 
	BR => s_BranchEn
	);

  RF: RegisterFile
	port map(
	i_RD1 => s_RegWrAddr,   
	i_RS1 => s_Inst(19 downto 15),  
	i_RS2 => s_Inst(24 downto 20),   
	i_RST => iRST,    
	i_CLK => iCLK,    
	wr_EN => s_RegWr,
	wr_DATA => s_RegWrData, 
	o_RS1 => s_Aout,    
	o_RS2 => s_Bout
	); 
  	s_DMemData <= s_Bout; --rs2 is DMem data

  IG: ImmGen
	port map(
	i_ImmSel => s_ImmSel,
        i_ImmType => s_Inst, 
	o_Imm => s_ImmOut   
	);

  bc: branch_comp
	port map(
	i_A => s_Aout,
	i_B => s_Bout,
	i_funct3 => s_funct3,
	i_BrUn => s_BrUn,
	o_Branch => s_BranchCond
        );
        s_Branch <= s_BranchCond and s_BranchEn;

  AMUX: mux2t1_N
	port map(
	i_S => s_ASel,   -- ASel       
        i_D0 => s_Aout, --RS1        
        i_D1 => s_PCOut, --PC value   
        o_O => s_Amux --Amux output         
	);

  BMUX: mux2t1_N
	port map(
	i_S => s_BSel, --BSel       
        i_D0 => s_Bout, --RS2        
        i_D1 => s_ImmOut, --Imm value  
        o_O => s_Bmux --Bmux output         
	);

  Arith_Logic_Unit: ALU
        port map(
	A => s_Amux,	 
	B => s_Bmux, 
	ALUCtrl => s_ALUSel,	 
	Result => s_ALUOut,	 
	zero => s_ALUzero,
	Cout => s_Ovfl
	);
	 s_ALUOut_masked <= s_ALUOut when s_Inst(6 downto 0) /= "1100111" else
		(s_ALUOut(31 downto 1) & '0');
	s_DMemAddr <= s_ALUOut; --ALUout is DMem Addr
	
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

	
  WRDATAMUX: mux4t1_N
	port map(
	i_S => s_WBSel,
	i_D0 => s_LoadData_Ext,	
	i_D1 => s_ALUOut,	
	i_D2 => s_NextInstAddr,	
	i_D3 => s_ImmOut,
	o_O => s_RegWrData	
	);

	s_RegWrAddr <= s_Inst(11 downto 7);
	oALUOut <= s_ALUOut;
  process (s_Branch, s_Inst) --jal/jalr wiring
  begin
  	case s_Inst(6 downto 0) is
  		when "1101111" =>
  			s_PCsrc <= "10";
  		when "1100111" =>
  			s_PCsrc <= "11";
  		when "1100011" =>
  			if s_Branch ='1' then
  				s_PCsrc <= "01";
  			else
  				s_PCsrc <= "00";
  			end if;
  		when others =>
  			s_PCsrc <= "00";
  	end case;
  end process;
  
  
   process(s_DMemOut, s_ALUOut, s_Inst)
    variable v_addr_bits : std_logic_vector(1 downto 0);
  begin
    v_addr_bits := s_ALUOut(1 downto 0); -- Lower 2 bits of the address
    
   
    if (s_Inst(6 downto 0) = "0000011") then -- Check if it's a load
      
      -- If it is a load then check the funct3 bits
      case s_Inst(14 downto 12) is 
        
        -- lb (sign-extend byte)
        when "000" => 
          case v_addr_bits is
            when "00" => s_LoadData_Ext <= (31 downto 8 => s_DMemOut(7)) & s_DMemOut(7 downto 0);
            when "01" => s_LoadData_Ext <= (31 downto 8 => s_DMemOut(15)) & s_DMemOut(15 downto 8);
            when "10" => s_LoadData_Ext <= (31 downto 8 => s_DMemOut(23)) & s_DMemOut(23 downto 16);
            when others => s_LoadData_Ext <= (31 downto 8 => s_DMemOut(31)) & s_DMemOut(31 downto 24);
          end case;
          
        -- lh (sign-extend halfword)
        when "001" => 
          case v_addr_bits(1) is
            when '0' => s_LoadData_Ext <= (31 downto 16 => s_DMemOut(15)) & s_DMemOut(15 downto 0);
            when others => s_LoadData_Ext <= (31 downto 16 => s_DMemOut(31)) & s_DMemOut(31 downto 16);
          end case;
          
        -- lw (load word)
        when "010" => 
          s_LoadData_Ext <= s_DMemOut;
          
        -- lbu (zero-extend byte)
        when "100" => 
          case v_addr_bits is
            when "00" => s_LoadData_Ext <= x"000000" & s_DMemOut(7 downto 0);
            when "01" => s_LoadData_Ext <= x"000000" & s_DMemOut(15 downto 8);
            when "10" => s_LoadData_Ext <= x"000000" & s_DMemOut(23 downto 16);
            when others => s_LoadData_Ext <= x"000000" & s_DMemOut(31 downto 24);
          end case;
          
        -- lhu (zero-extend halfword)
        when "101" => 
          case v_addr_bits(1) is
            when '0' => s_LoadData_Ext <= x"0000" & s_DMemOut(15 downto 0);
            when others => s_LoadData_Ext <= x"0000" & s_DMemOut(31 downto 16);
          end case;
          
        -- Default for any other funct3 
        when others => 
          s_LoadData_Ext <= s_DMemOut;
      end case;
      
    else 
      s_LoadData_Ext <= s_DMemOut;
    end if;
  end process;

end structure;

