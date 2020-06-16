library ieee;
use ieee.std_logic_1164.all;

entity zero_extend is
	generic (
		width : positive := 32
	);
	port (
		input  : in std_logic_vector(8 downto 0);
		output : out std_logic_vector(31 downto 0)
	);
end zero_extend;

architecture BHV of zero_extend is

	constant C_ZERO_EXTENDED : std_logic_vector(width-1 downto 9) := (others => '0');

begin

	output <= C_ZERO_EXTENDED & input;

end BHV;