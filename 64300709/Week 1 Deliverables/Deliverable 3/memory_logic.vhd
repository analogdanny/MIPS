library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity memory_logic is
	generic(
		width : positive := 32
	);
    port (
        MemWrite			: in std_logic;
        addr     			: in std_logic_vector(width - 1 downto 0);
		OutPort_en, ram_wen : out std_logic;
		hw_sel 				: out std_logic_vector(1 downto 0)
    );
end memory_logic;


architecture BHV of memory_logic is

begin

	process(MemWrite, addr)
	
	begin
		-- defaults
		ram_wen <= '0';
		OutPort_en <= '0';
		hw_sel <= "10";
			
		--decide if writing
		if (MemWrite = '1') then

			--decide if outport or RAM
			if(addr = x"0000fffc") then		
				OutPort_en <= '1';			
			elsif (unsigned(addr) < 1024) then
				ram_wen <= '1';				
			end if;
			
		-- if reading
		else
		
			if (unsigned(addr) < 1024) then		
				hw_sel <= "10";
				
			-- otherwise, if addr correlates, select hardware
			elsif (addr = x"0000fff8") then		
				hw_sel <= "00";
				
			elsif (addr = x"0000fffc") then		
				hw_sel <= "01";
			
			end if;
			
		end if;
		
	end process;

end BHV;