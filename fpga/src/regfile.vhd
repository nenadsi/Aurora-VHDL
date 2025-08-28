library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
  port(
    clk    : in  std_logic;
    reset_n: in  std_logic;
    -- write port
    we     : in  std_logic;
    waddr  : in  unsigned(3 downto 0);
    wdata  : in  unsigned(31 downto 0);
    -- read port
    raddr  : in  unsigned(3 downto 0);
    rdata  : out unsigned(31 downto 0)
  );
end;
architecture rtl of regfile is
  type mem_t is array(0 to 15) of unsigned(31 downto 0);
  signal mem : mem_t := (others=>(others=>'0'));
begin
  process(clk, reset_n)
  begin
    if reset_n='0' then
      mem <= (others=>(others=>'0'));
      -- default view window
      mem(0) <= x"FFB00000"; -- center_re (q4.28) ~ -1.25
      mem(1) <= x"00000000"; -- center_im (0)
      mem(2) <= x"00000020"; -- zoom scale (small = zoom in)
      mem(3) <= to_unsigned(128,32); -- max_iter
      mem(4) <= (others=>'0'); -- mode 0: Mandelbrot, 1: Julia
      mem(5) <= x"00000000"; -- julia c_re
      mem(6) <= x"00000000"; -- julia c_im
    elsif rising_edge(clk) then
      if we='1' then
        mem(to_integer(waddr)) <= wdata;
      end if;
    end if;
  end process;
  rdata <= mem(to_integer(raddr));
end rtl;
