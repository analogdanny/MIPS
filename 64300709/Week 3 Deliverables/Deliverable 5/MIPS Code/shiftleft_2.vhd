library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity shiftleft_2 is
	generic (
		WIDTH : positive := 32
	);
	port (
		input  : in std_logic_vector(width-1 downto 0);
		output : out std_logic_vector(width-1 downto 0)
	);
end shiftleft_2;	

architecture BHV of shiftleft_2 is
begin

	output <= std_logic_vector(shift_left(unsigned(input), 2));

end BHV;