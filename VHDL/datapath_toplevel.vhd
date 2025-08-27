----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/27/2025
-- Name: datapath_toplevel
-- Target: Basys 3
-- Description: hardware validation for datapath
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath_toplevel is
    port ( clk_ext : in std_logic;
           dir_in : in std_logic_vector(1 downto 0);
           rand_in : in std_logic_vector(7 downto 0);
           mv_head_button : in std_logic;
           rm_tail_button : in std_logic;
           put_head_button : in std_logic;
           put_fruit_button : in std_logic;
           reset_button : in std_logic;
           vga_hsync : out std_logic;
           vga_vsync : out std_logic;
           vga_red : out std_logic_vector(3 downto 0);
           vga_green : out std_logic_vector(3 downto 0);
           vga_blue : out std_logic_vector(3 downto 0));
end datapath_toplevel;

architecture toplevel of datapath_toplevel is

component vga_sync is
    port ( pixel_en : in std_logic;
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

component button_interface is
    port( clk_port            : in  std_logic;
          button_port         : in  std_logic;
          button_db_port      : out std_logic;
          button_mp_port      : out std_logic);
end component;

signal pixel_en_sig : std_logic := '0'; -- 25 MHz
signal pixel_en_counter : unsigned(1 downto 0) := "00"; -- 1 in 4

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

signal direction_sig : std_logic_vector (1 downto 0) := "00";
signal rand_sig : std_logic_vector(7 downto 0) := (others => '0');

signal reset_sig : std_logic := '0';

signal mv_head_sig : std_logic := '0';
signal rm_tail_sig : std_logic := '0';
signal put_head_sig : std_logic := '0';
signal put_fruit_sig : std_logic := '0';

signal grid_sig : std_logic_vector(1407 downto 0) := (others => '0'); -- 16*11*8 bits

signal grow_sig : std_logic := '0';
signal full_sig : std_logic := '0';
signal crash_sig : std_logic := '0';
signal eaten_sig : std_logic := '0';

begin

sync: vga_sync
    port map ( pixel_en => pixel_en_sig,
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

uut: snake_datapath
    port map ( clk => clk_ext,
               dir => direction_sig,
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
               eaten => eaten_sig );
               
mv_head_btn: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => mv_head_button,
        button_db_port => open,
        button_mp_port => mv_head_sig
    );

rm_tail_btn: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => rm_tail_button,
        button_db_port => open,
        button_mp_port => rm_tail_sig
    );

put_head_btn: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => put_head_button,
        button_db_port => open,
        button_mp_port => put_head_sig
    );

put_fruit_btn: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => put_fruit_button,
        button_db_port => open,
        button_mp_port => put_fruit_sig
    );

reset_btn: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => reset_button,
        button_db_port => reset_sig,
        button_mp_port => open
    );
    
dir_db0: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => dir_in(0),
        button_db_port => direction_sig(0),
        button_mp_port => open
    );

dir_db1: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => dir_in(1),
        button_db_port => direction_sig(1),
        button_mp_port => open
    );

rand_db0: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => rand_in(0),
        button_db_port => rand_sig(0),
        button_mp_port => open
    );

rand_db1: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => rand_in(1),
        button_db_port => rand_sig(1),
        button_mp_port => open
    );

rand_db2: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => rand_in(2),
        button_db_port => rand_sig(2),
        button_mp_port => open
    );

rand_db3: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => rand_in(3),
        button_db_port => rand_sig(3),
        button_mp_port => open
    );

rand_db4: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => rand_in(4),
        button_db_port => rand_sig(4),
        button_mp_port => open
    );

rand_db5: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => rand_in(5),
        button_db_port => rand_sig(5),
        button_mp_port => open
    );

rand_db6: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => rand_in(6),
        button_db_port => rand_sig(6),
        button_mp_port => open
    );

rand_db7: button_interface
    port map (
        clk_port       => clk_ext,
        button_port    => rand_in(7),
        button_db_port => rand_sig(7),
        button_mp_port => open
    );
               
pixel_engen : process(clk_ext) -- generate pulse
begin
    if rising_edge(clk_ext) then
        if (pixel_en_counter + 1) = "11" then
            pixel_en_sig <= '1';
        else
            pixel_en_sig <= '0';
        end if;
        
        pixel_en_counter <= pixel_en_counter + 1;
    end if;
end process;

sync_colors : process(clk_ext)
begin
  if rising_edge(clk_ext) then
    if pixel_en_sig = '1' then
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

end toplevel;
