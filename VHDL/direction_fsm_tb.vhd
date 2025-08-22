----------------------------------------------------------------------------------
-- Authors: Mary Haferd and Owen Chen
-- Date: 8/17/2025
-- Name: direction_fsm_tb
-- Target: Basys 3
-- Description: testbench for direction FSM
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity direction_fsm_tb is
end direction_fsm_tb;

architecture testbench of direction_fsm_tb is

component direction_fsm is
    port ( clk : in std_logic;
           update : in std_logic;
           input : in std_logic_vector(1 downto 0);
           pause : in std_logic;
           reset : in std_logic;
           direction : out std_logic_vector(1 downto 0));
end component;

signal clk_sig : std_logic := '0';
signal update_sig : std_logic := '0';

constant clk_period : time := 10ns; -- 100 MHz

signal counter : unsigned(5 downto 0) := (others => '0'); -- 1 in 50
constant counter_tc : integer := 50;

signal input_sig : std_logic_vector(1 downto 0) := "10";
signal direction_sig : std_logic_vector(1 downto 0) := "10";

signal pause_sig : std_logic := '0';
signal reset_sig : std_logic := '0';

begin

uut: direction_fsm
    port map ( clk => clk_sig,
               update => update_sig,
               input => input_sig,
               pause => pause_sig,
               reset => reset_sig,
               direction => direction_sig);

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
    -- hold on right
    wait for 47 * clk_period; -- expect right
    
    -- move up
    input_sig <= "00";
    wait for 50 * clk_period; -- expect up

    -- move left
    input_sig <= "11";
    wait for 50 * clk_period; -- expect left
    
     -- move down
    input_sig <= "01";
    wait for 50 * clk_period; -- expect down
    
    -- move right
    input_sig <= "10";
    wait for 50 * clk_period; -- expect right
    
    --move down
    input_sig <= "01";
    wait for 50 * clk_period; -- expect down
    
    --move left
    input_sig <= "11";
    wait for 50 * clk_period; -- expect left
    
     --move up
    input_sig <= "00";
    wait for 50 * clk_period; -- expect up
    
     --move right
    input_sig <= "10";
    wait for 50 * clk_period; -- expect right
    
     --test input left when in right
    input_sig <= "11";
    wait for 50 * clk_period; -- still expect right
    
    --move up
    input_sig <= "00";
    wait for 50 * clk_period; -- expect up
    
    --test input down when in up
    input_sig <= "01";
    wait for 50 * clk_period; -- still expect up
    
    --test input left when paused in up
    pause_sig <= '1';
    input_sig <= "11";
    wait for 50 * clk_period; -- still expect up
    
    --test reset
    pause_sig <= '0';
    reset_sig <= '1';
    wait for 50 * clk_period; -- expect right
    
    reset_sig <= '0';
    wait for 10 * clk_period;
    
    --move up in between update pulses
    input_sig <= "00";
    wait for 10 * clk_period; -- still expect right
    
     --move down in between update pulses
    input_sig <= "01";
    wait for 10 * clk_period; -- still expect right
    
    input_sig <= "00";
    wait;
end process;

end testbench;
