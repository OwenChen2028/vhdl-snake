----------------------------------------------------------------------------------
-- Authors: Owen Chen and Mary Haferd
-- Date: 8/17/2025
-- Name: pixelgen_tb
-- Target: Basys 3
-- Description: testbench for pixel generation
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pixelgen_tb is
end pixelgen_tb;

architecture testbench of pixelgen_tb is

component pixel_generation is
    port ( pixel_x : in std_logic_vector(9 downto 0);
           pixel_y : in std_logic_vector(9 downto 0);
           video_on : in std_logic;
           grid : in std_logic_vector(1407 downto 0); -- 16*11*8 bits
           red : out std_logic_vector(3 downto 0);
           green : out std_logic_vector(3 downto 0);
           blue : out std_logic_vector(3 downto 0));
end component;

signal pixel_x_sig : std_logic_vector(9 downto 0) := (others => '0');
signal pixel_y_sig : std_logic_vector(9 downto 0) := (others => '0');
signal video_on_sig : std_logic := '0';

signal grid_sig : std_logic_vector(1407 downto 0) := (others => '0');
signal red_sig : std_logic_vector(3 downto 0) := (others => '0');
signal green_sig : std_logic_vector(3 downto 0) := (others => '0');
signal blue_sig : std_logic_vector(3 downto 0) := (others => '0');

begin

uut: pixel_generation
    port map ( pixel_x => pixel_x_sig,
               pixel_y => pixel_y_sig,
               video_on => video_on_sig,
               grid => grid_sig,
               red => red_sig,
               green => green_sig,
               blue => blue_sig );
               
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

stim_proc : process
begin
    -- test video off
    video_on_sig <= '0';
    
    pixel_x_sig <= std_logic_vector(to_unsigned(606, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(73, 10));
    wait for 10 ns; -- expect black
    
    pixel_x_sig <= std_logic_vector(to_unsigned(61, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(35, 10));
    wait for 10 ns; -- expect black
    
    pixel_x_sig <= std_logic_vector(to_unsigned(447, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(302, 10));
    wait for 10 ns; -- expect black
    
    pixel_x_sig <= std_logic_vector(to_unsigned(187, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(165, 10));
    wait for 10 ns; -- expect black
    
    pixel_x_sig <= std_logic_vector(to_unsigned(303, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(443, 10));
    wait for 10 ns; -- expect black

    video_on_sig <= '1';
    
    -- test outside grid
    pixel_x_sig <= std_logic_vector(to_unsigned(24, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(236, 10));
    wait for 10 ns; -- expect black at left
    
    pixel_x_sig <= std_logic_vector(to_unsigned(536, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(16, 10));
    wait for 10 ns; -- expect black at top
    
    pixel_x_sig <= std_logic_vector(to_unsigned(627, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(84, 10));
    wait for 10 ns; -- expect black at right
    
    pixel_x_sig <= std_logic_vector(to_unsigned(378, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(465, 10));
    wait for 10 ns; -- expect black at bottom
    
    -- test on grid border
    pixel_x_sig <= std_logic_vector(to_unsigned(256, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(36, 10));
    wait for 10 ns; -- expect blue at top
    
    pixel_x_sig <= std_logic_vector(to_unsigned(347, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(423, 10));
    wait for 10 ns; -- expect blue at bottom
    
    pixel_x_sig <= std_logic_vector(to_unsigned(61, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(182, 10));
    wait for 10 ns; -- expect blue at left
    
    pixel_x_sig <= std_logic_vector(to_unsigned(598, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(309, 10));
    wait for 10 ns; -- expect blue at right
    
    -- test black squares in grid
    pixel_x_sig <= std_logic_vector(to_unsigned(79, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(66, 10));
    wait for 10 ns; -- expect black
    
    pixel_x_sig <= std_logic_vector(to_unsigned(284, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(162, 10));
    wait for 10 ns; -- expect black
    
    pixel_x_sig <= std_logic_vector(to_unsigned(472, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(367, 10));
    wait for 10 ns; -- expect black
    
    -- test red squares in grid
    pixel_x_sig <= std_logic_vector(to_unsigned(75, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(386, 10));
    wait for 10 ns; -- expect red
    
    pixel_x_sig <= std_logic_vector(to_unsigned(406, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(178, 10));
    wait for 10 ns; -- expect red
    
    pixel_x_sig <= std_logic_vector(to_unsigned(354, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(406, 10));
    wait for 10 ns; -- expect red
    
    -- test green squares in grid
    pixel_x_sig <= std_logic_vector(to_unsigned(246, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(185, 10));
    wait for 10 ns; -- expect green
    
    pixel_x_sig <= std_logic_vector(to_unsigned(412, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(396, 10));
    wait for 10 ns; -- expect green
    
    pixel_x_sig <= std_logic_vector(to_unsigned(544, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(159, 10));
    wait for 10 ns; -- expect green
    
    -- reset
    video_on_sig <= '0';
    pixel_x_sig <= std_logic_vector(to_unsigned(0, 10));
    pixel_y_sig <= std_logic_vector(to_unsigned(0, 10));
    wait;
end process;

end testbench;
