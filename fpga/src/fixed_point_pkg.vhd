library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package fixed_point_pkg is
  -- Q4.28 fixed-point signed (total 32 bit) untuk fractal
  subtype q4_28 is signed(31 downto 0);
  constant Q_FRAC : integer := 28;

  function to_q(x : integer) return q4_28;
  function add(a,b : q4_28) return q4_28;
  function sub(a,b : q4_28) return q4_28;
  function mul(a,b : q4_28) return q4_28; -- (a*b)>>Q_FRAC
  function abs2(a,b : q4_28) return unsigned; -- a^2 + b^2 dalam skala Q
end package;

package body fixed_point_pkg is
  function to_q(x : integer) return q4_28 is
  begin
    return to_signed(x, 32) sll Q_FRAC;
  end;

  function add(a,b : q4_28) return q4_28 is
  begin
    return resize(a,32) + resize(b,32);
  end;

  function sub(a,b : q4_28) return q4_28 is
  begin
    return resize(a,32) - resize(b,32);
  end;

  function mul(a,b : q4_28) return q4_28 is
    variable p : signed(63 downto 0);
  begin
    p := resize(a,64) * resize(b,64);
    return signed( p(63 downto Q_FRAC) );
  end;

  function abs2(a,b : q4_28) return unsigned is
    variable aa, bb : signed(31 downto 0);
    variable paa, pbb : signed(63 downto 0);
  begin
    aa := mul(a,a);
    bb := mul(b,b);
    return unsigned(resize(aa,32)) + unsigned(resize(bb,32));
  end;
end package body;
