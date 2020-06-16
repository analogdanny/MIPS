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
		ALUOp		: in std_logic_vector(1 downto 0);
		ALU_LO_HI 	: out std_logic_vector(1 downto 0);
		OPSelect	: out std_logic_vector(5 downto 0);
		HI_en		: out std_logic;
		LO_en		: out std_logic
    );
end alu_control;

architecture BHV of alu_control is

begin
	
	process(IR5to0, ALUOp)
	begin
	
		HI_en <= '0';
		LO_en <= '0';
		OPSelect <= IR5to0;
		ALU_LO_HI <= "00";

	end process;

end BHV;