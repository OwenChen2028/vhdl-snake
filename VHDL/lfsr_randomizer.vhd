----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/23/2025
-- Name: lfsr_randomizer
-- Target: Basys 3
-- Description: produces random output
----------------------------------------------------------------------------------

-- CITATION: referenced https://www.engineersgarage.com/feed-back-register-in-vhdl/

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lfsr_randomizer is
    port ( clk : in std_logic;
           reset : in std_logic;
           rand : out std_logic_vector(7 downto 0) );
end lfsr_randomizer;

architecture behavioral of lfsr_randomizer is

constant seed : unsigned(7 downto 0) := "00000001";
signal rand_sig : unsigned(7 downto 0) := seed;

begin

process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            rand_sig <= seed;
        else 
            rand_sig <= (rand_sig(0) xor rand_sig(2) xor rand_sig(3) xor rand_sig(4)) & rand_sig(7 downto 1); 
                        
        end if;
    end if;
end process;

rand <= std_logic_vector(rand_sig - 1); -- include 0 in output range

end behavioral;
