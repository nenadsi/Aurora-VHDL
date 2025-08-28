library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
  generic(
    CLK_FREQ : integer := 50000000;
    BAUD     : integer := 115200
  );
  port(
    clk      : in  std_logic;
    reset_n  : in  std_logic;
    data_i   : in  unsigned(7 downto 0);
    start_i  : in  std_logic;
    tx       : out std_logic;
    busy_o   : out std_logic
  );
end;
architecture rtl of uart_tx is
  constant DIV : integer := CLK_FREQ / BAUD;
  signal cnt   : integer range 0 to DIV-1 := 0;
  signal bitn  : integer range 0 to 9 := 0;
  signal sh    : unsigned(7 downto 0) := (others=>'0');
  signal txr   : std_logic := '1';
  signal busy  : std_logic := '0';
begin
  tx <= txr;
  busy_o <= busy;
  process(clk, reset_n)
  begin
    if reset_n='0' then
      cnt<=0; bitn<=0; busy<='0'; sh<=(others=>'0'); txr<='1';
    elsif rising_edge(clk) then
      if busy='0' then
        if start_i='1' then
          busy <= '1'; sh<=data_i; bitn<=0; cnt<=DIV-1; txr<='0'; -- start
        end if;
      else
        if cnt=0 then
          cnt <= DIV-1;
          if bitn<8 then
            txr <= std_logic(sh(0));
            sh <= '0' & sh(7 downto 1);
            bitn <= bitn + 1;
          elsif bitn=8 then
            txr <= '1'; -- stop
            bitn <= bitn + 1;
          else
            busy <= '0';
            txr <= '1';
          end if;
        else
          cnt <= cnt-1;
        end if;
      end if;
    end if;
  end process;
end rtl;
