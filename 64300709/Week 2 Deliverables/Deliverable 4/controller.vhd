library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity controller is
	generic(
		width : positive := 32
	);
    port (
		clk 		: in std_logic;
		rst			: in std_logic;
	
	--Signals to Datapath		
		IR31to26	: in std_logic_vector(5 downto 0);
		IR5to0		: in std_logic_vector(5 downto 0);
        PCWrite 	: out std_logic;
		PCWriteCond : out std_logic;
		IorD 		: out std_logic;
		MemRead		: out std_logic;
		MemWrite 	: out std_logic;
		MemToReg 	: out std_logic;
		IRWrite 	: out std_logic;
		JumpAndLink : out std_logic;
		IsSigned 	: out std_logic;
		PCSource 	: out std_logic_vector(1 downto 0);
		ALUOp 		: out std_logic_vector(3 downto 0);
		ALUSrcA 	: out std_logic;
		ALUSrcB 	: out std_logic_vector(1 downto 0);
		RegWrite 	: out std_logic;
		RegDst 		: out std_logic
	);
end controller;

architecture BHV of controller is

	type STATE_TYPE is (S_START, S_FETCH, S_PC_INC, S_DECODE, S_RTYPE_EX, S_RTYPE_COMPLETE, 
						S_MEMORY_COMPUTE, S_LW, S_SW, S_MEMREAD_COMPLETE, S_BEQ, S_BGTEZ, 
						S_BGTZ, S_BLTEZ, S_BLTZ, S_BNE, S_JUMP, S_JAL, S_TARGET_ADDRESS,
						S_ADDIU, S_SLTI, S_SLTIU, S_ANDI, S_ORI, S_XORI, S_SUBIU, 
						S_ITYPE_COMPLETE, S_HALT, S_LW_WB);
	signal state, next_state : STATE_TYPE;

	--constants for Decoding		
	constant C_BEQ    : std_logic_vector(5 downto 0) := "101100";
	constant C_BNE    : std_logic_vector(5 downto 0) := "101101";
	constant C_BLTEZ  : std_logic_vector(5 downto 0) := "101110";
	constant C_BGTZ   : std_logic_vector(5 downto 0) := "101111";
	constant C_BLTZ   : std_logic_vector(5 downto 0) := "110001";
	constant C_BGTEZ  : std_logic_vector(5 downto 0) := "110010";
	constant C_HALT   : std_logic_vector(5 downto 0) := "111111";
	constant C_J      : std_logic_vector(5 downto 0) := "000010";
	constant C_JR     : std_logic_vector(5 downto 0) := "000000";
	constant C_JAL    : std_logic_vector(5 downto 0) := "000011";
	
	--constants for exceptions to RTYPE instructions
	constant C_MULT   : std_logic_vector(5 downto 0) := "011000";
	constant C_MULTU  : std_logic_vector(5 downto 0) := "011001";
	constant C_MFHI	  : std_logic_vector(5 downto 0) := "010000";
	constant C_MFLO   : std_logic_vector(5 downto 0) := "010010";
	
	--constants for instruction types
	constant C_RTYPE_I : std_logic_vector(5 downto 0) := "000000";	
	constant C_LW      : std_logic_vector(5 downto 0) := "100011";
	constant C_SW      : std_logic_vector(5 downto 0) := "101011";
	constant C_ADDIU_I : std_logic_vector(5 downto 0) := "001001";
	constant C_SLTI_I  : std_logic_vector(5 downto 0) := "001010";
	constant C_SLTIU_I : std_logic_vector(5 downto 0) := "001011";
	constant C_ANDI_I  : std_logic_vector(5 downto 0) := "001100";
	constant C_ORI_I   : std_logic_vector(5 downto 0) := "001101";
	constant C_XORI_I  : std_logic_vector(5 downto 0) := "001110";
	constant C_SUBIU_I : std_logic_vector(5 downto 0) := "010000";
	
	--ALUOps
	constant C_ADD     : std_logic_vector(3 downto 0) := "0000";
	constant C_RTYPE   : std_logic_vector(3 downto 0) := "0001";
	
	--ALUOp for branching
	constant C_BR_BEQ   : std_logic_vector(3 downto 0) := "0010";	
	constant C_BR_BNE   : std_logic_vector(3 downto 0) := "0011";	
	constant C_BR_BLTEZ : std_logic_vector(3 downto 0) := "0100";	
	constant C_BR_BGTZ  : std_logic_vector(3 downto 0) := "0101";	
	constant C_BR_BLTZ  : std_logic_vector(3 downto 0) := "0110";	
	constant C_BR_BGTEZ : std_logic_vector(3 downto 0) := "0111";

	--ALUOp for I-TYPE
	constant C_ADDIU    : std_logic_vector(3 downto 0) := "1000";
	constant C_SLTI     : std_logic_vector(3 downto 0) := "1001";
	constant C_SLTIU    : std_logic_vector(3 downto 0) := "1010";
	constant C_ANDI     : std_logic_vector(3 downto 0) := "1011";
	constant C_ORI      : std_logic_vector(3 downto 0) := "1100";
	constant C_XORI     : std_logic_vector(3 downto 0) := "1101";
	constant C_SUBIU    : std_logic_vector(3 downto 0) := "1110";

begin

	process (clk, rst)
	begin
		if (rst = '1') then
			state <= S_START;
		elsif (clk = '1' and clk'event) then
			state <= next_state;
		end if;
	end process;
	
	
	process (state, IR31to26, IR5to0)
	begin
		
		PCWrite 	<= '0';
		PCWriteCond <= '0';
		IorD 		<= '0';
		MemRead		<= '0';
		MemWrite 	<= '0';
		MemToReg 	<= '0';
		IRWrite 	<= '0';
		JumpAndLink <= '0';
		IsSigned 	<= '0';
		PCSource 	<= (others => '0');
		ALUOp 		<= (others => '0');
		ALUSrcA 	<= '0';
		ALUSrcB 	<= (others => '0');
		RegWrite 	<= '0';
		RegDst 		<= '0';
		next_state  <= state;
		
		case state is 
		
			when S_START =>
			
				next_state <= S_FETCH;
			
		------------------- FETCHING INSTRUCTIONS -------------------
			when S_FETCH =>
			
				MemRead <= '1';
				next_state <= S_PC_INC;
			
			when S_PC_INC =>
						
				IRWrite <= '1';
				ALUSrcB <= "01";
				PCWrite <= '1';
				next_state <= S_DECODE;
		------------------- FETCHING INSTRUCTIONS -------------------

		
			
		------------------- DECODING INSTRUCTIONS -------------------
			when S_DECODE =>
			
				ALUSrcB <= "11";
			
				--RTYPE INSTRUCTIONS
				if (IR31to26 = C_RTYPE_I) then				
					next_state <= S_RTYPE_EX;
					
				--ITYPE INSTRUCTIONS	
				elsif ((IR31to26 >= C_ADDIU_I) and (IR31to26 <= C_SUBIU_I)) then
					
					if (IR31to26 = C_ADDIU_I) then
						next_state <= S_ADDIU;
					elsif (IR31to26 = C_SLTI_I) then
						next_state <= S_SLTI;
					elsif (IR31to26 = C_SLTIU_I) then
						next_state <= S_SLTIU;
					elsif (IR31to26 = C_ANDI_I) then
						next_state <= S_ANDI;
					elsif (IR31to26 = C_ORI_I) then
						next_state <= S_ORI;
					elsif (IR31to26 = C_XORI_I) then
						next_state <= S_XORI;
					elsif (IR31to26 = C_SUBIU_I) then
						next_state <= S_SUBIU;
					end if;
					
				--LOAD/STORE INSTRUCTIONS
				elsif ((IR31to26 = C_LW) or (IR31to26 = C_SW)) then 				
					next_state <= S_MEMORY_COMPUTE;
				
				--BRANCHING INSTRUCTIONS
				elsif ((IR31to26 >= C_BEQ) and (IR31to26 <= C_BGTEZ)) then 
					next_state <= S_TARGET_ADDRESS;	
				
				--JUMP INSTRUCTIONS 				
				elsif (IR31to26 = C_J) then
					next_state <= S_JUMP;
					
				elsif (IR31to26 = C_JAL) then
					next_state <= S_JAL;
					
				--HALT STATE	
				elsif (IR31to26 = C_HALT) then
					next_state <= S_HALT;
				
				end if;
		------------------- DECODING INSTRUCTIONS -------------------
		
		
		
		------------------- LW/SW PATH -------------------
			when S_MEMORY_COMPUTE =>
			
				--ALUOp Defaulted to Add for offset and register
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				
				if(IR31to26 = C_LW) then

					next_state <= S_LW;

				elsif (IR31to26 = C_SW) then 

					next_state <= S_SW;
			
				end if;
			
			--LW			
			when S_LW =>
			
				MemRead <= '1';
				IorD <= '1';
				next_state <= S_LW_WB;
				
			when S_LW_WB =>
				next_state <= S_MEMREAD_COMPLETE;
				
			when S_MEMREAD_COMPLETE =>
			
				RegDst <= '0';
				RegWrite <= '1';
				MemToReg <= '1'; --PDF says '0'?
				next_state <= S_FETCH;
				
			--SW
			when S_SW =>
				
				MemWrite <= '1';
				IorD <= '1';
				next_state <= S_FETCH;
		------------------- LW/SW PATH -------------------
			
			
			
		------------------- RTYPE INSTRUCTION PATH -------------------
			when S_RTYPE_EX =>
				ALUOp <= C_RTYPE;
				PCWriteCond <= '1'; -- for Jump Register Instruction
				ALUSrcA <= '1';
				
				if ((IR5to0 = C_MULT) or (IR5to0 = C_MULTU)) then
					next_state <= S_FETCH;
				else
					next_state <= S_RTYPE_COMPLETE;
				end if;
				
			when S_RTYPE_COMPLETE =>
				if ((IR5to0 = C_MFHI) or (IR5to0 = C_MFLO)) then
					ALUOp <= C_RTYPE;
				end if;
				
				RegDst <= '1';
				RegWrite <= '1';
				next_state <= S_FETCH;
		------------------- RTYPE INSTRUCTION PATH -------------------
			
			
			
		------------------- ITYPE INSTRUCTION PATH -------------------
			when S_ADDIU =>
				IsSigned <= '1';
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				ALUOp <= C_ADDIU;
				next_state <= S_ITYPE_COMPLETE;
			
			when S_SLTI =>
				IsSigned <= '1';
				PCWriteCond <= '1';
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				ALUOp <= C_SLTI;
				next_state <= S_ITYPE_COMPLETE;
			
			when S_SLTIU =>
				IsSigned <= '1';
				PCWriteCond <= '1';
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				ALUOp <= C_SLTIU;
				next_state <= S_ITYPE_COMPLETE;
			
			when S_ANDI =>
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				ALUOp <= C_ANDI;
				next_state <= S_ITYPE_COMPLETE;
				
			when S_ORI =>
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				ALUOp <= C_ORI;
				next_state <= S_ITYPE_COMPLETE;
			
			when S_XORI =>
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				ALUOp <= C_XORI;
				next_state <= S_ITYPE_COMPLETE;
			
			when S_SUBIU =>
				IsSigned <= '1';
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				ALUOp <= C_SUBIU;
				next_state <= S_ITYPE_COMPLETE;
			
			when S_ITYPE_COMPLETE =>
				RegWrite <= '1';
				next_state <= S_FETCH;			
		------------------- ITYPE INSTRUCTION PATH -------------------
			
			
			
		------------------- BRANCH PATHS -------------------
			when S_TARGET_ADDRESS =>
				ALUOp <= C_ADD; 
				IsSigned <= '1';
				PCSource <= "01";
				ALUSrcB <= "11";
		
				if (IR31to26 = C_BEQ) then
					next_state <= S_BEQ;
				
				elsif (IR31to26 = C_BGTEZ) then
					next_state <= S_BGTEZ;
				
				elsif (IR31to26 = C_BGTZ) then
					next_state <= S_BGTZ;	
				
				elsif (IR31to26 = C_BLTEZ) then
					next_state <= S_BLTEZ;	
				
				elsif (IR31to26 = C_BLTZ) then
					next_state <= S_BLTZ;	
				
				elsif (IR31to26 = C_BNE) then
					next_state <= S_BNE;
					
				end if;
		
			when S_BEQ =>
				ALUOp <= C_BR_BEQ;
				ALUSrcA <= '1';
				PCWriteCond <= '1';
				PCSource <= "01";
				next_state <= S_FETCH;
				
			when S_BGTEZ =>
				ALUOp <= C_BR_BGTEZ;
				ALUSrcA <= '1';
				PCWriteCond <= '1';
				PCSource <= "01";
				next_state <= S_FETCH;
			
			when S_BGTZ =>
				ALUOp <= C_BR_BGTZ;
				ALUSrcA <= '1';
				PCWriteCond <= '1';
				PCSource <="01";
				next_state <= S_FETCH;
			
			when S_BLTEZ =>
				ALUOp <= C_BR_BLTEZ;
				ALUSrcA <= '1';
				PCWriteCond <= '1';
				PCSource <= "01";
				next_state <= S_FETCH;
			
			when S_BLTZ =>
				ALUOp <= C_BR_BLTZ;
				ALUSrcA <= '1';
				PCWriteCond <= '1';
				PCSource <= "01";
				next_state <= S_FETCH;
			
			when S_BNE =>
				ALUOp <= C_BR_BNE;
				ALUSrcA <= '1';
				PCWriteCond <= '1';
				PCSource <= "01";
				next_state <= S_FETCH;
		------------------- BRANCH PATHS -------------------
			
			
			
		------------------- JUMP PATHS -------------------
			when S_JUMP =>
				PCSource <= "10";
				PCWrite <= '1';
				next_state <= S_FETCH;
				
			when S_JAL =>
				JumpAndLink <= '1';
				next_state <= S_JUMP;
		------------------- JUMP PATHS -------------------		
		
			when S_HALT =>
				next_state <= S_HALT;
		
		end case;
		
	end process;

end BHV;