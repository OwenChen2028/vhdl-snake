----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd 
-- Date: 8/21/2025
-- Name: game_fsm_tb
-- Target: Basys 3
-- Description: testbench for game FSM
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_fsm_tb is
end game_fsm_tb;

architecture testbench of game_fsm_tb is

component game_state_fsm is
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
end component;

signal clk_sig : std_logic := '0';
signal update_sig : std_logic := '0';

constant clk_period : time := 10ns; -- 100 MHz

signal counter : unsigned(5 downto 0) := (others => '0'); -- 1 in 50
constant counter_tc : integer := 50;

signal pressed_sig : std_logic := '0';
signal full_sig : std_logic := '0';
signal crash_sig : std_logic := '0';

signal pause_db_sig : std_logic := '0';
signal reset_db_sig : std_logic := '0';

signal reset_sync_sig : std_logic := '0';
signal move_sig : std_logic := '0';
signal done_sig : std_logic := '0';

begin

uut: game_state_fsm
    port map ( clk => clk_sig,
               update => update_sig,
               pressed => pressed_sig,
               full => full_sig,
               crash => crash_sig,
               pause_db => pause_db_sig,
               reset_db => reset_db_sig,
               reset_sync => reset_sync_sig,
               move => move_sig,
               done => done_sig );

clkgen_proc : process
begin
    clk_sig <= not(clk_sig);
    wait for clk_period / 2;
end process;

-- generate pulse
update_pulsegen_proc : process -- 2MHz instead of 2Hz for testing purposes
begin
    if (counter + 1) = to_unsigned(counter_tc - 1, 6) then
        update_sig <= '1';
    else
        update_sig <= '0';
    end if;
    
    if counter = to_unsigned(counter_tc - 1, 6) then
        counter <= (others => '0');
    else
        counter <= counter + 1;
    end if;

    wait for clk_period;
end process;

stim_proc : process
begin
    -- start in idle state
    wait for 47 * clk_period; -- wait until next update
    
    -- test active state
    pressed_sig <= '1';
    wait for 50 * clk_period; -- expect move high
    pressed_sig <= '0';
    
    -- test pause state
    pause_db_sig <= '1';
    wait for 50 * clk_period; -- expect move low
    pressed_sig <= '1';
    wait for 50 * clk_period; -- still expect move low
    pressed_sig <= '0';
    
    -- test leaving pause
    pause_db_sig <= '0';
    wait for 50 * clk_period; -- expect move high
    
    -- test crashing
    crash_sig <= '1';
    wait for 50 * clk_period; -- expect done
    crash_sig <= '0';
    pressed_sig <= '1';
    wait for 50 * clk_period; -- expect no change
    pressed_sig <= '0';
    
    -- test reset
    reset_db_sig <= '1';
    wait for 50 * clk_period; -- expect reset sync
    reset_db_sig <= '0';
    
    wait for 50 * clk_period;
    
    -- test winning
    pressed_sig <= '1';
    wait for 50 * clk_period; -- expect move
    pressed_sig <= '0';
    full_sig <= '1';
    wait for 50 * clk_period; -- expect done
    full_sig <= '0';
    
    -- test reset again
    reset_db_sig <= '1';
    wait for 50 * clk_period; -- expect reset sync
    reset_db_sig <= '0';
    
    wait for 50 * clk_period;
    
    -- test idle to pause
    pause_db_sig <= '1';
    wait for 50 * clk_period; -- expect move low
    pressed_sig <= '1';
    wait for 50 * clk_period; -- still expect move low
    pressed_sig <= '0';
    
    wait;
end process;

end testbench;
