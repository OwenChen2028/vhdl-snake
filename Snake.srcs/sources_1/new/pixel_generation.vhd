----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/16/2025
-- Name: vga_toplevel
-- Target: Basys 3
-- Description: generates RGB based on (x, y) value in grid
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pixel_generation is
    port ( pixel_x : in std_logic_vector(9 downto 0);
           pixel_y : in std_logic_vector(9 downto 0);
           video_on : in std_logic;
           grid : in std_logic_vector(1407 downto 0); -- 16*11*8 bits
           red : out std_logic_vector(3 downto 0);
           green : out std_logic_vector(3 downto 0);
           blue : out std_logic_vector(3 downto 0));
end pixel_generation;

architecture behavioral of pixel_generation is

signal grid_x : unsigned(9 downto 0);
signal grid_y : unsigned(9 downto 0);

signal grid_pos : unsigned(10 downto 0);

signal selected : unsigned(7 downto 0);

constant RED_CONST : std_logic_vector(11 downto 0) := "111100000000";
constant GREEN_CONST : std_logic_vector(11 downto 0) := "000011110000";
constant BLUE_CONST : std_logic_vector(11 downto 0) := "000000001111";
constant BLACK_CONST : std_logic_vector(11 downto 0) := "000000000000";

signal color : std_logic_vector(11 downto 0);

begin

grid_scale : process(pixel_x, pixel_y)
begin
    grid_x <= "00000" & unsigned(pixel_x(9 downto 5));
    grid_y <= "00000" & unsigned(pixel_y(9 downto 5));
end process;

grid_index : process(grid_x, grid_y)
begin
    grid_pos <= resize(shift_left(grid_y - 2, 4), 11) + resize((grid_x - 2), 11);
end process;

grid_select : process(grid_x, grid_y, grid_pos, grid)
begin
    if (grid_x <= to_unsigned(0,10)) or (grid_x >= to_unsigned(19,10)) or
       (grid_y <= to_unsigned(0,10)) or (grid_y >= to_unsigned(14,10)) then
        selected <= to_unsigned(0, 8); -- background
    elsif (grid_x <= to_unsigned(1,10)) or (grid_x >= to_unsigned(18,10)) or
          (grid_y <= to_unsigned(1,10)) or (grid_y >= to_unsigned(13,10)) then
        selected <= to_unsigned(178, 8); -- border
    else
        selected <= unsigned( grid ( to_integer(shift_left(grid_pos, 3)) + 7
                              downto to_integer(shift_left(grid_pos, 3)) ));
    end if;
end process;

lookup_color : process(selected, video_on)
begin
    if video_on = '0' then
        color <= BLACK_CONST;
    else
        case selected is
        when to_unsigned(0, 8) =>
            color <= BLACK_CONST; -- background
        when to_unsigned(177, 8) =>
            color <= RED_CONST; -- fruit
        when to_unsigned(178, 8) =>
            color <= BLUE_CONST; -- border
        when others =>
            color <= GREEN_CONST; -- snake
        end case;
    end if;
end process;

red <= color(11 downto 8);
green <= color(7 downto 4);
blue <= color(3 downto 0);

end behavioral;
