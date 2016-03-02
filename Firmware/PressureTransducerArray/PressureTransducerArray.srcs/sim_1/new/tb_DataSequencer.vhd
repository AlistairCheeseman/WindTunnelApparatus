----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.03.2016 15:04:38
-- Design Name: 
-- Module Name: tb_DataSequencer - Behavioral
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

entity tb_DataSequencer is
--  Port ( );
end tb_DataSequencer;

architecture Behavioral of tb_DataSequencer is
constant Clk_period : time := 10ns;
signal clk :STD_LOGIC;
signal reset:STD_LOGIC;


 signal  Serial_FIFO_WriteEn : STD_LOGIC;
 signal  Serial_FIFO_DataIn : STD_LOGIC_VECTOR ( 7 downto 0);
 signal  Serial_FIFO_Full :  STD_LOGIC:= '0';
  --sensor 1
signal   I2C1_FIFO_ReadEn : STD_LOGIC;
 signal  I2C1_FIFO_DataOut :STD_LOGIC_VECTOR ( 7 downto 0):= "00001010";
 signal  I2C1_FIFO_Empty :  STD_LOGIC:= '0';
  --sensor 2
 signal  I2C2_FIFO_ReadEn :  STD_LOGIC;
  signal I2C2_FIFO_DataOut :  STD_LOGIC_VECTOR ( 7 downto 0);
 signal  I2C2_FIFO_Empty :  STD_LOGIC:= '0';
 --sensor 3
 signal  I2C3_FIFO_ReadEn :  STD_LOGIC;
 signal  I2C3_FIFO_DataOut :  STD_LOGIC_VECTOR ( 7 downto 0);
 signal I2C3_FIFO_Empty :  STD_LOGIC:= '0';
  --sensor 4
 signal  I2C4_FIFO_ReadEn :  STD_LOGIC;
 signal  I2C4_FIFO_DataOut :  STD_LOGIC_VECTOR ( 7 downto 0);
 signal  I2C4_FIFO_Empty :  STD_LOGIC:= '0';
  --sensor 5
 signal  I2C5_FIFO_ReadEn :  STD_LOGIC;
 signal  I2C5_FIFO_DataOut :  STD_LOGIC_VECTOR ( 7 downto 0);
 signal  I2C5_FIFO_Empty :  STD_LOGIC:= '0';
  --sensor 6
 signal  I2C6_FIFO_ReadEn : STD_LOGIC;
 signal  I2C6_FIFO_DataOut :  STD_LOGIC_VECTOR ( 7 downto 0);
 signal  I2C6_FIFO_Empty :  STD_LOGIC:= '0';
  --sensor 7
 signal  I2C7_FIFO_ReadEn :  STD_LOGIC;
 signal  I2C7_FIFO_DataOut :  STD_LOGIC_VECTOR ( 7 downto 0);
 signal  I2C7_FIFO_Empty :  STD_LOGIC:= '0';
  --sensor 8
 signal  I2C8_FIFO_ReadEn :  STD_LOGIC;
 signal  I2C8_FIFO_DataOut :  STD_LOGIC_VECTOR ( 7 downto 0);
 signal  I2C8_FIFO_Empty :  STD_LOGIC:= '0';
  --sensor 9
 signal  I2C9_FIFO_ReadEn :  STD_LOGIC;
 signal  I2C9_FIFO_DataOut :  STD_LOGIC_VECTOR ( 7 downto 0);
 signal  I2C9_FIFO_Empty : STD_LOGIC:= '0';
  --sensor 10
 signal  I2C10_FIFO_ReadEn :  STD_LOGIC;
 signal  I2C10_FIFO_DataOut :  STD_LOGIC_VECTOR ( 7 downto 0);
 signal  I2C10_FIFO_Empty :  STD_LOGIC:= '0';
begin


-- Clock process definitions
   Clk_process :process
   begin
		clk <= '0';
		wait for Clk_period/2;
		clk <= '1';
		wait for Clk_period/2;
   end process;


UUT:entity work.DataSequencer(Behavioral)
    port map (
    clk => clk,
    reset => reset,
    S_FIFO_WriteEn => Serial_FIFO_WriteEn,
    S_FIFO_DataIn => Serial_FIFO_DataIn,
    S_FIFO_Full => Serial_FIFO_Full,
    
    I2C1_FIFO_ReadEn    => I2C1_FIFO_ReadEn,
    I2C1_FIFO_DataOut   => I2C1_FIFO_DataOut,
    I2C1_FIFO_Empty     => I2C1_FIFO_Empty,
    
    I2C2_FIFO_ReadEn    => I2C2_FIFO_ReadEn,
    I2C2_FIFO_DataOut   => I2C2_FIFO_DataOut,
    I2C2_FIFO_Empty     => I2C2_FIFO_Empty,
    
    I2C3_FIFO_ReadEn    => I2C3_FIFO_ReadEn,
    I2C3_FIFO_DataOut   => I2C3_FIFO_DataOut,
    I2C3_FIFO_Empty     => I2C3_FIFO_Empty,
    
    I2C4_FIFO_ReadEn    => I2C4_FIFO_ReadEn,
    I2C4_FIFO_DataOut   => I2C4_FIFO_DataOut,
    I2C4_FIFO_Empty     => I2C4_FIFO_Empty,
    
    I2C5_FIFO_ReadEn    => I2C5_FIFO_ReadEn,
    I2C5_FIFO_DataOut   => I2C5_FIFO_DataOut,
    I2C5_FIFO_Empty     => I2C5_FIFO_Empty,
    
    I2C6_FIFO_ReadEn    => I2C6_FIFO_ReadEn,
    I2C6_FIFO_DataOut   => I2C6_FIFO_DataOut,
    I2C6_FIFO_Empty     => I2C6_FIFO_Empty,
    
    I2C7_FIFO_ReadEn    => I2C7_FIFO_ReadEn,
    I2C7_FIFO_DataOut   => I2C7_FIFO_DataOut,
    I2C7_FIFO_Empty     => I2C7_FIFO_Empty,
    
    I2C8_FIFO_ReadEn    => I2C8_FIFO_ReadEn,
    I2C8_FIFO_DataOut   => I2C8_FIFO_DataOut,
    I2C8_FIFO_Empty     => I2C8_FIFO_Empty,
    
    I2C9_FIFO_ReadEn    => I2C9_FIFO_ReadEn,
    I2C9_FIFO_DataOut   => I2C9_FIFO_DataOut,
    I2C9_FIFO_Empty     => I2C9_FIFO_Empty,
    
    I2C10_FIFO_ReadEn   => I2C10_FIFO_ReadEn,
    I2C10_FIFO_DataOut  => I2C10_FIFO_DataOut,
    I2C10_FIFO_Empty    => I2C10_FIFO_Empty
    
    );


end Behavioral;
