library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I_O_Ports is
    generic (
		WIDTH : positive := 32
		);
    port (
		clk, rst, en_in_port0, en_in_port1, en_out_port : in std_logic;
		in_port0_input, in_port1_input, out_port_input : in std_logic_vector(width-1 downto 0);
		in_port0_output, in_port1_output, out_port_output : out std_logic_vector(width-1 downto 0)
        );
end entity;

architecture BHV of I_O_Ports is

begin

	IN_PORT0: entity work.reg
		generic map (
			width => 32
		)
		port map (
			clk 	=> clk,
			rst 	=> rst,
			en  	=> en_in_port0,
			input  	=> in_port0_input,
			output 	=> in_port0_output
		);

	IN_PORT1: entity work.reg
		generic map (
			width => 32
		)
		port map (
			clk 	=> clk,
			rst 	=> rst,
			en  	=> en_in_port1,
			input  	=> in_port1_input,
			output 	=> in_port1_output
		);

	OUT_PORT: entity work.reg
		generic map (
			width => 32
		)
		port map(
			clk 	=> clk,
			rst 	=> rst,
			en  	=> en_out_port,
			input  	=> out_port_input,
			output 	=> out_port_output
		);
		
end BHV;