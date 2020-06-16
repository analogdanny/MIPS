library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
	generic(
		width : positive := 32
	);
    port (
        clk, rst, MemRead, MemWrite, InPort0_en, InPort1_en : in std_logic;
        InPort, addr, WrData : in  std_logic_vector(width - 1 downto 0);
        OutPort, memory_data : out std_logic_vector(width - 1 downto 0)
    );
end memory;

architecture BHV of memory is 

	signal ram_wen, OutPort_en : std_logic;
	signal in_port0_output, in_port1_output, rdata : std_logic_vector(width - 1 downto 0);
	signal hw_sel, memory_hw_sel : std_logic_vector(1 downto 0);

begin	
	
	U_MEMREAD: entity work.reg
		generic map(
			width => 2
		)
		port map(
			clk => clk,
			rst => rst,
			en => MemRead,
			input => memory_hw_sel,
			output => hw_sel
		);
		
	U_MEMORY_LOGIC: entity work.memory_logic
		port map(
			MemWrite 	=> MemWrite, 
			addr     	=> addr,
			OutPort_en 	=> OutPort_en,
			ram_wen		=> ram_wen,
			hw_sel		=> memory_hw_sel
		);
	
	-- use the hw_sel signal to choose memory data to output
	U_MUX_3x1: entity work.mux_3x1
		generic map(
			width => 32
		)
		port map(
			in1 	=> in_port0_output,
			in2 	=> in_port1_output,
			in3 	=> rdata,
			sel 	=> hw_sel,
			output 	=> memory_data
		);

	U_IO_PORTS: entity work.I_O_Ports
		generic map(
			width => 32
		)
		port map(
			clk 			=> clk, 
			rst 			=> rst, 
			en_in_port0 	=> InPort0_en, 
			en_in_port1 	=> InPort1_en, 
			en_out_port 	=> OutPort_en,
			in_port0_input 	=> InPort, 
			in_port1_input 	=> InPort, 
			out_port_input 	=> WrData,
			in_port0_output => in_port0_output, 
			in_port1_output => in_port1_output, 
			out_port_output => OutPort
		);
		
	U_RAM: entity work.ram
		port map(
			clock   => clk,
			wren  	=> ram_wen,
			address => addr(9 downto 2),
			data    => WrData,
			q		=> rdata
		);

end BHV;





























