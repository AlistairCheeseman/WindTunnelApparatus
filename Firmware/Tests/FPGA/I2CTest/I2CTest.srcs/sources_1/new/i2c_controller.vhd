----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.01.2016 19:23:03
-- Design Name: 
-- Module Name: i2c_controller - Behavioral
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

entity i2c_controller is
 PORT(
   clk       : IN     STD_LOGIC;                    --system clock
   reset_n   : IN     STD_LOGIC;                    --active low reset
   --fifo pins
   FIFO_WriteEn : out STD_LOGIC;
   FIFO_DataIn: out std_logic_vector ( 7 downto 0);
   FIFO_Full : in STD_LOGIC;
   ena : out STD_LOGIC := '0'; --latch in command
   addr   : out STD_LOGIC_VECTOR(6 DOWNTO 0):= "0101000"; --address of target slave
   rw        : out STD_LOGIC;                    --'0' is write, '1' is read
   busy      : in STD_LOGIC;                    --indicates transaction in progress
   data_rd   : in STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
   ack_error : in STD_LOGIC       --flag if improper acknowledge from slave
   );             
end i2c_controller;

architecture Behavioral of i2c_controller is
-- state control signals
    type state_type is (STATE_WAITREADY, STATE_STARTREAD, STATE_WAIT_RX, STATE_GETBYTE, STATE_WRITEBYTE, STATE_FINISHWRITE, STATE_FINISHREAD, STATE_SLEEPCHK, STATE_SLEEPINC);
    signal state_next, state_reg: state_type := STATE_WAITREADY;
-- recd. byte counter
    signal finishFlag :STD_LOGIC;
    signal delay : INTEGER RANGE 0 to 200 := 0;
begin



-- state control
process (clk, FIFO_Full, busy, ack_error) -- process to handle the next state
begin
if rising_edge (clk) then
    case state_reg is
        when STATE_WAITREADY =>
            if (busy = '0') then
                state_next <= STATE_STARTREAD;
            end if;
        when STATE_STARTREAD =>
            if (busy = '1') then
                state_next <= STATE_WAIT_RX;
            end if;
        when STATE_WAIT_RX =>
            if (busy = '0' and ack_error = '0') then
                    state_next <= STATE_GETBYTE;
            else
                if (ack_error = '1') then
                    state_next <= STATE_WAITREADY;
                end if;
            end if;
        when STATE_GETBYTE =>
            state_next <= STATE_WRITEBYTE;
        when STATE_WRITEBYTE =>
            state_next <= STATE_FINISHWRITE;
        when STATE_FINISHWRITE => 
           if (finishFlag = '1') then
                state_next <= STATE_SLEEPCHK;
            else
                state_next <= STATE_FINISHREAD;
            end if;
        when STATE_FINISHREAD =>
            if (busy ='1') then
                state_next <= STATE_WAIT_RX;
            end if;
        when STATE_SLEEPCHK =>
            if (delay = 200) then 
                state_next <= STATE_WAITREADY;
            else
                state_next <= STATE_SLEEPINC;
            end if;
        when STATE_SLEEPINC =>
            state_next <= STATE_SLEEPCHK;
        when others =>
            state_next <= STATE_WAITREADY;
    end case;
end if;
state_reg <= state_next;
end process;

	
process(state_reg) -- process to handle the actual state change

begin
    case state_reg is
        when STATE_WAITREADY =>
            --reset the timers & counters
            delay <= 0;
            finishFlag<='0';
            -- make sure not enabled
            ena <= '0';
        when STATE_STARTREAD =>
            -- load the address and start a read
            ena <= '1';
             rw <= '1';
        when STATE_WAIT_RX =>
        when STATE_GETBYTE =>
            FIFO_DataIn <= data_rd;
        when STATE_WRITEBYTE =>
            FIFO_WriteEn <= '1';
        when STATE_FINISHWRITE =>
            FIFO_WriteEn <= '0';
        when STATE_FINISHREAD =>
           
            finishFlag <= '1';
        when STATE_SLEEPINC =>
            delay <= delay + 1; 
        when STATE_SLEEPCHK =>
         ena <= '0';
        when others =>
        --don't do anything, error handle
    end case;
end process;

end Behavioral;
