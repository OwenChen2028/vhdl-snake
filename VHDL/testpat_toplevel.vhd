----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/16/2025
-- Name: testpat_toplevel
-- Target: Basys 3
-- Description: displays test pattern on VGA
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity testpat_toplevel is
    port ( clk_ext : in std_logic;
           vga_hsync : out std_logic;
           vga_vsync : out std_logic;
           vga_red : out std_logic_vector(3 downto 0);
           vga_green : out std_logic_vector(3 downto 0);
           vga_blue : out std_logic_vector(3 downto 0));
end testpat_toplevel;

architecture toplevel of testpat_toplevel is

component vga_sync is
    port ( pixel_clk : in std_logic;
           clk : in std_logic;
           pixel_x : out std_logic_vector(9 downto 0);
           pixel_y : out std_logic_vector(9 downto 0);
           video_on : out std_logic;
           hsync : out std_logic;
           vsync : out std_logic);
end component;

component vga_test_pattern is
    port ( row : in std_logic_vector(9 downto 0);
           column : in std_logic_vector(9 downto 0);
           color : out std_logic_vector(11 downto 0));
end component;

signal pixel_clk_sig : std_logic := '0';
signal counter : unsigned(1 downto 0) := "00";

signal pixel_x_sig : std_logic_vector(9 downto 0) := (others => '0');
signal pixel_y_sig : std_logic_vector(9 downto 0) := (others => '0');
signal video_on_sig : std_logic := '0';
signal hsync_sig : std_logic := '0';
signal vsync_sig : std_logic := '0';

signal color_sig : std_logic_vector(11 downto 0) := (others => '0');

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
        
        counter <= counter + 1; -- overflows to 0 when tc
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

testpat: vga_test_pattern 
    port map ( row => pixel_y_sig,
               column => pixel_x_sig,
               color => color_sig);

vga_hsync <= hsync_sig;
vga_vsync <= vsync_sig;

vga_red <= color_sig(11 downto 8) when video_on_sig = '1' else (others => '0');
vga_green <= color_sig(7 downto 4) when video_on_sig = '1' else (others => '0');
vga_blue <= color_sig(3 downto 0) when video_on_sig = '1' else (others => '0');

end toplevel;
