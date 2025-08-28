library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
  generic(
    CLK_FREQ : integer := 50000000;
    BAUD     : integer := 115200
  );
  port(
    clk      : in  std_logic;
    reset_n  : in  std_logic;
    rx       : in  std_logic;
    data_o   : out unsigned(7 downto 0);
    valid_o  : out std_logic
  );
end;
architecture rtl of uart_rx is
  constant DIV : integer := CLK_FREQ / BAUD;
  signal cnt   : integer range 0 to DIV-1 := 0;
  signal bitn  : integer range 0 to 9 := 0;
  signal sh    : unsigned(7 downto 0) := (others=>'0');
  signal busy  : std_logic := '0';
  signal rx_sync : std_logic_vector(1 downto 0) := (others=>'1');
  signal rx_i : std_logic := '1';
begin
  -- 2FF sync
  process(clk) begin
    if rising_edge(clk) then
      rx_sync <= rx_sync(0) & rx;
      rx_i <= rx_sync(1);
    end if;
  end process;

  process(clk, reset_n)
  begin
    if reset_n='0' then
      cnt<=0; bitn<=0; busy<='0'; sh<=(others=>'0'); valid_o<='0';
    elsif rising_edge(clk) then
      valid_o <= '0';
      if busy='0' then
        if rx_i='0' then  -- start bit detect
          busy <= '1'; cnt <= DIV/2; bitn<=0;
        end if;
      else
        if cnt=0 then
          cnt <= DIV-1;
          if bitn=0 then
            -- sample start bit (ignore)
            bitn <= 1;
          elsif bitn<=8 then
            sh <= rx_i & sh(7 downto 1);
            bitn <= bitn + 1;
          elsif bitn=9 then
            -- stop bit
            busy <= '0';
            data_o <= sh;
            valid_o <= '1';
          end if;
        else
          cnt <= cnt-1;
        end if;
      end if;
    end if;
  end process;
end rtl;
