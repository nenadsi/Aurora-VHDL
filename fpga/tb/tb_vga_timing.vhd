library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_vga_timing is end;
architecture tb of tb_vga_timing is
  signal clk, reset_n : std_logic := '0';
  signal hs, vs, de : std_logic;
  signal x : unsigned(9 downto 0);
  signal y : unsigned(9 downto 0);
begin
  clk <= not clk after 19.86 ns; -- approx 25.175 MHz
  process begin reset_n<='0'; wait for 100 ns; reset_n<='1'; wait; end process;

  dut: entity work.vga_timing port map(clk, reset_n, hs, vs, de, x, y);
end tb;
