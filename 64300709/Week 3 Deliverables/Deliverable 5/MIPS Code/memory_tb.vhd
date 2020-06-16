library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_tb is
end memory_tb;

architecture TB of memory_tb is

        signal clk, rst, MemRead, MemWrite, InPort0_en, InPort1_en : std_logic := '0';
        signal InPort, addr, WrData :  std_logic_vector(31 downto 0) := (others => '0');
        signal OutPort, memory_data : std_logic_vector(31 downto 0) := (others => '0');
		
begin 

	U_MEMORY: entity work.memory
        port map (
            clk       		=> clk,
            rst       		=> rst,
            MemRead   		=> MemRead,
            MemWrite 		=> MemWrite,
            InPort0_en 		=> InPort0_en,
            InPort1_en 		=> InPort1_en,
			addr 			=> addr,
			WrData 			=> WrData,
			memory_data 	=> memory_data,
            InPort    		=> InPort,
            OutPort   		=> OutPort
        );
	
	clk <= (not clk) after 10 ns;
    
		
    process
    begin
		rst <= '0';
		
		InPort0_en <= '1';
		InPort1_en <= '0';
		wait until rising_edge(clk);
		InPort0_en <= '0';
		InPort1_en <= '1';
		wait until rising_edge(clk);
		InPort1_en <= '0';
		wait until rising_edge(clk);

        -- Write 0x0A0A0A0A to byte address 0x00000000
        MemWrite <= '1';
        WrData <= x"0A0A0A0A";
        addr <= x"00000000";
        wait for 40 ns;

        -- Write 0xF0F0F0F0 to byte address 0x00000004
        WrData <= x"F0F0F0F0";
        addr <= x"00000004";
        wait for 40 ns;
        MemWrite <= '0';
        wait for 40 ns;

        -- Read from address 0x00000000
		MemRead <= '1';
        addr <= x"00000000";
        wait until rising_edge(clk);
       
        -- Read from address 0x00000001
        addr <= x"00000001";
        wait until rising_edge(clk);

        -- Read from address 0x00000004
        addr <= x"00000004";
        wait until rising_edge(clk);

        -- Read from address 0x00000005
        addr <= x"00000005";
        wait until rising_edge(clk);
		MemRead <= '0';
		
        -- Write 0x00001111 to outport
        MemWrite <= '1';
        WrData <= x"00001111";
        addr <= x"0000FFFC";
        wait until rising_edge(clk);
        MemWrite <= '0';
        
        -- Load 0x00010000 into inport0
        InPort <= x"00010000";
        InPort0_en <= '1';
        wait until rising_edge(clk);
        InPort0_en <= '0';
        
        -- Load 0x00000001 into inport1
        InPort <= x"00000001";
        InPort1_en <= '1';
        wait until rising_edge(clk);
        InPort1_en <= '0';
        
        -- Read from inport0
        MemRead <= '1';
        addr <= x"0000FFF8";
        wait until rising_edge(clk);
        MemRead <= '0';
        
        -- Read from inport1
        MemRead <= '1';
        addr <= x"0000FFFC";
        wait until rising_edge(clk);
        MemRead <= '0';
        
        wait for 15 ns;
		
        wait;
		
    end process;
	
end TB;