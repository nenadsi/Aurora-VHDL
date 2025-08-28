library ieee;
use ieee.std_logic_1164.all;
entity pll_stub is
  port(
    clk_in  : in  std_logic;
    clk_out : out std_logic;
    locked  : out std_logic
  );
end;
architecture sim of pll_stub is
begin
  -- For simulation only: pass-through
  clk_out <= clk_in;
  locked  <= '1';
end sim;
