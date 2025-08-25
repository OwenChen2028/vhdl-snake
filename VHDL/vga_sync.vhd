----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/16/2025
-- Name: vga_sync
-- Target: Basys 3
-- Description: synchronizer component for VGA
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_sync is
    port ( pixel_en : in std_logic;
           clk : in std_logic;
           pixel_x : out std_logic_vector(9 downto 0);
           pixel_y : out std_logic_vector(9 downto 0);
           video_on : out std_logic;
           hsync : out std_logic;
           vsync : out std_logic );
end vga_sync;

architecture behavioral of vga_sync is

signal x_sig : unsigned(9 downto 0) := (others => '0'); -- assign to pixel_x
signal y_sig : unsigned(9 downto 0) := (others => '0'); -- assign to pixel_y

constant x_tc : integer := 799; -- x_sig resets after x_tc
constant y_tc : integer := 524; -- y_sig resets after y_rc

signal h_sig : std_logic := '0'; -- assign to hsync
signal v_sig : std_logic := '0'; -- assign to vsync

constant h_bot : integer := 655; -- hsync is asserted after h_min
constant h_top : integer := 751; -- hsync is asserted until after h_max

constant v_bot : integer := 489; -- vsync is asserted after v_min
constant v_top : integer := 491; -- vsync is asserted until after v_max

signal on_sig : std_logic := '0'; -- assign to video_on

constant x_disp : integer := 640; -- under x_disp means on display
constant y_disp : integer := 480; -- under y_disp means on display

begin

-- increment x_sig
update_x : process(clk)
begin
    if rising_edge(clk) then
        if pixel_en = '1' then -- enable
            if x_sig = to_unsigned(x_tc, 10) then -- reset
                x_sig <= (others => '0');
            else
                x_sig <= x_sig + 1;
            end if;
        end if;
    end if;
end process;

-- set h_sig
update_h : process(x_sig)
begin
    h_sig <= '0';
    if x_sig > to_unsigned(h_bot, 10) and x_sig <= to_unsigned(h_top, 10) then
        h_sig <= '1';
    end if;
end process;

-- increment y_sig
update_y : process(clk)
begin
    if rising_edge(clk) then
        if pixel_en = '1' and x_sig = to_unsigned(x_tc, 10) then -- enable
            if y_sig = to_unsigned(y_tc, 10) then -- reset
                y_sig <= (others => '0');
            else
                y_sig <= y_sig + 1;
            end if;
        end if;
    end if;
end process;

-- set v_sig
update_v : process(y_sig)
begin
    v_sig <= '0';
    if y_sig > to_unsigned(v_bot, 10) and y_sig <= to_unsigned(v_top, 10) then
        v_sig <= '1';
    end if;
end process;

-- set on_sig
update_on : process(x_sig, y_sig)
begin
    on_sig <= '0';
    if x_sig < to_unsigned(x_disp, 10) and y_sig < to_unsigned(y_disp, 10) then
        on_sig <= '1';
    end if;
end process;

pixel_x <= std_logic_vector(x_sig);
pixel_y <= std_logic_vector(y_sig);

hsync <= not(h_sig);
vsync <= not(v_sig);

video_on <= on_sig;

end behavioral;
