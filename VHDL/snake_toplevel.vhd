----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/24/2025
-- Name: snake_toplevel
-- Target: Basys 3
-- Description: top level for the full game
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity snake_toplevel is
    port ( clk_ext : in std_logic;
           up_button : in std_logic;
           down_button : in std_logic;
           right_button : in std_logic;
           left_button : in std_logic;
           pause_switch : in std_logic;
           reset_switch : in std_logic;
           vga_hsync : out std_logic;
           vga_vsync : out std_logic;
           vga_red : out std_logic_vector(3 downto 0);
           vga_green : out std_logic_vector(3 downto 0);
           vga_blue : out std_logic_vector(3 downto 0));
end snake_toplevel;

architecture toplevel of snake_toplevel is

-- VGA Controller components

component vga_sync is
    port ( pixel_clk : in std_logic;
           clk : in std_logic;
           pixel_x : out std_logic_vector(9 downto 0);
           pixel_y : out std_logic_vector(9 downto 0);
           video_on : out std_logic;
           hsync : out std_logic;
           vsync : out std_logic);
end component;

component pixel_generation is
    port ( pixel_x : in std_logic_vector(9 downto 0);
           pixel_y : in std_logic_vector(9 downto 0);
           video_on : in std_logic;
           grid : in std_logic_vector(1407 downto 0); -- 16*11*8 bits
           red : out std_logic_vector(3 downto 0);
           green : out std_logic_vector(3 downto 0);
           blue : out std_logic_vector(3 downto 0));
end component;

-- Grid System components

component snake_datapath is
    port ( clk : in std_logic;
           update : in std_logic;
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
		   finished : out std_logic );
end component;

component dp_helper_fsm is
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
end component;

component randomizer_lfsr is
    port ( clk : in std_logic;
           reset : in std_logic;
           rand : out std_logic_vector(7 downto 0) );
end component;

-- Direction FSM components

component direction_fsm is
    port ( 
           clk : in std_logic;
           update : in std_logic;
           input : in std_logic_vector(1 downto 0);
           pause : in std_logic;
           reset : in std_logic;
           direction : out std_logic_vector(1 downto 0) );
end component;

component button_interface is
    port( clk_port            : in  std_logic;
          button_port         : in  std_logic;
          button_db_port      : out std_logic;
          button_mp_port      : out std_logic);
end component;

-- Game State FSM component

component game_state_fsm is
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

-- VGA Controller signals

signal pixel_clk_sig : std_logic := '0'; -- 25 MHz
signal pixel_clk_counter : unsigned(1 downto 0) := "00"; -- 1 in 4

signal pixel_x_sig : std_logic_vector(9 downto 0) := (others => '0');
signal pixel_y_sig : std_logic_vector(9 downto 0) := (others => '0');
signal video_on_sig : std_logic := '0';
signal hsync_sig : std_logic := '0';
signal vsync_sig : std_logic := '0';

signal red_sig : std_logic_vector(3 downto 0) := (others => '0'); 
signal green_sig : std_logic_vector(3 downto 0) := (others => '0'); 
signal blue_sig : std_logic_vector(3 downto 0) := (others => '0'); 

signal red_reg   : std_logic_vector(3 downto 0) := (others => '0');
signal green_reg : std_logic_vector(3 downto 0) := (others => '0');
signal blue_reg  : std_logic_vector(3 downto 0) := (others => '0');

-- Grid System signals

signal grid_sig : std_logic_vector(1407 downto 0) := (others => '0'); -- 16*11*8 bits

signal mv_head_sig : std_logic := '0';
signal rm_tail_sig : std_logic := '0';
signal put_head_sig : std_logic := '0';
signal put_fruit_sig : std_logic := '0';
signal grow_sig : std_logic := '0';
signal full_sig : std_logic := '0';
signal crash_sig : std_logic := '0';
signal finished_sig : std_logic := '0';

signal rand_sig : std_logic_vector(7 downto 0) := (others => '0');

-- Direction FSM signals

signal update_sig : std_logic := '0';

signal update_counter : unsigned(25 downto 0) := (others => '0'); -- 1 in 50e6
constant update_counter_tc : integer := 50e6;

signal input_sig : std_logic_vector(1 downto 0) := "10";
signal direction_sig : std_logic_vector(1 downto 0) := "10";

signal up_db_sig : std_logic := '0';
signal down_db_sig : std_logic := '0';
signal right_db_sig : std_logic := '0';
signal left_db_sig : std_logic := '0';

signal pause_db_sig : std_logic := '0';
signal reset_db_sig : std_logic := '0';

-- Game State FSM signals
signal pressed_sig : std_logic := '0';
signal reset_sync_sig : std_logic := '0';

signal move_sig : std_logic := '0';

begin

-- VGA Controller instances

sync: vga_sync
    port map ( pixel_clk => pixel_clk_sig,
               clk => clk_ext,
               pixel_x => pixel_x_sig,
               pixel_y => pixel_y_sig,
               video_on => video_on_sig,
               hsync => hsync_sig,
               vsync => vsync_sig);

pixelgen: pixel_generation
    port map ( pixel_x => pixel_x_sig,
               pixel_y => pixel_y_sig,
               video_on => video_on_sig,
               grid => grid_sig,
               red => red_sig,
               green => green_sig,
               blue => blue_sig);

-- Grid System instances

datapath: snake_datapath
    port map ( clk => clk_ext,
               update => update_sig,
               dir => direction_sig,
               rand => rand_sig,
               mv_head => mv_head_sig,
               rm_tail => rm_tail_sig,
               put_head => put_head_sig,
               put_fruit => put_fruit_sig,
               reset => reset_sync_sig,
               grid => grid_sig,
               grow => grow_sig,
               full => full_sig,
               crash => crash_sig,
               finished => finished_sig );

helperfsm: dp_helper_fsm
    port map ( clk => clk_ext,
               move => move_sig,
               full => full_sig,
               crash => crash_sig,
               grow => grow_sig,
               finished => finished_sig,
               reset => reset_sync_sig,
               mv_head => mv_head_sig,
               rm_tail => rm_tail_sig,
               put_head => put_head_sig,
               put_fruit => put_fruit_sig );

randomizer: randomizer_lfsr
    port map ( clk => clk_ext,
               reset => reset_sync_sig,
               rand => rand_sig );

-- Direction FSM instances

dirfsm: direction_fsm
    port map ( clk => clk_ext,
               update => update_sig,
               input => input_sig,
               pause => pause_db_sig,
               reset => reset_db_sig,
               direction => direction_sig );

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

-- Game State FSM instance

gamefsm: game_state_fsm
    port map ( clk => clk_ext,
               update => update_sig,
               pressed => pressed_sig,
               full => full_sig,
               crash => crash_sig,
               pause_db => pause_db_sig,
               reset_db => reset_db_sig,
               reset_sync => reset_sync_sig,
               move => move_sig,
               done => open );

-- VGA Controller processes

pixel_clkgen : process(clk_ext) -- generate pulse
begin
    if rising_edge(clk_ext) then
        if (pixel_clk_counter + 1) = "11" then
            pixel_clk_sig <= '1';
        else
            pixel_clk_sig <= '0';
        end if;
        
        pixel_clk_counter <= pixel_clk_counter + 1;
    end if;
end process;

sync_colors : process(clk_ext)
begin
  if rising_edge(clk_ext) then
    if pixel_clk_sig = '1' then
      red_reg <= red_sig;
      green_reg <= green_sig;
      blue_reg <= blue_sig;
    end if;
  end if;
end process;

vga_hsync <= hsync_sig;
vga_vsync <= vsync_sig;

vga_red <= red_reg;
vga_green <= green_reg;
vga_blue <= blue_reg;

-- Direction FSM processes

update_pulsegen_proc : process(clk_ext) -- generate pulse
begin
    if rising_edge(clk_ext) then
        if (update_counter + 1) = to_unsigned(update_counter_tc - 1, 26) then
            update_sig <= '1';
        else
            update_sig <= '0';
        end if;
        
        if update_counter = to_unsigned(update_counter_tc - 1, 26) then
            update_counter <= (others => '0');
        else
            update_counter <= update_counter + 1;
        end if;
    end if;
end process;

deode_input : process(clk_ext)
begin
    if rising_edge(clk_ext) then
        if reset_sync_sig = '1' then
            input_sig <= "10"; -- initial direction
            pressed_sig <= '0';
        else
            if up_db_sig = '1' then
                input_sig <= "00";
                pressed_sig <= '1';
            elsif down_db_sig = '1' then
                input_sig <= "01";
                pressed_sig <= '1';
            elsif right_db_sig = '1' then
                input_sig <= "10";
                pressed_sig <= '1';
            elsif left_db_sig = '1' then
                input_sig <= "11";
                pressed_sig <= '1';
            end if;
        end if;
    end if;
end process;

end toplevel;
