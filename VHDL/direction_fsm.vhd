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

entity direction_fsm is
    port ( 
           clk : in std_logic;
           update : in std_logic;
           input : in std_logic_vector(1 downto 0);
           direction : out std_logic_vector(1 downto 0));
end direction_fsm;

architecture behavioral of direction_fsm is

type state is (up, down, right, left);
signal current_state, next_state : state := right;

signal direction_sig : std_logic_vector(1 downto 0) := "10";

begin

state_update: process(clk)
begin
    if rising_edge(clk) then   
        if update = '1' then
            current_state <= next_state;
        end if;
    end if;
end process;


next_state_logic: process(current_state, input)
begin
    next_state <= current_state;
    case current_state is
        when up =>
            if input = "10" then
                next_state <= right;
            elsif input = "11" then
                next_state <= left;
            end if;
        when right =>
            if input = "01" then
                next_state <= down;
            elsif input = "00" then
                next_state <= up;
            end if;
        when down =>
            if input = "11" then 
                next_state <= left;
            elsif input = "10" then
                next_state <= right;
            end if;
        when left =>
            if input = "00" then
                next_state <= up;
            elsif input = "01" then
                next_state <= down;
            end if;
        when others => null;
    end case;
end process;

output_logic : process(current_state)
begin
    case current_state is
        when up => direction_sig <= "00";
        when down => direction_sig <= "01";
        when right => direction_sig <= "10";
        when left => direction_sig <= "11";
        when others => null;
    end case;
end process;

direction <= direction_sig;        

end behavioral;
