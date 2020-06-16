library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity controller_TB is
end controller_TB;

architecture BHV of controller_TB is 

	signal clk 			:  std_logic := '0';
	signal rst			:  std_logic := '0';	
	signal IR31to26		:  std_logic_vector(5 downto 0) := (others => '0');
	signal IR5to0		:  std_logic_vector(5 downto 0) := (others => '0');
	signal PCWrite 		:  std_logic := '0';
	signal PCWriteCond  :  std_logic := '0';
	signal IorD 		:  std_logic := '0';
	signal MemRead		:  std_logic := '0';
	signal MemWrite 	:  std_logic := '0';
	signal MemToReg 	:  std_logic := '0';
	signal IRWrite 		:  std_logic := '0';
	signal JumpAndLink  :  std_logic := '0';
	signal IsSigned 	:  std_logic := '0';
	signal PCSource 	:  std_logic_vector(1 downto 0) := (others => '0');
	signal ALUOp 		:  std_logic_vector(3 downto 0) := (others => '0');
	signal ALUSrcA 		:  std_logic := '0';
	signal ALUSrcB 		:  std_logic_vector(1 downto 0) := (others => '0');
	signal RegWrite 	:  std_logic := '0';
	signal RegDst 		:  std_logic := '0';
	signal switches 	:  std_logic_vector(9 downto 0) := (others => '0');
	signal buttons 		:  std_logic_vector(1 downto 0) := (others => '0');
	signal LEDs 		:  std_logic_vector(31 downto 0) := (others => '0');

begin

	U_CONTROLLER: entity work.controller
		generic map(
			width => 32
		)
		port map(
			clk 		=> clk,
			rst			=> rst,
			IR31to26	=> IR31to26,
			IR5to0		=> IR5to0,
			PCWrite 	=> PCWrite,
			PCWriteCond => PCWriteCond,
			IorD 		=> IorD,
			MemRead		=> MemRead,
			MemWrite 	=> MemWrite,
			MemToReg 	=> MemToReg,
			IRWrite 	=> IRWrite,
			JumpAndLink => JumpAndLink,
			IsSigned 	=> IsSigned,
			PCSource 	=> PCSource,
			ALUOp 		=> ALUOp,
			ALUSrcA 	=> ALUSrcA,
			ALUSrcB 	=> ALUSrcB,
			RegWrite 	=> RegWrite,
			RegDst 		=> RegDst
		);

	U_DATAPATH: entity work.datapath
		generic map(
			width => 32
		)
		port map(
			clk 		=> clk,
			rst			=> rst,
			IR31to26	=> IR31to26,
			IR5to0_out	=> IR5to0,
			PCWrite 	=> PCWrite,
			PCWriteCond => PCWriteCond,
			IorD 		=> IorD,
			MemRead		=> MemRead,
			MemWrite 	=> MemWrite,
			MemToReg 	=> MemToReg,
			IRWrite 	=> IRWrite,
			JumpAndLink => JumpAndLink,
			IsSigned 	=> IsSigned,
			PCSource 	=> PCSource,
			ALUOp 		=> ALUOp,
			ALUSrcA 	=> ALUSrcA,
			ALUSrcB 	=> ALUSrcB,
			RegWrite 	=> RegWrite,
			RegDst 		=> RegDst,
			switches 	=> switches,
			buttons 	=> buttons,
			LEDs		=> LEDs
		);
	
	clk <= not clk after 10 ns;
	
	process
	begin
	
		rst <= '1';
		wait for 10 ns;
		rst <= '0';
		
		--Load inport0
		switches <= "0111111111";
		buttons <= "01";
		wait until rising_edge(clk);
		
		--Load inport1
		switches <= (others => '1');
		buttons <= "10";
		wait until rising_edge(clk);
		
		--turn off enables for inports
		buttons <= "00";
	
		--interate through mif file clock cycles
		for i in 0 to 20 loop 
			wait until rising_edge(clk);
		end loop;

		report "DONE!"; 
		wait; 
	
	end process;

end BHV;