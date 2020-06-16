library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity alu is
	generic (
		WIDTH : positive := 32
	);
	port (
		IR10to6   		 : in std_logic_vector(4 downto 0);
		OPSelect 		 : in std_logic_vector(5 downto 0);
		ALUSrcA, ALUSrcB : in std_logic_vector(WIDTH-1 downto 0);
		Branch_Taken 	 : out std_logic;
		Result, ResultHI : out std_logic_vector(WIDTH-1 downto 0)
	);
end alu;	

architecture BHV of alu is
begin
	process(ALUSrcA, ALUSrcB, IR10to6, OPSelect)

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
		
		variable temp : unsigned(WIDTH-1 downto 0);
		variable temp_mult : signed((WIDTH*2)-1 downto 0);
		variable temp_multu : unsigned((WIDTH*2)-1 downto 0);

	begin
	
		Result <= (others => '0');
		ResultHi <= (others => '0');
		Branch_Taken <= '0';
	
		case OPSelect is
		
			when C_ADD =>
				Result <= std_logic_vector(unsigned(ALUSrcA) + unsigned(ALUSrcB));
				
			when C_SUB =>
				Result <= std_logic_vector(unsigned(ALUSrcA) - unsigned(ALUSrcB));	
								
			when C_MULT =>
				temp_mult := signed(ALUSrcA) * signed(ALUSrcB);
				Result <= std_logic_vector(temp_mult(WIDTH-1 downto 0));
				ResultHI <= std_logic_vector(temp_mult((WIDTH*2)-1 downto 32));
			
			when C_MULTU =>
				temp_multu := unsigned(ALUSrcA) * unsigned(ALUSrcB);
				Result <= std_logic_vector(temp_multu(WIDTH-1 downto 0));
				ResultHI <= std_logic_vector(temp_multu((WIDTH*2)-1 downto 32));
				
			when C_AND =>
				Result <= ALUSrcA and ALUSrcB;
			
			when C_OR =>
				Result <= ALUSrcA or ALUSrcB;
			
			when C_XOR =>
				Result <= ALUSrcA xor ALUSrcB;
			
			--RIGHT HERE
			when C_SRL =>
				Result <= std_logic_vector(shift_right(unsigned(ALUSrcB), to_integer(unsigned(IR10to6))));
			
			when C_SLL =>
				Result <= std_logic_vector(shift_left(unsigned(ALUSrcB), to_integer(unsigned(IR10to6))));
			
			when C_SRA =>
				Result <= std_logic_vector(shift_right(signed(ALUSrcB), to_integer(unsigned(IR10to6))));
		
			when C_SLT =>
				if(signed(ALUSrcA) < signed(ALUSrcB)) then
					Branch_Taken <= '1';
					Result <= std_logic_vector(to_unsigned(1, WIDTH));
				end if;
					
			when C_SLTU =>
				if(unsigned(ALUSrcA) < unsigned(ALUSrcB)) then
					Branch_Taken <= '1';
					Result <= std_logic_vector(to_unsigned(1, WIDTH));
				end if;
				
			when C_BEQ =>
				if (unsigned(ALUSrcA) = unsigned(ALUSrcB)) then
					Branch_Taken <= '1';
				end if;
			
			when C_BNE =>
				if (unsigned(ALUSrcA) /= unsigned(ALUSrcB)) then
					Branch_Taken <= '1';
				end if;
			
			when C_BLTEZ =>
				if (signed(ALUSrcA) <= to_signed(0, WIDTH)) then
					Branch_Taken <= '1';
				end if;
			
			when C_BGTZ =>
				if (signed(ALUSrcA) > to_signed(0, WIDTH)) then
					Branch_Taken <= '1';
				end if;
			
			when C_BLTZ =>
				if (signed(ALUSrcA) < to_signed(0, WIDTH)) then
					Branch_Taken <= '1';
				end if;
			
			when C_BGTEZ =>
				if (signed(ALUSrcA) >= to_signed(0, WIDTH)) then
					Branch_Taken <= '1';
				end if;
			
			when C_JR =>
				Result <= ALUSrcA;
				Branch_Taken <= '1';
				
			when others => NULL;
			
		end case;
	
	end process;

end BHV;
