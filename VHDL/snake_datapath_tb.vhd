----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd 
-- Date: 8/26/2025
-- Name: snake_datapath_tb
-- Target: Basys 3
-- Description: testbench for snake datapath
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity snake_datapath_tb is
end snake_datapath_tb;

architecture testbench of snake_datapath_tb is

component snake_datapath is
    port ( clk : in std_logic;
           dir : in std_logic_vector(1 downto 0);
		   rand : in std_logic_vector(7 downto 0);
		   mv_head : in std_logic;
		   rm_tail : in std_logic;
		   put_head : in std_logic;
		   put_fruit : in std_logic;
		   reset : in std_logic;
		   grid : out std_logic_vector (1407 downto 0);
		   grow : out std_logic;
		   full : out std_logic;
		   crash : out std_logic;
		   eaten : out std_logic );
end component;

signal clk_sig : std_logic := '1';
constant clk_period : time := 10ns; -- 100 MHz

signal dir_sig : std_logic_vector(1 downto 0) := (others => '0');
signal rand_sig : std_logic_vector(7 downto 0) := (others => '0');

signal mv_head_sig : std_logic := '0';
signal rm_tail_sig : std_logic := '0';
signal put_head_sig : std_logic := '0';
signal put_fruit_sig : std_logic := '0';

signal reset_sig : std_logic := '0';
signal grid_sig : std_logic_vector(1407 downto 0) := (others => '0');

signal grow_sig : std_logic := '0';
signal full_sig : std_logic := '0';
signal crash_sig : std_logic := '0';
signal eaten_sig : std_logic := '0';

begin

uut: snake_datapath
    port map (
        clk => clk_sig,
        dir => dir_sig,
        rand => rand_sig,
        mv_head => mv_head_sig,
        rm_tail => rm_tail_sig,
        put_head => put_head_sig,
        put_fruit => put_fruit_sig,
        reset => reset_sig,
        grid => grid_sig,
        grow => grow_sig,
        full => full_sig,
        crash => crash_sig,
        eaten => eaten_sig
    );

clkgen_proc : process
begin
    clk_sig <= not(clk_sig);
    wait for clk_period / 2;
end process;

stim_proc : process
begin
    dir_sig <= "10"; -- right

    -- test remove tail
    rm_tail_sig <= '1';
    wait for clk_period;
    rm_tail_sig <= '0';
    wait for clk_period; -- grid should be updated

    -- test move and place head
    mv_head_sig <= '1';
    wait for clk_period;
    mv_head_sig <= '0';
    wait for clk_period;
    put_head_sig <= '1';
    wait for clk_period;
    put_head_sig <= '0';
    wait for clk_period; -- grid should be updated
    
    -- test eat fruit and crash
    for i in 1 to 11 loop
        mv_head_sig <= '1';
        wait for clk_period;
        mv_head_sig <= '0';
        wait for clk_period;
        put_head_sig <= '1';
        wait for clk_period;
        put_head_sig <= '0';
        wait for clk_period;
    end loop; -- expect grow and eaten, then crash
    
    -- test reset
    reset_sig <= '1';
    wait for clk_period;
    reset_sig <= '0';
    wait for clk_period; -- expect all reset
    
    -- test place fruit
    put_fruit_sig <= '1';
    wait for clk_period;
    put_fruit_sig <= '0';
    wait for clk_period; -- expect grid updated
    
    wait;
end process;

end testbench;
