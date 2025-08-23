----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/23/2025
-- Name: randomizer_toplevel
-- Target: Basys 3
-- Description: ouputs random numbers from LFSR randomizer
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity randomizer_toplevel is
    port ( clk_ext : in std_logic;
           reset_button : in std_logic;
           rand_out : out std_logic_vector(7 downto 0);
           clk_out : out std_logic );
end randomizer_toplevel;

architecture toplevel of randomizer_toplevel is

component lfsr_randomizer is
    port ( clk : in std_logic;
           reset : in std_logic;
           rand : out std_logic_vector(7 downto 0) );
end component;

component system_clock_generation is
    Generic( CLK_DIVIDER_RATIO : integer := 1e6 );
    Port (
        --External Clock:
        input_clk_port		: in std_logic;
        --System Clock:
        system_clk_port		: out std_logic);
end component;

signal clk_sig : std_logic := '0';

begin

lfsr: lfsr_randomizer
    port map ( clk => clk_sig,
               reset => reset_button,
               rand => rand_out );
               
clkgen: system_clock_generation
    port map ( input_clk_port => clk_ext,
               system_clk_port => clk_sig );
               
clk_out <= clk_sig;

end toplevel;
