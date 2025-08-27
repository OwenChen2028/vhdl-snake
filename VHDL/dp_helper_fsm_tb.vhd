----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd 
-- Date: 8/24/2025
-- Name: dp_helper_fsm_tb
-- Target: Basys 3
-- Description: testbench for grid helper FSM
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dp_helper_fsm_tb is
end dp_helper_fsm_tb;

architecture testbench of dp_helper_fsm_tb is

component dp_helper_fsm is
    port ( clk : in std_logic;
           update : in std_logic;
           move : in std_logic;
		   full : in std_logic;
		   crash : in std_logic;
           grow : in std_logic;
           eaten : in std_logic;
		   reset : in std_logic;
           mv_head : out std_logic;
		   rm_tail : out std_logic;
		   put_head : out std_logic;
		   put_fruit : out std_logic );
end component;

signal clk_sig : std_logic := '1';
constant clk_period : time := 10ns; -- 100 MHz

signal update_sig : std_logic := '0';

signal move_sig : std_logic := '0';

signal full_sig : std_logic := '0';
signal crash_sig : std_logic := '0';

signal grow_sig : std_logic := '0';
signal eaten_sig : std_logic := '0';

signal reset_sig : std_logic := '0';

signal mv_head_sig : std_logic := '0';
signal rm_tail_sig : std_logic := '0';
signal put_head_sig : std_logic := '0';
signal put_fruit_sig : std_logic := '0';

begin

uut: dp_helper_fsm
    port map ( clk => clk_sig,
               update => update_sig,
               move => move_sig,
               full => full_sig,
               crash => crash_sig,
               grow => grow_sig,
               eaten => eaten_sig,
               reset => reset_sig,
               mv_head => mv_head_sig,
               rm_tail => rm_tail_sig,
               put_head => put_head_sig,
               put_fruit => put_fruit_sig );

clkgen_proc : process
begin
    clk_sig <= not(clk_sig);
    wait for clk_period / 2;
end process;

stim_proc : process
begin
    -- start in idle state
    wait for 2 * clk_period; -- expect all low
    
    -- test move input
    move_sig <= '1';
    wait for clk_period; -- expect mv head high
    
    -- wait for buffer
    wait for clk_period; -- expect all low
    
    -- test grow input
    grow_sig <= '1';
    wait for clk_period; -- expect put head high, skipping rm tail
    grow_sig <= '0';

    -- wait for buffer
    wait for clk_period;
    
    -- test place fruit state
    eaten_sig <= '1';
    wait for 10 * clk_period; -- expect oscillating put_fruit
    eaten_sig <= '0';
    
    -- test done retrying
    wait for 2 * clk_period; -- expect all low
    
    -- test next update pulse
    update_sig <= '1';
    wait for 1 * clk_period;
    update_sig <= '0';
    wait for 5 * clk_period; -- cycle repeats
    
    -- test crash input
    crash_sig <= '1'; -- interrupt it
    wait for 5 * clk_period; -- expect all low
    crash_sig <= '0';
    
    -- test full input
    wait for 5 * clk_period; -- repeat cycle again
    full_sig <= '1'; -- interrupt it
    wait for 5 * clk_period; -- expect all low
    full_sig <= '0';
    
    -- test reset input
    wait for 5 * clk_period; -- repeat cycle again
    reset_sig <= '1'; -- interrupt it
    move_sig <= '0'; -- stop moving as well
    wait for 5 * clk_period; -- expect all low
    reset_sig <= '0';
    
    wait;
end process;

end testbench;
