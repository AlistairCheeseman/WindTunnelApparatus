----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.01.2016 17:22:42
-- Design Name: 
-- Module Name: serialLoader - Behavioral
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

entity serialLoader is
  Port (
  --serial control data
   S_Send : out STD_LOGIC:='0';
   S_DataOut : out  std_logic_vector (7 downto 0);
   S_Ready : in STD_LOGIC;
   --FIFO DATA
   FIFO_Empty   : in STD_LOGIC;                                    -- flag if no data is left
   FIFO_Data    : in  STD_LOGIC_VECTOR (7 downto 0);   -- actual data
   FIFO_ReadEn  : out STD_LOGIC := '0';                                    -- enable read
   -- global clock
   clk : in STD_LOGIC;
   reset: in STD_LOGIC
   );
end serialLoader;

architecture Behavioral of serialLoader is
    type state_type is ( STATE_WAIT, STATE_STARTREAD, STATE_ENDREAD, STATE_STARTWRITE, STATE_ENDWRITE, STATE_CLOCKIN);
    signal state_reg: state_type := STATE_WAIT;
    
begin

process (clk, FIFO_Empty, S_Ready, reset) -- process to handle the next state
begin
if (reset = '1') then
    --reset state:
    FIFO_ReadEn <= '0';
    S_Send <= '0';
    state_reg <= STATE_WAIT;
else
    if rising_edge (clk) then
        case state_reg is
            when STATE_WAIT =>
                if (FIFO_Empty = '1' or S_Ready = '0') then
                    state_reg <= STATE_WAIT;
                else
                    state_reg <= STATE_STARTREAD;
                end if;
            when STATE_STARTREAD =>
                -- request the data
                FIFO_ReadEn <= '1';
                state_reg <= STATE_ENDREAD;

            when STATE_ENDREAD =>
                FIFO_ReadEn <= '0';
                state_reg <= STATE_CLOCKIN;
            when STATE_CLOCKIN =>
                --clock the data out
                S_DataOut <= FIFO_Data;
                state_reg <= STATE_STARTWRITE;
            when STATE_STARTWRITE =>
                    -- tell the serial module to pickup the data
                S_Send <= '1';
                state_reg <= STATE_ENDWRITE;
            when STATE_ENDWRITE =>
                -- close all the modules down
                S_Send <= '0';
                --if (FIFO_Empty = '0' and S_Ready = '1') then
                --    state_reg <= STATE_STARTREAD;
                --else
                    state_reg <= STATE_WAIT;
                --end if;
            when others =>
                state_reg <= STATE_WAIT;
        end case;
    end if;
end if;    
end process;
end Behavioral;
