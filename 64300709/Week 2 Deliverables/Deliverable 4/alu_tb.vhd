library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end alu_tb;

architecture TB of alu_tb is

    constant width   : positive := 32;
	constant C_ADD   : std_logic_vector(5 downto 0) := "100001";
	constant C_SUB   : std_logic_vector(5 downto 0) := "100011";
	constant C_MULT  : std_logic_vector(5 downto 0) := "011000";
	constant C_MULTU : std_logic_vector(5 downto 0) := "011010";
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
			
	signal ALUSrcA, ALUSrcB, Result, ResultHI 	: std_logic_vector(width-1 downto 0);
    signal OPSelect 							: std_logic_vector(5 downto 0);
    signal IR10to6  							: std_logic_vector(4 downto 0);
    signal Branch_Taken   						: std_logic;
	
begin
	
	process
	begin
	
		IR10to6 <= (others => '0');
		
		--add
		OPSelect <= C_ADD;		
		ALUSrcA <= std_logic_vector(to_unsigned(10, width));	
		ALUSrcB <= std_logic_vector(to_unsigned(15, width)); 
		wait for 10 ns;	
		
		--sub
		OPSelect <= C_SUB;		
		ALUSrcA <= std_logic_vector(to_unsigned(25, width));	
		ALUSrcB <= std_logic_vector(to_unsigned(10, width)); 
		wait for 10 ns;	
		
		--signed multiplication
		OPSelect <= C_MULT;		
		ALUSrcA <= std_logic_vector(to_signed(10, width));	
		ALUSrcB <= std_logic_vector(to_signed(-4, width));
		wait for 10 ns;
		
		--unsigned multiplication
		OPSelect <= C_MULTU;
		ALUSrcA <= std_logic_vector(to_unsigned(65536, width));	
		ALUSrcB <= std_logic_vector(to_unsigned(131072, width));
		wait for 20 ns;		
		
		--and
		OPSelect <= C_AND;		
		ALUSrcA <= x"0000FFFF";	
		ALUSrcB <= x"FFFF1234"; 
		wait for 10 ns;	
		
		--OR
		OPSelect <= C_OR;		
		ALUSrcA <= x"0000FFFF";	
		ALUSrcB <= x"FFFF1234"; 
		wait for 10 ns;	
		
		--XOR
		OPSelect <= C_XOR;		
		ALUSrcA <= x"0000FFFF";	
		ALUSrcB <= x"FFFF1234";  
		wait for 10 ns;	
		
		--SRL
		OPSelect <= C_SRL;		
		ALUSrcA <= x"0000000F";	
		IR10to6 <= std_logic_vector(to_unsigned(4, 5));
		wait for 10 ns;	
		
		--SRA
		OPSelect <= C_SRA;		
		ALUSrcA <= x"F0000008";
		IR10to6 <= std_logic_vector(to_unsigned(1, 5)); 
		wait for 10 ns;	
		
		--SRA
		OPSelect <= C_SRA;		
		ALUSrcA <= x"00000008";	
		IR10to6 <= std_logic_vector(to_signed(1, 5));
		wait for 10 ns;	
		
		--SLT
		OPSelect <= C_SLT;		
		ALUSrcA <= std_logic_vector(to_signed(10, width));	
		ALUSrcB <= std_logic_vector(to_signed(15, width));
		wait for 10 ns;	
		
		--SLT
		OPSelect <= C_SLT;		
		ALUSrcA <= std_logic_vector(to_signed(15, width));	
		ALUSrcB <= std_logic_vector(to_signed(10, width));
		wait for 10 ns;	
				
		--BLTEZ
		OPSelect <= C_BLTEZ;		
		ALUSrcA <= std_logic_vector(to_signed(5, width));	
		wait for 10 ns;	
		
		--BGTZ
		OPSelect <= C_BGTZ;		
		ALUSrcA <= std_logic_vector(to_signed(5, width));	
		wait for 10 ns;		
		
		wait;
		
	end process;
	
	U_ALU: entity work.alu
        generic map ( 
			width => width 
		)
        port map (
			ALUSrcA  		=> ALUSrcA,
			ALUSrcB  		=> ALUSrcB,
            IR10to6  		=> IR10to6,
            OPSelect      	=> OPSelect,
            Result   		=> Result,
            ResultHi 		=> ResultHi,
            Branch_Taken	=> Branch_Taken
		);
	
end TB;