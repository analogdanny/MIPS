library ieee;
use ieee.std_logic_1164.all;

entity mux_3x1 is
  generic (
    width  :     positive);
  port (
    in1    : in  std_logic_vector(width-1 downto 0);
    in2    : in  std_logic_vector(width-1 downto 0);
	in3	   : in  std_logic_vector(width-1 downto 0);
    sel    : in  std_logic_vector(1 downto 0);
    output : out std_logic_vector(width-1 downto 0));
end mux_3x1;

architecture BHV of mux_3x1 is
begin

	process(in1, in2, in3, sel)
	begin
	
		if (sel = "00") then
			output <= in1;
		elsif (sel = "01") then
			output <= in2;
		else
			output <= in3;		
		end if;
		
	end process;
	
end BHV;