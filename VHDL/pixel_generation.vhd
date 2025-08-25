----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/16/2025
-- Name: pixel_generation
-- Target: Basys 3
-- Description: generates RGB based on value in grid
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pixel_generation is
    port ( pixel_x : in std_logic_vector(9 downto 0); -- bits 0-4 are shifted out
           pixel_y : in std_logic_vector(9 downto 0); -- bits 0-4 are shifted out
           video_on : in std_logic;
           grid : in std_logic_vector(1407 downto 0); -- 16*11*8 bits
           red : out std_logic_vector(3 downto 0);
           green : out std_logic_vector(3 downto 0);
           blue : out std_logic_vector(3 downto 0));
end pixel_generation;

architecture behavioral of pixel_generation is

signal grid_x : unsigned(9 downto 0) := (others => '0');
signal grid_y : unsigned(9 downto 0) := (others => '0');

signal selected : unsigned(7 downto 0) := (others => '0');

constant BLACK_COLOR : std_logic_vector(11 downto 0) := (others => '0'); 
constant SNAKE_COLOR : std_logic_vector(11 downto 0) := "010001111110";
constant GRID_COLOR_A : std_logic_vector(11 downto 0) := "101111010101";
constant GRID_COLOR_B : std_logic_vector(11 downto 0) := "101011010101";
constant BORDER_COLOR : std_logic_vector(11 downto 0) := "010110000011";
constant FRUIT_COLOR : std_logic_vector(11 downto 0) := "110101010010";

signal color : std_logic_vector(11 downto 0) := (others => '0');

begin

scale_xy : process(pixel_x, pixel_y) -- convert from screen to grid space
begin
    grid_x <= "00000" & unsigned(pixel_x(9 downto 5));
    grid_y <= "00000" & unsigned(pixel_y(9 downto 5));
end process;

select_val : process(grid_x, grid_y, grid)

variable index : integer; -- CITATION: referenced https://nandland.com/variable/

begin
    if (grid_x <= to_unsigned(0,10)) or (grid_x >= to_unsigned(19,10)) or
       (grid_y <= to_unsigned(0,10)) or (grid_y >= to_unsigned(14,10)) then
        selected <= to_unsigned(179, 8); -- outside of grid, on background
    elsif (grid_x <= to_unsigned(1,10)) or (grid_x >= to_unsigned(18,10)) or
          (grid_y <= to_unsigned(1,10)) or (grid_y >= to_unsigned(13,10)) then
        selected <= to_unsigned(178, 8); -- on border surrounding grid
    else -- convert grid x and y to 1d positon, using shift as multiplication
		index := to_integer(
					shift_left(
						resize( shift_left(grid_y - 2, 4), 11 )   -- (grid_y - 2) * 16
						+ resize( (grid_x - 2), 11 ),             -- + (grid_x - 2)
					3)                                            -- * 8
				);
		selected <= unsigned(grid(index + 7 downto index));
    end if;
end process;

lookup_col : process(selected, video_on, grid_x, grid_y)
begin
    if video_on = '0' then
        color <= BLACK_COLOR; -- 0 value
    else
        case selected is
        when to_unsigned(0, 8) =>
            if grid_x(0) = '1' xor grid_y(0) = '1' then -- alternating colors
                color <= GRID_COLOR_A; -- grid color 1
            else
                color <= GRID_COLOR_B; -- grid color 2
            end if;
        when to_unsigned(177, 8) =>
            color <= FRUIT_COLOR; -- fruit color
        when to_unsigned(178, 8) =>
            color <= BORDER_COLOR; -- border color
        when to_unsigned(179, 8) =>
            color <= BLACK_COLOR; -- outside color
        when others =>
            color <= SNAKE_COLOR; -- snake color
        end case;
    end if;
end process;

red <= color(11 downto 8);
green <= color(7 downto 4);
blue <= color(3 downto 0);

end behavioral;
