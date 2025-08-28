library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_point_pkg.all;

entity tb_mandelbrot is end;
architecture tb of tb_mandelbrot is
  signal clk, reset_n : std_logic := '0';
  signal x : unsigned(9 downto 0) := (others=>'0');
  signal y : unsigned(9 downto 0) := (others=>'0');
  signal de: std_logic := '0';
  signal iter_o : unsigned(7 downto 0);

  signal center_re, center_im, c_re, c_im : q4_28;
  signal zoom    : unsigned(31 downto 0);
  signal max_iter: unsigned(7 downto 0);
  signal mode_julia : std_logic;
begin
  clk <= not clk after 10 ns;
  process begin reset_n<='0'; wait for 50 ns; reset_n<='1'; wait; end process;

  dut: entity work.mandelbrot_core
    port map(clk, reset_n, x, y, de, center_re, center_im, zoom, max_iter, mode_julia, c_re, c_im, iter_o);

  stim: process
  begin
    center_re <= to_q(-1); center_im <= to_q(0);
    c_re <= to_q(-1); c_im<=to_q(0);
    zoom <= to_unsigned(16,32);
    max_iter <= to_unsigned(64,8);
    mode_julia <= '0';
    wait for 100 ns;
    de <= '1';
    x <= to_unsigned(320,10);
    y <= to_unsigned(240,10);
    wait for 10 us;
    wait;
  end process;
end tb;
