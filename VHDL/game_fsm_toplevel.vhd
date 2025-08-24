----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/23/2025
-- Name: game_fsm_toplevel
-- Target: Basys 3
-- Description: hardware validation for game FSM
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_fsm_toplevel is
    port ( clk_ext : in std_logic;
		   pressed_button : in std_logic; -- connected to input for testing
		   full_switch : in std_logic; -- connected to input for testing
		   crash_switch : in std_logic; -- connected to input for testing
           pause_switch : in std_logic;
		   reset_switch : in std_logic;
           reset_out : out std_logic;
		   move_out : out std_logic;
		   done_out : out std_logic;
		   update_out : out std_logic );
end game_fsm_toplevel;

architecture toplevel of game_fsm_toplevel is

component game_fsm is
    port ( clk : in std_logic;
           update : in std_logic;
           pressed : in std_logic;
		   full : in std_logic;
		   crash : in std_logic;
           pause_db : in std_logic;
		   reset_db : in std_logic;
           reset_sync : out std_logic;
		   move : out std_logic;
		   done : out std_logic );
end component;

component button_interface is
    port( clk_port            : in  std_logic;
          button_port         : in  std_logic;
          button_db_port      : out std_logic;
          button_mp_port      : out std_logic);
end component;

signal update_sig : std_logic := '0';

signal counter : unsigned(25 downto 0) := (others => '0'); -- 1 in 50e6
constant counter_tc : integer := 50e6;

signal pressed_sig : std_logic := '0';

signal full_sig : std_logic := '0';
signal crash_sig : std_logic := '0';

signal pause_db_sig : std_logic := '0';
signal reset_db_sig : std_logic := '0';

begin

 -- generate pulse
update_pulsegen_proc : process(clk_ext)
begin
    if rising_edge(clk_ext) then
        if (counter + 1) = to_unsigned(counter_tc - 1, 26) then
            update_sig <= '1';
        else
            update_sig <= '0';
        end if;
        
        if counter = to_unsigned(counter_tc - 1, 26) then
            counter <= (others => '0');
        else
            counter <= counter + 1;
        end if;
    end if;
end process;

gamefsm: game_fsm
    port map ( clk => clk_ext,
               update => update_sig,
               pressed => pressed_sig,
               full => full_sig,
               crash => crash_sig,
               pause_db => pause_db_sig,
               reset_db => reset_db_sig,
               reset_sync => reset_out,
               move => move_out,
               done => done_out );

pressed_btn: button_interface
    port map ( clk_port => clk_ext,
               button_port => pressed_button,
               button_db_port => pressed_sig,
               button_mp_port => open );

full_sw: button_interface
    port map ( clk_port => clk_ext,
               button_port => full_switch,
               button_db_port => full_sig,
               button_mp_port => open );

crash_sw: button_interface
    port map ( clk_port => clk_ext,
               button_port => crash_switch,
               button_db_port => crash_sig,
               button_mp_port => open );

pause_sw: button_interface
    port map ( clk_port => clk_ext,
               button_port => pause_switch,
               button_db_port => pause_db_sig,
               button_mp_port => open );

reset_sw: button_interface
    port map ( clk_port => clk_ext,
               button_port => reset_switch,
               button_db_port => reset_db_sig,
               button_mp_port => open );

update_out <= update_sig;

end toplevel;
