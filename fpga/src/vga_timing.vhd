library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_timing is
  port(
    clk_pix   : in  std_logic;
    reset_n   : in  std_logic;
    hsync     : out std_logic;
    vsync     : out std_logic;
    de        : out std_logic;
    x         : out unsigned(9 downto 0); -- 0..639
    y         : out unsigned(9 downto 0)  -- 0..479
  );
end;

architecture rtl of vga_timing is
  -- 640x480@60Hz timing (25.175MHz)
  constant H_VISIBLE : integer := 640;
  constant H_FP      : integer := 16;
  constant H_SYNC    : integer := 96;
  constant H_BP      : integer := 48;
  constant H_TOTAL   : integer := H_VISIBLE + H_FP + H_SYNC + H_BP;

  constant V_VISIBLE : integer := 480;
  constant V_FP      : integer := 10;
  constant V_SYNC    : integer := 2;
  constant V_BP      : integer := 33;
  constant V_TOTAL   : integer := V_VISIBLE + V_FP + V_SYNC + V_BP;

  signal hc : unsigned(10 downto 0) := (others=>'0');
  signal vc : unsigned(9 downto 0)  := (others=>'0');
begin
  process(clk_pix, reset_n)
  begin
    if reset_n='0' then
      hc <= (others=>'0'); vc <= (others=>'0');
    elsif rising_edge(clk_pix) then
      if hc = to_unsigned(H_TOTAL-1, hc'length) then
        hc <= (others=>'0');
        if vc = to_unsigned(V_TOTAL-1, vc'length) then
          vc <= (others=>'0');
        else
          vc <= vc + 1;
        end if;
      else
        hc <= hc + 1;
      end if;
    end if;
  end process;

  hsync <= '0' when (hc >= to_unsigned(H_VISIBLE+H_FP, hc'length) and
                     hc <  to_unsigned(H_VISIBLE+H_FP+H_SYNC, hc'length)) else '1';

  vsync <= '0' when (vc >= to_unsigned(V_VISIBLE+V_FP, vc'length) and
                     vc <  to_unsigned(V_VISIBLE+V_FP+V_SYNC, vc'length)) else '1';

  de <= '1' when (hc < to_unsigned(H_VISIBLE, hc'length) and
                  vc < to_unsigned(V_VISIBLE, vc'length)) else '0';

  x <= resize(hc, x'length);
  y <= resize(vc, y'length);
end rtl;
