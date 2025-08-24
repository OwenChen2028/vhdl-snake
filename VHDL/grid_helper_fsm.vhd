----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/24/2025
-- Name: grid_helper_fsm
-- Target: Basys 3
-- Description: FSM for coordinating grid operations
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity grid_helper_fsm is
    port ( clk : in std_logic;
           move : in std_logic;
		   full : in std_logic;
		   crash : in std_logic;
           grow : in std_logic;
           finished : in std_logic;
		   reset : in std_logic;
           mv_head : out std_logic;
		   rm_tail : out std_logic;
		   put_head : out std_logic;
		   put_fruit : out std_logic );
end grid_helper_fsm;

architecture behavioral of grid_helper_fsm is

type state is (idle, move_head, buffer1, buffer2, remove_tail, place_head, buffer3, place_fruit);
signal current_state, next_state : state := idle; -- start state

signal mv_head_sig : std_logic := '0';
signal rm_tail_sig : std_logic := '0';
signal put_head_sig : std_logic := '0';
signal put_fruit_sig : std_logic := '0';

begin

state_update: process(clk)
begin
    if rising_edge(clk) then
        current_state <= next_state;
    end if;
end process;

next_state_logic: process(current_state, move, full, crash, grow, finished, reset)
begin
    if reset = '1' or full = '1' or crash = '1' or finished = '1' then
        next_state <= idle; -- go to start state
    else
        next_state <= current_state; -- derfault to current
        case current_state is
            when idle =>
                if move = '1' then
                    next_state <= move_head;
                end if;
            when move_head =>
                next_state <= buffer1; -- wait for head pos to update in datapath
            when buffer1 =>
                next_state <= buffer2; -- wait for full to update in datapath
            when buffer2 =>
                if grow = '1' then
                    next_state <= place_head; -- skip remove tail state
                else -- grow is 0
                    next_state <= remove_tail;
                end if; 
            when remove_tail =>
                next_state <= place_head;
            when place_head =>
                next_state <= buffer3; -- wait for head to be placed in datapath
            when buffer3 =>
                next_state <= place_fruit;
            when place_fruit =>
                next_state <= buffer3; -- wait for finished to update before retrying, loop until finished or reset
            when others =>
                null;
        end case;
    end if;
end process;

output_logic : process(current_state)
begin
	mv_head_sig <= '0';
    rm_tail_sig <= '0';
    put_head_sig <= '0';
    put_fruit_sig <= '0';
    case current_state is
        when move_head =>
            mv_head_sig <= '1';
        when remove_tail =>
            rm_tail_sig <= '1'; 
       when place_head => 
            put_head_sig <= '1';
       when place_fruit =>
            put_fruit_sig <= '1';
       when others =>
            null; -- others have no outputs
    end case;
end process;

mv_head <= mv_head_sig;
rm_tail <= rm_tail_sig;
put_head <= put_head_sig;
put_fruit <= put_fruit_sig;

end behavioral;
