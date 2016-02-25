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
   busy      : in STD_LOGIC;                    --indicates transaction in progress
   data_rd   : in STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
   ack_error : in STD_LOGIC;       --flag if improper acknowledge from slave
   sensorId : in STD_LOGIC_VECTOR(7 downto 0);
   delimeter : in STD_LOGIC_VECTOR(7 downto 0) -- delimeter character
   );             
end i2c_controller;

architecture Behavioral of i2c_controller is
-- state control signals
    type state_type is (STATE_WAITREADY, STATE_STARTREAD, STATE_WAIT_RX, STATE_GETBYTE, STATE_WRITEBYTE, STATE_FINISHWRITE, STATE_FINISHREAD, STATE_SLEEPCHK, STATE_SLEEPINC, STATE_HEADERWRITE, STATE_HEADERIDWRITE);
    signal state_reg: state_type := STATE_WAITREADY;
-- recd. byte counter
    signal ByteCount :INTEGER RANGE 0 to 7 := 0;
    signal delay : INTEGER RANGE 0 to 100000 := 0;
begin



-- state control
process (clk, FIFO_Full, busy, ack_error) -- process to handle the next state
begin
if rising_edge (clk) then
    case state_reg is
        when STATE_WAITREADY =>
        --reset the timers & counters
                    delay <= 0;
                    ByteCount<= 0;
                    -- make sure not enabled
                    ena <= '0';
            if (busy = '0') then
                state_reg <= STATE_STARTREAD;
            end if;
        when STATE_STARTREAD =>
           -- load the address and start a read
                 ena <= '1';
            if (busy = '1') then
                state_reg <= STATE_WAIT_RX;
            end if;
        when STATE_WAIT_RX =>
            if (busy = '0' and ack_error = '0') then
                    state_reg <= STATE_GETBYTE;
            else
                if (ack_error = '1') then
                    state_reg <= STATE_WAITREADY;
                end if;
            end if;
        when STATE_GETBYTE =>
            FIFO_DataIn <= data_rd;
            state_reg <= STATE_WRITEBYTE;
        when STATE_WRITEBYTE =>
            FIFO_WriteEn <= '1';
            ByteCount <= ByteCount + 1;
            state_reg <= STATE_FINISHWRITE;
        when STATE_FINISHWRITE => 
            FIFO_WriteEn <= '0';
            if (ByteCount = 4) then
                state_reg <=STATE_HEADERIDWRITE ;
            elsif (ByteCount = 5) then 
                state_reg <= STATE_HEADERWRITE;
            elsif (ByteCount = 6) then 
                state_reg <= STATE_SLEEPCHK;
            else
                state_reg <= STATE_FINISHREAD;
            end if;
        when STATE_FINISHREAD =>
            if (ByteCount = 3) then
                ena<='0';
            end if;
            if (busy ='1') then
                state_reg <= STATE_WAIT_RX;
            end if;
        when STATE_HEADERWRITE =>
            FIFO_DataIn <= delimeter;
            state_reg <= STATE_WRITEBYTE;
        when STATE_HEADERIDWRITE =>
            FIFO_DataIn <= sensorId;
            state_reg <= STATE_WRITEBYTE;
        when STATE_SLEEPCHK =>
           ena <= '0'; -- this might not be needed anymore.
            if (delay = 100000) then 
                state_reg <= STATE_WAITREADY;
            else
                state_reg <= STATE_SLEEPINC;
            end if;
        when STATE_SLEEPINC =>
            delay <= delay + 1; 
            state_reg <= STATE_SLEEPCHK;
        when others =>
            state_reg <= STATE_WAITREADY;
    end case;
end if;
end process;

	

end Behavioral;
