library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity datapath is
	generic(
		width : positive := 32
	);
    port (
		clk 		: in std_logic;
		rst			: in std_logic;
	
		--Signals from/to Controller
        PCWrite 	: in std_logic;
		PCWriteCond : in std_logic;
		IorD 		: in std_logic;
		MemRead		: in std_logic;
		MemWrite 	: in std_logic;
		MemToReg 	: in std_logic;
		IRWrite 	: in std_logic;
		JumpAndLink : in std_logic;
		IsSigned 	: in std_logic;
		PCSource 	: in std_logic_vector(1 downto 0);
		ALUOp 		: in std_logic_vector(1 downto 0);
		ALUSrcA 	: in std_logic;
		ALUSrcB 	: in std_logic_vector(1 downto 0);
		RegWrite 	: in std_logic;
		RegDst 		: in std_logic;
		IR31to26	: out std_logic_vector(5 downto 0);
		
		--Signals coming from Top Level/Interface	
		switches 	: in std_logic_vector(9 downto 0);
		buttons 	: in std_logic_vector(1 downto 0);
		LEDs 		: out std_logic_vector(width-1 downto 0) --maybe modify this?
	);
end datapath;


architecture BHV of datapath is

	--Other signals in the MIPS Architecture
	signal IR			: std_logic_vector(width-1 downto 0);
	signal IR5to0 		: std_logic_vector(5 downto 0);
	signal IR10to6 		: std_logic_vector(4 downto 0);
	signal IR25to0 		: std_logic_vector(25 downto 0);
	signal IR25to21		: std_logic_vector(4 downto 0);
	signal IR20to16 	: std_logic_vector(4 downto 0);
	signal IR15to11		: std_logic_vector(4 downto 0);
	signal IR15to0 		: std_logic_vector(15 downto 0);
	
	signal OPSelect		: std_logic_vector(5 downto 0);
	signal Load_HI 		: std_logic;
	signal Load_LO 		: std_logic;
	signal Alu_LO_HI 	: std_logic_vector(1 downto 0);
	signal Branch 		: std_logic;
	
	--Internal Signals
	signal PC_en 		: std_logic;
	signal PC_input		: std_logic_vector(width-1 downto 0);
	signal PC_output	: std_logic_vector(width-1 downto 0);
	signal ALU_out		: std_logic_vector(width-1 downto 0);
	signal IorD_out		: std_logic_vector(width-1 downto 0);
	signal RegA_out		: std_logic_vector(width-1 downto 0);
	signal RegB_out		: std_logic_vector(width-1 downto 0);
	signal Memory_out	: std_logic_vector(width-1 downto 0);
	signal ZE_InPort	: std_logic_vector(width-1 downto 0);
	signal InPort0_en	: std_logic;
	signal InPort1_en	: std_logic;
	signal MDR_out		: std_logic_vector(width-1 downto 0);
	signal Alu_mux_out	: std_logic_vector(width-1 downto 0);
	signal WriteReg_in  : std_logic_vector(4 downto 0);
	signal WriteData_in : std_logic_vector(width-1 downto 0);
	signal RegA_in		: std_logic_vector(width-1 downto 0);
	signal RegB_in 		: std_logic_vector(width-1 downto 0);
	signal SE_out		: std_logic_vector(width-1 downto 0);
	signal RegA_mux_out : std_logic_vector(width-1 downto 0);
	signal RegB_mux_out : std_logic_vector(width-1 downto 0); 
	signal SL_out		: std_logic_vector(width-1 downto 0); 
	signal Result		: std_logic_vector(width-1 downto 0); 
	signal ResultHi		: std_logic_vector(width-1 downto 0); 
	signal LO_out		: std_logic_vector(width-1 downto 0);
	signal HI_out		: std_logic_vector(width-1 downto 0);
	signal concat 		: std_logic_vector(width-1 downto 0);
	
begin

	PC_en <= (PCWriteCond and Branch) or PCWrite;

	U_PC: entity work.reg
		generic map(
			width => width
		)
		port map(
			clk	  	=> clk,
			rst		=> rst,
			en		=> PC_en,
			input	=> PC_input,
			output	=> PC_output
		);

	U_IorD_MUX: entity work.mux_2x1
		generic map(
			width => width
		)
		port map(
			in1		=> PC_output,
			in2		=> ALU_out,
			sel		=> IorD,
			output	=> IorD_out
		);
	
	InPort0_en <= (not buttons(0)) and (not switches(9));
	InPort1_en <= (not buttons(1)) and (switches(9));
		
	U_MEMORY: entity work.memory
        port map (
            clk       		=> clk,
            rst       		=> rst,
            MemRead   		=> MemRead,
            MemWrite 		=> MemWrite,
            InPort0_en 		=> InPort0_en,
            InPort1_en 		=> InPort1_en,
			addr 			=> IorD_out,
			WrData 			=> RegB_out,
			memory_data 	=> Memory_out,
            InPort    		=> ZE_InPort,
            OutPort   		=> LEDs
        );
		
	U_ZERO_EXTEND: entity work.zero_extend
		port map (
			input  => switches(8 downto 0),
			output => ZE_InPort
		);
		
	U_MEMORY_DATA_REG: entity work.reg
		generic map(
			width => width
		)
		port map(
			clk	  	=> clk,
			rst		=> rst,
			en		=> '1',
			input	=> Memory_out,
			output	=> MDR_out
		);
	
	IR10to6 <= IR15to0(10 downto 6);
	IR5to0  <= IR15to0(5 downto 0);
	
	U_INSTRUCTION_REG: entity work.ir_reg
		generic map(
			width => width
		)
		port map(
			clk	  	 => clk,
			rst		 => rst,
			en		 => IRWrite,
			input	 => Memory_out,
			IR25to0  => IR25to0,
			IR31to26 => IR31to26,
			IR25to21 => IR25to21,
			IR20to16 => IR20to16,
			IR15to11 => IR15to11,
			IR15to0  => IR15to0
		);
		
	U_REGDST_MUX: entity work.mux_2x1
		generic map(
			width => 5
		)
		port map(
			in1		=> IR20to16,
			in2		=> IR15to11,
			sel		=> RegDst,
			output	=> WriteReg_in
		);
	
	U_MEMTOREG_MUX: entity work.mux_2x1
		generic map(
			width => width
		)
		port map(
			in1		=> Alu_mux_out,
			in2		=> MDR_out,
			sel		=> MemToReg,
			output	=> WriteData_in
		);
	
	U_REGISTER_FILE: entity work.register_file
		generic map(
			width => width
		)
		port map(
			clk          	=> clk,
			rst          	=> rst,
			RegWrite     	=> RegWrite,
			JumpAndLink  	=> JumpAndLink,
			Read_Reg1      	=> IR25to21,
			Read_Reg2      	=> IR20to16,
			Write_Register	=> WriteReg_in,
			Write_Data    	=> WriteData_in,
			Read_Data1      => RegA_in,
			Read_Data2      => RegB_in
		);
	
	U_SIGN_EXTEND: entity work.sign_extend
		generic map(
			width => width
		)
		port map(
			IsSigned => IsSigned,
			input	 => IR15to0,
			output   => SE_out
		);
		
	U_REGA: entity work.reg
		generic map(
			width => width
		)
		port map(
			clk	  	=> clk,
			rst		=> rst,
			en		=> '1',
			input	=> RegA_in,
			output	=> RegA_out
		);
	
	U_REGB: entity work.reg
		generic map(
			width => width
		)
		port map(
			clk	  	=> clk,
			rst		=> rst,
			en		=> '1',
			input	=> RegB_in,
			output	=> RegB_out
		);
		
	U_REGA_MUX: entity work.mux_2x1
		generic map(
			width => width
		)
		port map(
			in1		=> PC_output,
			in2		=> RegA_out,
			sel		=> ALUSrcA,
			output	=> RegA_mux_out
		);
	
	U_SHIFT_LEFT_2: entity work.shiftleft_2
		generic map(
			width => width
		)
		port map(
			input  => SE_out,
			output => SL_out
		);
	
	U_REGB_MUX: entity work.mux_4x1
		generic map(
			width => width
		)
		port map(
			in1		=> RegB_out,
			in2		=> std_logic_vector(to_unsigned(4, width)),
			in3		=> SE_out,
			in4		=> SL_out, 
			sel		=> ALUSrcB,
			output	=> RegB_mux_out
		);
	
	U_ALU: entity work.alu
        generic map ( 
			width => width 
		)
        port map (
			ALUSrcA  		=> RegA_mux_out,
			ALUSrcB  		=> RegB_mux_out,
            IR10to6  		=> IR10to6,
            OPSelect      	=> OPSelect,
            Result   		=> Result,
            ResultHi 		=> ResultHi,
            Branch_Taken	=> Branch
		);
		
	U_ALU_OUT: entity work.reg
		generic map(
			width => width
		)
		port map(
			clk	  	=> clk,
			rst		=> rst,
			en		=> '1',
			input	=> Result,
			output	=> ALU_out
		);
	
	U_LO: entity work.reg
		generic map(
			width => width
		)
		port map(
			clk	  	=> clk,
			rst		=> rst,
			en		=> Load_LO,
			input	=> Result,
			output	=> LO_out
		);
	
	U_HI: entity work.reg
		generic map(
			width => width
		)
		port map(
			clk	  	=> clk,
			rst		=> rst,
			en		=> Load_HI,
			input	=> ResultHi,
			output	=> HI_out
		);
	
	U_ALU_MUX: entity work.mux_3x1
		generic map(
			width => width
		)
		port map(
			in1		=> ALU_out,
			in2		=> LO_out,
			in3		=> HI_out,
			sel		=> Alu_LO_HI,
			output  => Alu_mux_out
		);
		
	--concat PC[31:28] with (IR[25:0] << 2)	
	concat <= PC_output(31 downto 28) & IR25to0 & "00";
		
	U_PC_MUX: entity work.mux_3x1
		generic map(
			width => width
		)
		port map(
			in1		=> Result,
			in2		=> ALU_out,
			in3		=> concat,
			sel		=> PCSource,
			output  => PC_input
		);
		
	U_ALU_CONTROL: entity work.alu_control
		generic map(
			width => width
		)
		port map(
			IR5to0		=> IR5to0,
			ALUOp		=> ALUOp,
			ALU_LO_HI 	=> Alu_LO_HI,
			OPSelect	=> OPSelect,
			HI_en		=> Load_HI,
			LO_en		=> Load_LO
		);
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	


end BHV;