library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity color_mapper is
  port(
    iter      : in unsigned(7 downto 0);
    max_iter  : in unsigned(7 downto 0);
    r,g,b     : out unsigned(3 downto 0)
  );
end;
architecture rtl of color_mapper is
  signal t : unsigned(7 downto 0);
begin
  -- simple smooth palette
  t <= (iter * 255) / (max_iter + 1);
  r <= t(7 downto 4);
  g <= (t(5 downto 2));
  b <= (t(3 downto 0));
end rtl;
