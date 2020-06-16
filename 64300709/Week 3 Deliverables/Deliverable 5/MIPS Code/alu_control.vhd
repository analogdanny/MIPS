library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity alu_control is
	generic(
		width : positive := 32
	);
    port (
        IR5to0		: in std_logic_vector(5 downto 0);
		ALUOp		: in std_logic_vector(3 downto 0);
		ALU_LO_HI 	: out std_logic_vector(1 downto 0);
		OPSelect	: out std_logic_vector(5 downto 0);
		HI_en		: out std_logic;
		LO_en		: out std_logic
    );
end alu_control;

architecture BHV of alu_control is

	--constants for OPSelect
	constant C_ADD   : std_logic_vector(5 downto 0) := "100001";
	constant C_SUB   : std_logic_vector(5 downto 0) := "100011";
	constant C_MULT  : std_logic_vector(5 downto 0) := "011000";
	constant C_MULTU : std_logic_vector(5 downto 0) := "011001";
	constant C_AND   : std_logic_vector(5 downto 0) := "100100";
	constant C_OR    : std_logic_vector(5 downto 0) := "100101";
	constant C_XOR   : std_logic_vector(5 downto 0) := "100110";
	constant C_SRL   : std_logic_vector(5 downto 0) := "000010";
	constant C_SLL   : std_logic_vector(5 downto 0) := "000000";
	constant C_SRA   : std_logic_vector(5 downto 0) := "000011";
	constant C_SLT   : std_logic_vector(5 downto 0) := "101010";
	constant C_SLTU  : std_logic_vector(5 downto 0) := "101011";
	constant C_BEQ   : std_logic_vector(5 downto 0) := "101100";
	constant C_BNE   : std_logic_vector(5 downto 0) := "101101";
	constant C_BLTEZ : std_logic_vector(5 downto 0) := "101110";
	constant C_BGTZ  : std_logic_vector(5 downto 0) := "101111";
	constant C_BLTZ  : std_logic_vector(5 downto 0) := "110001";
	constant C_BGTEZ : std_logic_vector(5 downto 0) := "110010";
	constant C_JR    : std_logic_vector(5 downto 0) := "001000";
	
	--IR5-0 for ALU_LO_HI
	constant C_MFHI	  : std_logic_vector(5 downto 0) := "010000";
	constant C_MFLO   : std_logic_vector(5 downto 0) := "010010";
	
	--ALUOps
	constant C_ADDONLY: std_logic_vector(3 downto 0) := "0000";
	constant C_RTYPE  : std_logic_vector(3 downto 0) := "0001";
	
	--ALUOp for branching
	constant C_BR_BEQ   : std_logic_vector(3 downto 0) := "0010";	
	constant C_BR_BNE   : std_logic_vector(3 downto 0) := "0011";	
	constant C_BR_BLTEZ : std_logic_vector(3 downto 0) := "0100";	
	constant C_BR_BGTZ  : std_logic_vector(3 downto 0) := "0101";	
	constant C_BR_BLTZ  : std_logic_vector(3 downto 0) := "0110";	
	constant C_BR_BGTEZ : std_logic_vector(3 downto 0) := "0111";

	--ALUOp for I-TYPE
	constant C_ADDIU  : std_logic_vector(3 downto 0) := "1000";
	constant C_SLTI   : std_logic_vector(3 downto 0) := "1001";
	constant C_SLTIU  : std_logic_vector(3 downto 0) := "1010";
	constant C_ANDI   : std_logic_vector(3 downto 0) := "1011";
	constant C_ORI    : std_logic_vector(3 downto 0) := "1100";
	constant C_XORI   : std_logic_vector(3 downto 0) := "1101";
	constant C_SUBIU  : std_logic_vector(3 downto 0) := "1110";	

	--ALUOp for JAL
	constant C_JAL_OP : std_logic_vector(3 downto 0) := "1111";

begin
	
	process(IR5to0, ALUOp)
	begin
		
		HI_en <= '0';
		LO_en <= '0';
		ALU_LO_HI <= "00";
		--Default OPSelect to "111111" because "000000" is SLL
		OPSelect <= (others => '1');
		
		case ALUOp is 
			
			when C_ADDONLY => --LW/SE/Target Address Compute Intructions
				OPSelect <= C_ADD;
		
			when C_RTYPE => --R-type instructions				
				--pass IR5-0 to the ALU
				OPSelect <= IR5to0;				
				--check if a multiply instruction in occuring
				if( (IR5to0 = C_MULT) or (IR5to0 = C_MULTU) ) then				
					HI_en <= '1';
					LO_en <= '1';			
				--Load HI register from previous multiply
				elsif (IR5to0 = C_MFHI) then				
					ALU_LO_HI <= "10";
				--Load LO register from previous multiply
				elsif (IR5to0 = C_MFLO) then							
					ALU_LO_HI <= "01";		
				end if;
			
			--I-TYPE Instructions
			when C_ADDIU =>
				OPSelect <= C_ADD;
			when C_SLTI =>
				OPSelect <= C_SLT;
			when C_SLTIU =>
				OPSelect <= C_SLTU;
			when C_ANDI =>
				OPSelect <= C_AND;
			when C_ORI =>
				OPSelect <= C_OR;
			when C_XORI =>
				OPSelect <= C_XOR;
			when C_SUBIU =>
				OPSelect <= C_SUB;
			
			--Branch Instructions
			when C_BR_BEQ => 				
				OPSelect <= C_BEQ;				
			when C_BR_BNE => 				
				OPSelect <= C_BNE;				
			when C_BR_BLTEZ => 				
				OPSelect <= C_BLTEZ;				
			when C_BR_BGTZ => 				
				OPSelect <= C_BGTZ;				
			when C_BR_BLTZ => 				
				OPSelect <= C_BLTZ;				
			when C_BR_BGTEZ => 				
				OPSelect <= C_BGTEZ;
				
			when C_JAL_OP =>
				OPSelect <= C_JR;
				
			when others => --Jump instructions
		
		end case;

	end process;

end BHV;