----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/17/2025
-- Name: dirfsm_toplevel
-- Target: Basys 3
-- Description: connects direction FSM to raw input
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dirfsm_toplevel is
    port ( clk_ext : in std_logic;
           up_button : in std_logic;
           down_button : in std_logic;
           right_button : in std_logic;
           left_button : in std_logic;
           direction : out std_logic_vector(1 downto 0);
           update_out : out std_logic );
end dirfsm_toplevel;

architecture toplevel of dirfsm_toplevel is

component direction_fsm is
    port ( 
           clk : in std_logic;
           update : in std_logic;
           input : in std_logic_vector(1 downto 0);
           direction : out std_logic_vector(1 downto 0));
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

signal input_sig : std_logic_vector(1 downto 0) := "10";
signal direction_sig : std_logic_vector(1 downto 0) := "10";

signal up_db_sig : std_logic := '0';
signal down_db_sig : std_logic := '0';
signal right_db_sig : std_logic := '0';
signal left_db_sig : std_logic := '0';

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

dirfsm: direction_fsm
    port map ( clk => clk_ext,
               update => update_sig,
               input => input_sig,
               direction => direction_sig);

up_btn: button_interface
    port map ( clk_port => clk_ext,
               button_port => up_button,
               button_db_port => up_db_sig,
               button_mp_port => open );

down_btn: button_interface
    port map ( clk_port => clk_ext,
               button_port => down_button,
               button_db_port => down_db_sig,
               button_mp_port => open );

right_btn: button_interface
    port map ( clk_port => clk_ext,
               button_port => right_button,
               button_db_port => right_db_sig,
               button_mp_port => open );

left_btn: button_interface
    port map ( clk_port => clk_ext,
               button_port => left_button,
               button_db_port => left_db_sig,
               button_mp_port => open );

deode_input : process(clk_ext)
begin
    if rising_edge(clk_ext) then
        if up_db_sig = '1' then
            input_sig <= "00";
        elsif down_db_sig = '1' then
            input_sig <= "01";
        elsif right_db_sig = '1' then
            input_sig <= "10";
        elsif left_db_sig = '1' then
            input_sig <= "11";
        end if;
    end if;
end process;

direction <= direction_sig;
update_out <= update_sig;

end toplevel;
