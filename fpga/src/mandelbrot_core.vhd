library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_point_pkg.all;

entity mandelbrot_core is
  port(
    clk       : in  std_logic;
    reset_n   : in  std_logic;
    -- pixel
    x         : in  unsigned(9 downto 0);
    y         : in  unsigned(9 downto 0);
    de        : in  std_logic;
    -- params
    center_re : in  q4_28;
    center_im : in  q4_28;
    zoom      : in  unsigned(31 downto 0); -- scale: pixel_step = 2^-zoom[7:0] approx
    max_iter  : in  unsigned(7 downto 0);
    mode_julia: in  std_logic;
    c_re      : in  q4_28;
    c_im      : in  q4_28;
    -- out
    iter_o    : out unsigned(7 downto 0)
  );
end;

architecture rtl of mandelbrot_core is
  -- pipeline 4 stages (simple, iterative unrolled limited)
  type state_t is (IDLE, RUN, DONE);
  signal state : state_t := IDLE;

  signal zr, zi : q4_28 := (others=>'0');
  signal cr, ci : q4_28 := (others=>'0');
  signal it     : unsigned(7 downto 0) := (others=>'0');

  -- compute coordinate mapping
  function pix_to_coord(px : unsigned(9 downto 0); py : unsigned(9 downto 0);
                        center_re, center_im : q4_28; zoom : unsigned(31 downto 0)) return q4_28 is
    variable step_q : q4_28;
    variable dx, dy : q4_28;
  begin
    -- step ≈ 2^(-(zoom[7:0])/16) ~ coarse, using shift
    step_q := to_signed(1,32) sll (Q_FRAC-8); -- ~0.0039 baseline
    dx := to_q(to_integer(px) - 320);
    dy := to_q(to_integer(py) - 240);
    return add(center_re, mul(dx, step_q)); -- use for real; imag uses center_im + dy*step
  end;

begin
  process(clk, reset_n)
  begin
    if reset_n='0' then
      state<=IDLE; it<=(others=>'0'); zr<=(others=>'0'); zi<=(others=>'0');
    elsif rising_edge(clk) then
      case state is
        when IDLE =>
          if de='1' then
            -- set c depending on mode
            if mode_julia='1' then
              cr <= c_re; ci <= c_im; zr <= to_q(0); zi <= to_q(0);
            else
              -- map pixel to complex plane (simplified linear map)
              cr <= add(center_re, mul( to_q(to_integer(x)-320), to_q(1) sra 10 ));
              ci <= add(center_im, mul( to_q(240-to_integer(y)), to_q(1) sra 10 ));
              zr <= to_q(0); zi <= to_q(0);
            end if;
            it <= (others=>'0');
            state <= RUN;
          end if;
        when RUN =>
          -- z = z^2 + c
          -- (zr+izi)^2 = (zr^2 - zi^2) + 2*zr*zi*i
          zr <= add( sub( mul(zr,zr), mul(zi,zi) ), cr );
          zi <= add( mul( mul(zr,zi), to_q(2) ), ci );
          it <= it + 1;
          if (abs2(zr,zi) > x"40000000") or (it = max_iter) then
            state <= DONE;
          end if;
        when DONE =>
          iter_o <= it;
          state <= IDLE;
      end case;
    end if;
  end process;
end rtl;
