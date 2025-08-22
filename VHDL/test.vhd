----------------------------------------------------------------------------------
-- Authors: Mary Haferd and Owen Chen
-- Date: 8/17/2025
-- Name: direction_fsm
-- Target: Basys 3
-- Description: FSM providing snake direction
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test is
    port ( 
           clk : in std_logic;
           update : in std_logic;
           input : in std_logic_vector(1 downto 0);
           value : out std_logic_vector(7 downto 0));
end test;

architecture behavioral of test is

type cols is array (10 downto 0) of std_logic_vector(7 downto 0);
type rows is array (15 downto 0) of cols;

signal grid : rows;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if update = '1' then
                grid(10)(5) <= "10101010";
            else
                grid(10)(5) <= "01010101";
            end if;
        end if;
    end process;
    
    value <= grid(10)(5);
end behavioral;
