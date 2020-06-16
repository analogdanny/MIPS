library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity sign_extend is
	generic (
		width : positive := 32
	);
	port (
		input    : in std_logic_vector(15 downto 0);
		IsSigned : in std_logic;
		output   : out std_logic_vector(width-1 downto 0)
	);
end sign_extend;

architecture BHV of sign_extend is

begin
	
	process(IsSigned, input)
	begin
		
		if (IsSigned = '1') then
			output <= std_logic_vector(resize(signed(input), width));
		else 	
			output <= std_logic_vector(resize(unsigned(input), width));
		end if;
		
	end process;

end BHV;