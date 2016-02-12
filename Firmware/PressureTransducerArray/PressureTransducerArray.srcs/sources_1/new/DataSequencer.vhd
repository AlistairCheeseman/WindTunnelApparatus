----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.02.2016 21:28:53
-- Design Name: 
-- Module Name: DataSequencer - Behavioral
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

entity DataSequencer is
  Port (
      clk :in STD_LOGIC;
  reset : in STD_LOGIC;
  S_FIFO_WriteEn : out STD_LOGIC;
  S_FIFO_DataIn : out STD_LOGIC_VECTOR ( 7 downto 0);
  S_FIFO_Full : in STD_LOGIC;
  I2C_FIFO_ReadEn : out STD_LOGIC;
  I2C_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C_FIFO_Empty : in STD_LOGIC
   );
end DataSequencer;

architecture Behavioral of DataSequencer is
  type state_type is ( STATE_WAIT, STATE_STARTREAD, STATE_ENDREAD, STATE_WAITFULL,  STATE_STARTWRITE, STATE_FINISHWRITE);
  signal state_reg: state_type := STATE_WAIT;
begin

process (clk, I2C_FIFO_Empty, S_FIFO_Full, reset) -- process to handle the next state
begin
if (reset = '1') then
    --reset state:
    I2C_FIFO_ReadEn <= '0';
    S_FIFO_WriteEn <= '0';
    state_reg <= STATE_WAIT;
else
    if rising_edge (clk) then
    case state_reg is
            when STATE_WAIT =>
                    if (I2C_FIFO_Empty = '1') then
                        state_reg <= STATE_WAIT;
                    else
                        state_reg <= STATE_STARTREAD;
                    end if;
            when STATE_STARTREAD =>
                -- request the data
                I2C_FIFO_ReadEn <= '1';
                state_reg <= STATE_ENDREAD;
            when STATE_ENDREAD =>
                    --clock the data out
                S_FIFO_DataIn <= I2C_FIFO_DataOut;
                I2C_FIFO_ReadEn <= '0';
                if ('0' = S_FIFO_Full) then 
                    state_reg <= STATE_STARTWRITE;
                else
                    state_reg <= STATE_WAITFULL;
                end if;
            when STATE_WAITFULL =>
                if (S_FIFO_Full = '0') then
                    state_reg <= STATE_STARTWRITE;
                else
                    state_reg <= STATE_WAITFULL;
                end if;
            when STATE_STARTWRITE =>
                S_FIFO_WriteEn <= '1';
                state_reg <= STATE_FINISHWRITE;
            when STATE_FINISHWRITE => 
                S_FIFO_WriteEn <= '0';
                state_reg <= STATE_WAIT;
            when others =>
                state_reg <= STATE_WAIT;
    end case;
    end if;
end if;    
end process;
end Behavioral;
