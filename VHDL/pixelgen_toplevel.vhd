----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/16/2025
-- Name: pixelgen_toplevel
-- Target: Basys 3
-- Description: displays snake grid on VGA
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pixelgen_toplevel is
    port ( clk_ext : in std_logic;
           vga_hsync : out std_logic;
           vga_vsync : out std_logic;
           vga_red : out std_logic_vector(3 downto 0);
           vga_green : out std_logic_vector(3 downto 0);
           vga_blue : out std_logic_vector(3 downto 0));
end pixelgen_toplevel;

architecture toplevel of pixelgen_toplevel is

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

signal pixel_clk_sig : std_logic := '0'; -- 25 MHz
signal counter : unsigned(1 downto 0) := "00"; -- 1 in 4

signal pixel_x_sig : std_logic_vector(9 downto 0) := (others => '0');
signal pixel_y_sig : std_logic_vector(9 downto 0) := (others => '0');
signal video_on_sig : std_logic := '0';
signal hsync_sig : std_logic := '0';
signal vsync_sig : std_logic := '0';

signal grid_sig : std_logic_vector(1407 downto 0) := (others => '0'); -- 16*11*8 bits
signal red_sig : std_logic_vector(3 downto 0) := (others => '0'); 
signal green_sig : std_logic_vector(3 downto 0) := (others => '0'); 
signal blue_sig : std_logic_vector(3 downto 0) := (others => '0'); 

signal red_reg   : std_logic_vector(3 downto 0) := (others => '0');
signal green_reg : std_logic_vector(3 downto 0) := (others => '0');
signal blue_reg  : std_logic_vector(3 downto 0) := (others => '0');

begin

 -- generate pulse
pixel_clkgen : process(clk_ext)
begin
    if rising_edge(clk_ext) then
        if (counter + 1) = "11" then
            pixel_clk_sig <= '1';
        else
            pixel_clk_sig <= '0';
        end if;
        
        counter <= counter + 1;
    end if;
end process;

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
init_grid : process
begin
    for r in 0 to 10 loop
        for c in 0 to 15 loop
            if ((r + c) mod 3) = 0 then
                grid_sig(((r * 16 + c) * 8) + 7 downto (r * 16 + c) * 8) <= std_logic_vector(to_unsigned(0, 8));
            elsif (((r + c) mod 3) = 1) then
                grid_sig(((r * 16 + c) * 8) + 7 downto (r * 16 + c) * 8) <= std_logic_vector(to_unsigned(177, 8));
            else
                grid_sig(((r * 16 + c) * 8) + 7 downto (r * 16 + c) * 8) <= std_logic_vector(to_unsigned(23, 8));
            end if;
        end loop;
    end loop;
    wait; -- suspend process
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

end toplevel;
