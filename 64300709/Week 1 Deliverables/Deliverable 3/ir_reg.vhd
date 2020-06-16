library ieee;
use ieee.std_logic_1164.all;

entity ir_reg is
	generic (
		width : positive := 32
	);
	port (
		clk    		: in  std_logic;
		rst    		: in  std_logic;
		en   		: in  std_logic;
		input  		: in  std_logic_vector(width-1 downto 0);
		IR25to0 	: out std_logic_vector(25 downto 0);
		IR31to26	: out std_logic_vector(5 downto 0); 
		IR25to21	: out std_logic_vector(4 downto 0);
		IR20to16 	: out std_logic_vector(4 downto 0);
		IR15to11	: out std_logic_vector(4 downto 0);
		IR15to0 	: out std_logic_vector(15 downto 0)
	);
end ir_reg;

architecture BHV of ir_reg is
begin
	process(clk, rst)
	begin
	
		if (rst = '1') then
		
			IR25to0 <= (others => '0');
			IR31to26 <= (others => '0');
			IR25to21 <= (others => '0');
			IR20to16 <= (others => '0');
			IR15to11 <= (others => '0');
			IR15to0 <= (others => '0');
			
		elsif (clk'event and clk = '1') then
		
			if (en = '1') then
			
				IR25to0 <= input(25 downto 0);
				IR31to26 <= input(5 downto 0);
				IR25to21 <= input(4 downto 0);
				IR20to16 <= input(4 downto 0);
				IR15to11 <= input(4 downto 0);
				IR15to0 <= input(15 downto 0);
				
			end if;
			
		end if;
		
	end process;
	
end BHV;
