library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_sync_tb is
end vga_sync_tb;

architecture testbench of vga_sync_tb is

component vga_sync is
    port ( pixel_clk : in std_logic;
           clk : in std_logic;
           pixel_x : out std_logic_vector(9 downto 0);
           pixel_y : out std_logic_vector(9 downto 0);
           video_on : out std_logic;
           hsync : out std_logic;
           vsync : out std_logic);
end component;

signal clk_sig : std_logic := '0';
signal pixel_clk_sig : std_logic := '0';

constant clk_period : time := 10ns; -- 100 MHz
signal counter : unsigned(1 downto 0) := "00";

signal pixel_x_sig : std_logic_vector(9 downto 0) := (others => '0');
signal pixel_y_sig : std_logic_vector(9 downto 0) := (others => '0');
signal video_on_sig : std_logic := '0';
signal hsync_sig : std_logic := '0';
signal vsync_sig : std_logic := '0';

begin

uut: vga_sync
    port map ( pixel_clk => pixel_clk_sig,
               clk => clk_sig,
               pixel_x => pixel_x_sig,
               pixel_y => pixel_y_sig,
               video_on => video_on_sig,
               hsync => hsync_sig,
               vsync => vsync_sig);   

clkgen_proc : process
begin
    clk_sig <= not(clk_sig);
    wait for clk_period / 2;
end process;

-- generate pulse
pixel_clkgen_proc : process
begin
    if (counter + 1) = "11" then
        pixel_clk_sig <= '1';
    else
        pixel_clk_sig <= '0';
    end if;
    
    counter <= counter + 1;
    wait for clk_period / 2;
end process;

stim_proc : process
begin
    wait;
end process;

end testbench;
