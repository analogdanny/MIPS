library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is 
	generic(
		width : positive := 32
	);
    port (
        clk          	: in std_logic;
        rst          	: in std_logic;
        RegWrite     	: in std_logic;
		JumpAndLink  	: in std_logic;
        Read_Reg1      	: in std_logic_vector(4 downto 0);
        Read_Reg2      	: in std_logic_vector(4 downto 0);
        Write_Register	: in std_logic_vector(4 downto 0);
        Write_Data      : in std_logic_vector(width-1 downto 0);
		Read_Data1      : out std_logic_vector(width-1 downto 0);
        Read_Data2      : out std_logic_vector(width-1 downto 0)
    );
end register_file;

architecture BHV of register_file is

	type registers_array is array(0 to width-1) of std_logic_vector(width-1 downto 0);
	signal registers : registers_array;

begin

	process(clk, rst)
	begin

		if (rst = '1') then
		
			for i in registers'range loop
				registers(i) <= (others => '0');
			end loop;
		
		elsif (rising_edge(clk)) then
		
			if(RegWrite = '1') then
			
				if (JumpAndLink = '1') then
					registers(31) <= Write_Data;				
				else				
					registers(to_integer(unsigned(Write_Register))) <= Write_Data;				
				end if;
			
			end if;
		
		end if;

	end process;
	
	Read_Data1 <= registers(to_integer(unsigned(Read_Reg1)));
	Read_Data2 <= registers(to_integer(unsigned(Read_Reg2)));

end BHV;