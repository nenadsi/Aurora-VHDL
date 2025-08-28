library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_point_pkg.all;

entity top_aurora is
  port(
    clk_in    : in  std_logic;      -- 50MHz/100MHz from board
    reset_n   : in  std_logic;
    -- VGA
    vga_hsync : out std_logic;
    vga_vsync : out std_logic;
    vga_r     : out unsigned(3 downto 0);
    vga_g     : out unsigned(3 downto 0);
    vga_b     : out unsigned(3 downto 0);
    -- UART
    uart_rx_i : in  std_logic;
    uart_tx_o : out std_logic
  );
end;

architecture rtl of top_aurora is
  signal clk_pix : std_logic;
  -- Timing
  signal de : std_logic;
  signal x  : unsigned(9 downto 0);
  signal y  : unsigned(9 downto 0);

  -- Regs
  signal center_re, center_im, c_re, c_im : q4_28;
  signal zoom    : unsigned(31 downto 0);
  signal max_iter: unsigned(7 downto 0);
  signal mode_julia : std_logic;

  -- UART wires
  signal rx_byte : unsigned(7 downto 0);
  signal rx_v    : std_logic;

  signal tx_byte : unsigned(7 downto 0);
  signal tx_start: std_logic := '0';
  signal tx_busy : std_logic;
begin
  -- Simple clock divide by 2 as placeholder for 25MHz (assumes 50MHz input)
  process(clk_in, reset_n)
  begin
    if reset_n='0' then
      clk_pix <= '0';
    elsif rising_edge(clk_in) then
      clk_pix <= not clk_pix;
    end if;
  end process;

  vga: entity work.vga_timing
    port map(clk_pix, reset_n, vga_hsync, vga_vsync, de, x, y);

  core: entity work.mandelbrot_core
    port map(
      clk=>clk_pix, reset_n=>reset_n,
      x=>x, y=>y, de=>de,
      center_re=>center_re, center_im=>center_im,
      zoom=>zoom, max_iter=>max_iter,
      mode_julia=>mode_julia, c_re=>c_re, c_im=>c_im,
      iter_o=>open
    );

  -- color mapping demo (use x,y for gradient when blank)
  col: entity work.color_mapper
    port map(iter=>std_logic_vector(x(9 downto 2))(7 downto 0), max_iter=>max_iter,
             r=>vga_r, g=>vga_g, b=>vga_b);

  -- Regs default
  center_re <= to_q(-1);
  center_im <= to_q(0);
  c_re <= to_q(-1); c_im <= to_q(0);
  zoom <= to_unsigned(16,32);
  max_iter <= to_unsigned(128,8);
  mode_julia <= '0';

  -- UART
  urx: entity work.uart_rx generic map(50000000,115200)
       port map(clk_in, reset_n, uart_rx_i, rx_byte, rx_v);
  utx: entity work.uart_tx generic map(50000000,115200)
       port map(clk_in, reset_n, tx_byte, tx_start, uart_tx_o, tx_busy);

  -- Example: echo bytes back
  process(clk_in, reset_n)
  begin
    if reset_n='0' then
      tx_start<='0'; tx_byte<=(others=>'0');
    elsif rising_edge(clk_in) then
      tx_start <= '0';
      if rx_v='1' and tx_busy='0' then
        tx_byte <= rx_byte;
        tx_start <= '1';
      end if;
    end if;
  end process;
end rtl;
