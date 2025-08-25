----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Hafed
-- Date: 8/24/2025
-- Name: snake_datapath
-- Target: Basys 3
-- Description: datapath for snake game
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity snake_datapath is
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
end snake_datapath;

architecture behavioral of snake_datapath is

type y_vals is array (10 downto 0) of unsigned(7 downto 0);
type x_vals is array (15 downto 0) of y_vals;

constant init_grid : x_vals := (
	2 => ( -- x = 2
        5 => "00000001", -- y = 5
        others => (others => '0')
    ),
    3 => ( -- x = 3
        5 => "00000010", -- y = 5
        others => (others => '0')
    ),
    others => (others => (others => '0'))
);
    
signal grid_2d : x_vals := init_grid;
signal grid_1d : std_logic_vector(1407 downto 0) := (others => '0');

constant init_head  : unsigned(8 downto 0) := to_unsigned(3, 5) & to_unsigned(5, 4);
signal head_pos : unsigned(8 downto 0) := init_head; -- first 5 bits are x, remaning 4 are y

signal head_x : unsigned(3 downto 0);
signal head_y : unsigned(3 downto 0);

constant init_length : unsigned(7 downto 0) := to_unsigned(2, 8);
signal length : unsigned(7 downto 0) := init_length;

constant init_fruit : unsigned(7 downto 0) := to_unsigned(12, 4) & to_unsigned(5, 4);
signal fruit_pos  : unsigned(7 downto 0) := init_fruit; -- 4 bits each for x and y

signal out_bounds : std_logic := '0';
signal self_collision : std_logic := '0';

signal grow_sig : std_logic := '0';
signal full_sig : std_logic := '0';

signal eaten_sig : std_logic := '0';

signal rand_x, rand_y : unsigned(3 downto 0);

begin

update_head : process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            head_pos <= init_head;
        elsif mv_head = '1' then
            case dir is
                when "00" => -- up
                    head_pos <= ((head_pos(8) & head_x)) & (head_y - 1); 
                when "01" => -- down
                    head_pos <= ((head_pos(8) & head_x)) & (head_y + 1);
                when "10" => -- right
                    head_pos <= ((head_pos(8) & head_x) + 1) & (head_y);
                when "11" => -- left
                    head_pos <= ((head_pos(8) & head_x) - 1) & (head_y);
                when others => null;
            end case;
        end if;
    end if;
end process;

check_bounds : process(head_pos, head_x, head_y)
begin
    if head_pos(8) & head_x >= to_unsigned(16, 5) then -- right wall or left wall (underflow)
        out_bounds <= '1';
    elsif head_y >= to_unsigned(11, 4) then -- bottom wall or top wall (underflow)
        out_bounds <= '1';
    else
        out_bounds <= '0';
    end if;
end process;

check_fruit : process(head_pos, fruit_pos)
begin
    if head_pos(7 downto 0) = fruit_pos then -- head on fruit
        grow_sig <= '1';
    else
        grow_sig <= '0';
    end if;
end process;

update_length : process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            length <= init_length;
        elsif grow_sig = '1' then
            length <= length + 1;
        end if;
    end if;
end process;

check_full : process(length)
begin
    if length = to_unsigned(176, 8) then
        full_sig <= '1';
    else
        full_sig <= '0';
    end if;
end process;

update_fruit : process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            fruit_pos <= init_fruit;
            eaten_sig <= '0';
        elsif grow_sig = '1' then
            fruit_pos <= to_unsigned(255, 8); -- move fruit out of grid
            eaten_sig <= '1';
        elsif put_fruit = '1' then -- place fruit
            if rand_y < to_unsigned(11, 4) then -- y in bounds, always true for x
                if grid_2d(to_integer(rand_x))(to_integer(rand_y)) = to_unsigned(0, 8) then -- empty square
                    fruit_pos <= unsigned(rand); -- update fruit pos
                    eaten_sig <= '0';
                end if;
            end if;
        end if;
    end if;
end process;

update_grid : process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            grid_2d <= init_grid;
        elsif rm_tail = '1' then -- remove tail
            for y in 0 to 10 loop
                for x in 0 to 15 loop
                    if grid_2d(x)(y) > to_unsigned(0, 8) then
                        grid_2d(x)(y) <= grid_2d(x)(y) - 1;
                    end if;
                end loop;
            end loop;
        elsif put_head = '1' then -- place head
            if grid_2d(to_integer(head_x))(to_integer(head_y)) = to_unsigned(0, 8) then
                grid_2d(to_integer(head_x))(to_integer(head_y)) <= length; -- place head on empty space
            end if;
        end if;
    end if;
end process;

check_collision: process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            self_collision  <= '0';
        elsif put_head = '1' and grid_2d(to_integer(head_x))(to_integer(head_y)) > to_unsigned(0, 8) then
            self_collision <= '1'; -- head would be placed onto snake body
        end if;
    end if;
end process;

flatten_grid : process(grid_2d, fruit_pos) -- flatten using shift as multiplication

variable index : integer; -- CITATION: referenced https://nandland.com/variable/

begin
	for y in 0 to 10 loop
		for x in 0 to 15 loop
			index := to_integer(
						shift_left(
							shift_left(to_unsigned(y, 11), 4) -- y * 16
							+ to_unsigned(x, 11),             -- + x
						3)                                    -- * 8
					);
			if (to_unsigned(x, 4) & to_unsigned(y, 4)) = fruit_pos then
                grid_1d(index + 7 downto index) <= std_logic_vector(to_unsigned(177, 8)); -- fruit id
            else
                grid_1d(index + 7 downto index) <= std_logic_vector(grid_2d(x)(y));
            end if;
		end loop;
	end loop;
end process;

head_x <= head_pos(7 downto 4);
head_y <= head_pos(3 downto 0);

rand_x <= unsigned(rand(7 downto 4));
rand_y <= unsigned(rand(3 downto 0));

grid <= grid_1d;

grow <= grow_sig;
full <= full_sig;

crash <= out_bounds or self_collision;

eaten <= eaten_sig;

end behavioral;
