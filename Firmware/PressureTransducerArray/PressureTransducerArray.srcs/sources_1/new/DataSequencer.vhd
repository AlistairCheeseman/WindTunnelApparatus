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
  --sensor 1
  I2C1_FIFO_ReadEn : out STD_LOGIC;
  I2C1_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C1_FIFO_Empty : in STD_LOGIC;
  --sensor 2
  I2C2_FIFO_ReadEn : out STD_LOGIC;
  I2C2_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C2_FIFO_Empty : in STD_LOGIC;
 --sensor 3
  I2C3_FIFO_ReadEn : out STD_LOGIC;
  I2C3_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C3_FIFO_Empty : in STD_LOGIC;
  --sensor 4
  I2C4_FIFO_ReadEn : out STD_LOGIC;
  I2C4_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C4_FIFO_Empty : in STD_LOGIC;
  --sensor 5
  I2C5_FIFO_ReadEn : out STD_LOGIC;
  I2C5_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C5_FIFO_Empty : in STD_LOGIC;
  --sensor 6
  I2C6_FIFO_ReadEn : out STD_LOGIC;
  I2C6_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C6_FIFO_Empty : in STD_LOGIC;
  --sensor 7
  I2C7_FIFO_ReadEn : out STD_LOGIC;
  I2C7_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C7_FIFO_Empty : in STD_LOGIC;
  --sensor 8
  I2C8_FIFO_ReadEn : out STD_LOGIC;
  I2C8_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C8_FIFO_Empty : in STD_LOGIC;
  --sensor 9
  I2C9_FIFO_ReadEn : out STD_LOGIC;
  I2C9_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C9_FIFO_Empty : in STD_LOGIC;
  --sensor 10
  I2C10_FIFO_ReadEn : out STD_LOGIC;
  I2C10_FIFO_DataOut : in STD_LOGIC_VECTOR ( 7 downto 0);
  I2C10_FIFO_Empty : in STD_LOGIC

   );
end DataSequencer;

architecture Behavioral of DataSequencer is
  type state_type is ( STATE_WAIT, STATE_STARTREAD, STATE_ENDREAD, STATE_WAITFULL,  STATE_STARTWRITE, STATE_FINISHWRITE,STATE_CLOCKIN, STATE_UPDATEMUX, STATE_EOL);
  signal state_reg: state_type := STATE_WAIT;
 
  constant Maxtimeout  : positive := 2500;
  
  signal multiplexerState : INTEGER RANGE 0 to 9 := 0;
  signal timeoutCount     : INTEGER RANGE 0 to Maxtimeout +5:= 0; -- wait 1ms before a timeout.
  signal currentByteCount : INTEGER RANGE 0 to 8:= 0; --6 bytes of data per sensor.
  
  
begin

process (clk, S_FIFO_Full, reset) -- process to handle the next state
begin
if (reset = '1') then
    --reset state:
    S_FIFO_WriteEn <= '0';
    state_reg <= STATE_WAIT;
    multiplexerState <= 0;
    timeoutCount <= 0;
    I2C1_FIFO_ReadEn <= '0';
    I2C2_FIFO_ReadEn <= '0';
    I2C3_FIFO_ReadEn <= '0';
    I2C4_FIFO_ReadEn <= '0';
    I2C5_FIFO_ReadEn <= '0';
    I2C6_FIFO_ReadEn <= '0';
    I2C7_FIFO_ReadEn <= '0';
    I2C8_FIFO_ReadEn <= '0';
    I2C9_FIFO_ReadEn <= '0';
    I2C10_FIFO_ReadEn <= '0';
else
    if rising_edge (clk) then
    case state_reg is
            when STATE_WAIT =>
              case multiplexerState is
                   when 0 =>
                       if (I2C1_FIFO_Empty = '1') then
                            if (currentByteCount = 0) then
                                timeoutCount <= timeoutCount + 1; -- increase the timeout count.
                                if (timeoutCount = Maxtimeout) then
                                    state_reg <= STATE_UPDATEMUX; -- timeout has occured, move to the next sensor.
                                else
                                    state_reg <= STATE_WAIT; -- else carry on waiting.
                                end if;
                            else
                                state_reg <= STATE_WAIT;
                            end if;
                       else
                            state_reg <= STATE_STARTREAD;
                       end if;
                   when 1 =>
                        if (I2C2_FIFO_Empty = '1') then
                            if (currentByteCount = 0) then
                                timeoutCount <= timeoutCount + 1; -- increase the timeout count.
                                if (timeoutCount = Maxtimeout) then
                                    state_reg <= STATE_UPDATEMUX; -- timeout has occured, move to the next sensor.
                                else
                                    state_reg <= STATE_WAIT; -- else carry on waiting.
                                end if;
                            else
                                state_reg <= STATE_WAIT;
                            end if;
                       else
                            state_reg <= STATE_STARTREAD;
                       end if;
                   when 2 =>
                       if (I2C3_FIFO_Empty = '1') then
                       if (currentByteCount = 0) then 
                        timeoutCount <= timeoutCount + 1; -- increase the timeout count.
                        if (timeoutCount = Maxtimeout) then
                            state_reg <= STATE_UPDATEMUX; -- timeout has occured, move to the next sensor.
                        else
                            state_reg <= STATE_WAIT; -- else carry on waiting.
                        end if;
                        else
                            state_reg <= STATE_WAIT;
                       end if;
                       else
                        state_reg <= STATE_STARTREAD;
                       end if;
                   when 3 =>
                       if (I2C4_FIFO_Empty = '1') then
                        if (currentByteCount = 0) then
                            timeoutCount <= timeoutCount + 1; -- increase the timeout count.
                            if (timeoutCount = Maxtimeout) then
                                state_reg <= STATE_UPDATEMUX; -- timeout has occured, move to the next sensor.
                            else
                                state_reg <= STATE_WAIT; -- else carry on waiting.
                            end if;
                        else
                            state_reg <= STATE_WAIT;
                        end if;
                       else
                        state_reg <= STATE_STARTREAD;
                       end if;
                   when 4 =>
                       if (I2C5_FIFO_Empty = '1') then
                            if (currentByteCount = 0) then
                                timeoutCount <= timeoutCount + 1; -- increase the timeout count.
                                if (timeoutCount = Maxtimeout) then
                                    state_reg <= STATE_UPDATEMUX; -- timeout has occured, move to the next sensor.
                                else
                                    state_reg <= STATE_WAIT; -- else carry on waiting.
                                end if;
                            else
                                state_reg <= STATE_WAIT;
                            end if;
                       else
                            state_reg <= STATE_STARTREAD;
                       end if;
                   when 5 =>
                       if (I2C6_FIFO_Empty = '1') then
                            if (currentByteCount = 0) then
                                timeoutCount <= timeoutCount + 1; -- increase the timeout count.
                                if (timeoutCount = Maxtimeout) then
                                    state_reg <= STATE_UPDATEMUX; -- timeout has occured, move to the next sensor.
                                else
                                    state_reg <= STATE_WAIT; -- else carry on waiting.
                                end if;
                            else
                                state_reg <= STATE_WAIT;
                            end if;
                       else
                        state_reg <= STATE_STARTREAD;
                       end if;
                   when 6 =>
                       if (I2C7_FIFO_Empty = '1') then
                            if (currentByteCount = 0) then
                                timeoutCount <= timeoutCount + 1; -- increase the timeout count.
                                if (timeoutCount = Maxtimeout) then
                                    state_reg <= STATE_UPDATEMUX; -- timeout has occured, move to the next sensor.
                                else
                                    state_reg <= STATE_WAIT; -- else carry on waiting.
                                end if;
                            else
                                state_reg <= STATE_WAIT;
                            end if;
                       else
                        state_reg <= STATE_STARTREAD;
                       end if;
                   when 7 =>
                       if (I2C8_FIFO_Empty = '1') then
                        if (currentByteCount = 0) then
                            timeoutCount <= timeoutCount + 1; -- increase the timeout count.
                            if (timeoutCount = Maxtimeout) then
                                state_reg <= STATE_UPDATEMUX; -- timeout has occured, move to the next sensor.
                            else
                                state_reg <= STATE_WAIT; -- else carry on waiting.
                            end if;
                        else
                            state_reg <= STATE_WAIT;
                        end if;
                       else
                        state_reg <= STATE_STARTREAD;
                       end if;
                   when 8 =>
                       if (I2C9_FIFO_Empty = '1') then
                            if (currentByteCount = 0) then
                                timeoutCount <= timeoutCount + 1; -- increase the timeout count.
                                if (timeoutCount = Maxtimeout) then
                                    state_reg <= STATE_UPDATEMUX; -- timeout has occured, move to the next sensor.
                                else
                                    state_reg <= STATE_WAIT; -- else carry on waiting.
                                end if;
                            else
                                state_reg <= STATE_WAIT;
                            end if;  
                       else
                        state_reg <= STATE_STARTREAD;
                       end if;
                   when 9 =>
                       if (I2C10_FIFO_Empty = '1') then
                            if (currentByteCount = 0) then
                                timeoutCount <= timeoutCount + 1; -- increase the timeout count.
                                if (timeoutCount = Maxtimeout) then
                                    state_reg <= STATE_UPDATEMUX; -- timeout has occured, move to the next sensor.
                                else
                                    state_reg <= STATE_WAIT; -- else carry on waiting.
                                end if;
                            else
                                state_reg <= STATE_WAIT;
                            end if;
                       else
                        state_reg <= STATE_STARTREAD;
                       end if;
                   when others =>        
               end case;
            when STATE_STARTREAD =>
                -- request the data
                case (multiplexerState) is
                    when 0 =>
                        I2C1_FIFO_ReadEn <= '1';
                    when 1 =>
                        I2C2_FIFO_ReadEn <= '1';
                    when 2 =>
                        I2C3_FIFO_ReadEn <= '1';
                    when 3 =>
                        I2C4_FIFO_ReadEn <= '1';
                    when 4 =>
                        I2C5_FIFO_ReadEn <= '1';
                    when 5 =>
                        I2C6_FIFO_ReadEn <= '1';
                    when 6 =>
                        I2C7_FIFO_ReadEn <= '1';
                    when 7 =>
                        I2C8_FIFO_ReadEn <= '1';
                    when 8 =>
                        I2C9_FIFO_ReadEn <= '1';
                    when 9 =>
                        I2C10_FIFO_ReadEn <= '1';
                    when others =>
                end case;
                state_reg <= STATE_ENDREAD;
            when STATE_ENDREAD =>
            --finish the request
                case (multiplexerState) is
                    when 0 =>
                        I2C1_FIFO_ReadEn <= '0';
                    when 1 =>
                        I2C2_FIFO_ReadEn <= '0';
                    when 2 =>
                        I2C3_FIFO_ReadEn <= '0';
                    when 3 =>
                        I2C4_FIFO_ReadEn <= '0';
                    when 4 =>
                        I2C5_FIFO_ReadEn <= '0';
                    when 5 =>
                        I2C6_FIFO_ReadEn <= '0';
                    when 6 =>
                        I2C7_FIFO_ReadEn <= '0';
                    when 7 =>
                        I2C8_FIFO_ReadEn <= '0';
                    when 8 =>
                        I2C9_FIFO_ReadEn <= '0';
                    when 9 =>
                        I2C10_FIFO_ReadEn <= '0';
                    when others =>
                end case;
                state_reg <= STATE_CLOCKIN;
            when STATE_CLOCKIN =>
                --clock the data out
                case (multiplexerState) is
                    when 0 =>
                        S_FIFO_DataIn <= I2C1_FIFO_DataOut;
                    when 1 =>
                        S_FIFO_DataIn <= I2C2_FIFO_DataOut;
                    when 2 =>
                        S_FIFO_DataIn <= I2C3_FIFO_DataOut;
                    when 3 =>
                        S_FIFO_DataIn <= I2C4_FIFO_DataOut;
                    when 4 =>
                        S_FIFO_DataIn <= I2C5_FIFO_DataOut;
                    when 5 =>
                        S_FIFO_DataIn <= I2C6_FIFO_DataOut;
                    when 6 =>
                        S_FIFO_DataIn <= I2C7_FIFO_DataOut;
                    when 7 =>
                        S_FIFO_DataIn <= I2C8_FIFO_DataOut;
                    when 8 =>
                        S_FIFO_DataIn <= I2C9_FIFO_DataOut;
                    when 9 =>
                        S_FIFO_DataIn <= I2C10_FIFO_DataOut;
                    when others =>
                    
                end case;
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
                currentByteCount <= currentByteCount +1; --- update the byte count.
            when STATE_FINISHWRITE => 
                S_FIFO_WriteEn <= '0';
                state_reg <= STATE_UPDATEMUX;
            when STATE_UPDATEMUX => -- when a read has just completed or a timeout has occured.
            -- this is called when one of these things have happened:
                    --> TIMEOUT - reading a sensor has timed out --> 
                        --> IF A TIMEOUT HAS HAPPENED ON SENSOR 10 --> WRITE EOL
                        --> ELSE just move onto next sensor
                    --> FINISH BYTE WRITE --> A byte has just finished writing
                        --> FINISH EOL - an EOL has just been written --> an EOL has just been written
                        --> FINISH SENSOR READ - 6 bytes have been read --> move onto the next sensor
                        --> FINISH BYTE READ - a byte has just been read --> read the next one
                    if (timeoutCount >= (MaxTimeout) AND CurrentByteCount = 0) then -- this has been called by a timeout.
                        if (multiplexerState = 9) then -- sensor 10 timeout, write the EOL.
                            state_reg <= STATE_EOL; -- write the EOL.
                        else
                            timeoutCount <= 0; -- reset the timeout counter
                            multiplexerState <= multiplexerState +1; -- move onto the next sensor.
                            state_reg <= STATE_WAIT;
                        end if;
                    else
                        -- a byte was just written.
                        if ((multiplexerState = 9 AND timeoutCount >= (MaxTimeout)) OR (currentByteCount = 7))  then -- the EOL was just written, start the read all over again.
                            timeoutCount<=0;
                            multiplexerState <= 0; 
                            currentByteCount <=0;
                            state_reg <= STATE_WAIT;
                        elsif (currentByteCount = 6) then -- the final byte of a sensor read was written 
                            if (multiplexerState = 9) then
                                timeoutCount <=0;
                                state_reg <= STATE_EOL;
                            else
                                timeoutCount<=0;
                                multiplexerState <= multiplexerState +1;
                                currentByteCount<=0;
                            end if;
                        else -- a byte has been read
                            state_reg <= STATE_WAIT;--don't need to do anything, just continue.                        
                        end if;
                    end if;
            when STATE_EOL =>
                S_FIFO_DataIn <= "11111111";
                state_reg <= STATE_STARTWRITE;
            when others =>
                state_reg <= STATE_WAIT;
    end case;
    end if;
end if;    
end process;


end Behavioral;
