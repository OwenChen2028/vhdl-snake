----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/23/2025
-- Name: randomizer_tb
-- Target: Basys 3
-- Description: testbench for LFSR randomizer
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity randomizer_tb is
end randomizer_tb;

architecture testbench of randomizer_tb is

component lfsr_randomizer is
    port ( clk : in std_logic;
           reset : in std_logic;
           rand : out std_logic_vector(7 downto 0) );
end component;

signal clk_sig : std_logic := '0';
constant clk_period : time := 10ns; -- 100 MHz

signal reset_sig : std_logic := '0';
signal rand_sig : std_logic_vector(7 downto 0) := (others => '0');

begin

uut: lfsr_randomizer
    port map ( clk => clk_sig,
               reset => reset_sig,
               rand => rand_sig );

clkgen_proc : process
begin
    clk_sig <= not(clk_sig);
    wait for clk_period / 2;
end process;

stim_proc : process
begin
    wait for 10 * clk_period;
    reset_sig <= '1';
    wait for 5 * clk_period;
    reset_sig <= '0';
    wait;
end process;

end testbench;
