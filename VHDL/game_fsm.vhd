----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/21/2025
-- Name: game_fsm
-- Target: Basys 3
-- Description: FSM for tracking game state
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_fsm is
    port ( clk : in std_logic;
           update : in std_logic;
           pressed : in std_logic;
		   full : in std_logic;
		   crash : in std_logic;
           pause_db : in std_logic;
		   reset_db : in std_logic;
           reset_sync : out std_logic;
		   move : out std_logic;
		   done : out std_logic );
end game_fsm;

architecture behavioral of game_fsm is

type state is (idle, active, pause, reset, over);
signal current_state, next_state : state := idle;

signal move_sig : std_logic := '0';
signal reset_sig : std_logic := '0';
signal done_sig : std_logic := '0';

begin

state_update: process(clk)
begin
    if rising_edge(clk) then
        if update = '1' then
            current_state <= next_state;
        end if;
    end if;
end process;

next_state_logic: process(current_state, pressed, full, crash, pause_db, reset_db)
begin
    next_state <= current_state;
	if reset_db = '1' then -- includes only transition out of over state
		next_state <= reset;
	else
        case current_state is
            when idle =>
                if pause_db = '1' then
                    next_state <= pause;
                elsif pressed = '1' then
                    next_state <= active;
                end if;
            when active =>
                if crash = '1' or full = '1' then
                    next_state <= over;
                elsif pause_db = '1' then
                    next_state <= pause;
                end if;
            when pause =>
                if pause_db = '0' then 
                    next_state <= active;
                end if;
            when reset =>
                if reset_db = '0' then
                    next_state <= idle;
                end if;
            when others =>
                null;
        end case;
    end if;
end process;

output_logic : process(current_state)
begin
	move_sig <= '0';
	reset_sig <= '0';
	done_sig <= '0';
    case current_state is
        when active =>
            move_sig <= '1';
        when reset =>
            reset_sig <= '1'; 
       when over => 
            done_sig <= '1';
       when others =>
            null;
    end case;
end process;

move <= move_sig;
reset_sync <= reset_sig;
done <= done_sig;

end behavioral;
