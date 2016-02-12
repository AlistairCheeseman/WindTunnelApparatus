----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2016 23:50:03
-- Design Name: 
-- Module Name: SimALL - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SimALL is
--  Port ( );
end SimALL;

architecture Behavioral of SimALL is
constant Clk_period : time := 10ns;
signal clk  : STD_LOGIC; 
signal JA0 : STD_LOGIC; 
signal JA1 : STD_LOGIC;
signal JA2 : STD_LOGIC;
signal JA3  : STD_LOGIC;
signal RsTx : STD_LOGIC;
signal btnCpuReset : STD_LOGIC := '1';
begin

UUT: entity work.topmodule(Behavioral)
    port map (
        clk         => clk,
        btnCpuReset => btnCpuReset,
       JA0 => JA0,
         JA1 => JA1,
           JA2 => JA2,
             JA3 => JA3,
        RsTx => RsTx
  );

-- Clock process definitions
   Clk_process :process
   begin
		clk <= '0';
		wait for Clk_period/2;
		clk <= '1';
		wait for Clk_period/2;
   end process;

-- random reset program
    reset_process : process
    begin 
        JA1 <= 'H';
        btnCpuReset <= '0';
        wait for Clk_period * 200;
        btnCpuReset <= '1';
        wait for Clk_period * 2550;
        JA1 <= '0';
        wait for Clk_period * 249;
        JA1 <= 'H';
        wait for Clk_period * 999;
        wait for Clk_period * 999;
        wait;
        end process;
JA0 <= 'H';
end Behavioral;
