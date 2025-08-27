----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/26/2025
-- Name: helper_fsm_toplevel
-- Target: Basys 3
-- Description: hardware validation for helper FSM
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity helper_fsm_toplevel is
    port ( clk_ext : in std_logic;
           update_switch : in std_logic; -- connected to input for testing
		   move_switch : in std_logic; -- connected to input for testing
		   full_switch : in std_logic; -- connected to input for testing
		   crash_switch : in std_logic; -- connected to input for testing
           grow_switch : in std_logic; -- connected to input for testing
		   eaten_switch : in std_logic; -- connected to input for testing
		   reset_switch : in std_logic; -- connected to input for testing
           mv_head_out : out std_logic;
		   rm_tail_out : out std_logic;
		   put_head_out : out std_logic;
		   put_fruit_out : out std_logic;
		   clk_out : out std_logic );
end helper_fsm_toplevel;

architecture toplevel of helper_fsm_toplevel is

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

component button_interface is
    port( clk_port            : in  std_logic;
          button_port         : in  std_logic;
          button_db_port      : out std_logic;
          button_mp_port      : out std_logic);
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
signal update_sig : std_logic := '0';

signal move_sig : std_logic := '0';

signal full_sig : std_logic := '0';
signal crash_sig : std_logic := '0';

signal grow_sig : std_logic := '0';
signal eaten_sig : std_logic := '0';

signal reset_sig : std_logic := '0';
		   
begin

clkgen: system_clock_generation
    port map ( input_clk_port => clk_ext,
               system_clk_port => clk_sig );
               
clk_out <= clk_sig;

uut: dp_helper_fsm
    port map ( clk => clk_sig,
               update => update_sig,
               move => move_sig,
               full => full_sig,
               crash => crash_sig,
               grow => grow_sig,
               eaten => eaten_sig,
               reset => reset_sig,
               mv_head => mv_head_out,
               rm_tail => rm_tail_out,
               put_head => put_head_out,
               put_fruit => put_fruit_out );

update_sw: button_interface
    port map ( clk_port => clk_sig,
               button_port => update_switch,
               button_db_port => update_sig,
               button_mp_port => open );

move_sw: button_interface
    port map ( clk_port => clk_sig,
               button_port => move_switch,
               button_db_port => move_sig,
               button_mp_port => open );

full_sw: button_interface
    port map ( clk_port => clk_sig,
               button_port => full_switch,
               button_db_port => full_sig,
               button_mp_port => open );

crash_sw: button_interface
    port map ( clk_port => clk_sig,
               button_port => crash_switch,
               button_db_port => crash_sig,
               button_mp_port => open );

grow_sw: button_interface
    port map ( clk_port => clk_sig,
               button_port => grow_switch,
               button_db_port => grow_sig,
               button_mp_port => open );

eaten_sw: button_interface
    port map ( clk_port => clk_sig,
               button_port => eaten_switch,
               button_db_port => eaten_sig,
               button_mp_port => open );

reset_sw: button_interface
    port map ( clk_port => clk_sig,
               button_port => reset_switch,
               button_db_port => reset_sig,
               button_mp_port => open );

end toplevel;
