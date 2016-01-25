----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:46:43 02/28/2013 
-- Design Name: 
-- Module Name:    top_level - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_level is
           Port ( led : out std_logic_vector(7 downto 0);
       strataflash_oe : out std_logic;
       strataflash_ce : out std_logic;
       strataflash_we : out std_logic;
               switch : in std_logic_vector(3 downto 0);
            btn_north : in std_logic;
             btn_east : in std_logic;
            btn_south : in std_logic;
             btn_west : in std_logic;
                lcd_d : inout std_logic_vector(7 downto 4);
               lcd_rs : out std_logic;
               lcd_rw : out std_logic;
                lcd_e : out std_logic;
                  clk : in std_logic);
end top_level;
--
-------------------------------------------------------------------------
--
-- Start of test architecture
--
architecture Behavioral of top_level is
  --
  -------------------------------------------------------------------------
  --
  -- declaration of KCPSM3
  --
  component kcpsm3
       Port ( address : out std_logic_vector(9 downto 0);
          instruction : in std_logic_vector(17 downto 0);
              port_id : out std_logic_vector(7 downto 0);
         write_strobe : out std_logic;
             out_port : out std_logic_vector(7 downto 0);
          read_strobe : out std_logic;
              in_port : in std_logic_vector(7 downto 0);
            interrupt : in std_logic;
        interrupt_ack : out std_logic;
                reset : in std_logic;
                  clk : in std_logic);
  end component;
  --
  -- declaration of program ROM
  --
  component hello
       Port ( address : in std_logic_vector(9 downto 0);
          instruction : out std_logic_vector(17 downto 0);
          --proc_reset : out std_logic; --JTAG Loader version
                  clk : in std_logic);
  end component;
  --
  -------------------------------------------------------------------------
  --
  -- Signals used to connect KCPSM3 to program ROM and I/O logic
  --
  signal address : std_logic_vector(9 downto 0);
  signal instruction : std_logic_vector(17 downto 0);
  signal port_id : std_logic_vector(7 downto 0);
  signal out_port : std_logic_vector(7 downto 0);
  signal in_port : std_logic_vector(7 downto 0);
  signal write_strobe : std_logic;
  signal read_strobe : std_logic;
  signal interrupt : std_logic :='0';
  signal interrupt_ack : std_logic;
  signal kcpsm3_reset : std_logic;
  --
  --
  -- Signals for LCD operation
  --
  -- Tri-state output requires internal signals
  -- 'lcd_drive' is used to differentiate between LCD and
  -- StrataFLASH communications which share the same data bits.
  --
  signal lcd_rw_control : std_logic;
  signal lcd_output_data : std_logic_vector(7 downto 4);
  signal lcd_drive : std_logic;
  --
  --
  ------------------------------------------------------------------------
  begin
  --
  ----------------------------------------------------------------------
  -- LCD interface
  ----------------------------------------------------------------------
  --
  -- The 4-bit data port is bidirectional.
  -- lcd_rw is '1' for read and '0' for write
  -- lcd_drive is like a master enable signal which prevents either the
  -- FPGA outputs or the LCD display driving the data lines.
  --
  --Control of read and write signal
  lcd_rw <= lcd_rw_control and lcd_drive;
  --use read/write control to enable output buffers.
  lcd_d <= lcd_output_data when (lcd_rw_control='0' and lcd_drive='1')
  else "ZZZZ";
  --
  ----------------------------------------------------------------------
  -- Disable StrataFLASH
  ----------------------------------------------------------------------
  --
  strataflash_oe <= '1';
  strataflash_ce <= '1';
  strataflash_we <= '1';
  --
  ----------------------------------------------------------------------
  -- KCPSM3 and the program memory
  -----------------------------------------------------------------------
  --
  processor: kcpsm3
     port map( address => address,
           instruction => instruction,
               port_id => port_id,
          write_strobe => write_strobe,
              out_port => out_port,
           read_strobe => read_strobe,
               in_port => in_port,
             interrupt => interrupt,
         interrupt_ack => interrupt_ack,
                 reset => kcpsm3_reset,
                   clk => clk);
  
  program_rom: hello
     port map( address => address,
           instruction => instruction,
           --proc_reset => kcpsm3_reset, --JTAG Loader version
                   clk => clk);
  --
  -----------------------------------------------------------------------
  -- KCPSM3 input ports
  -----------------------------------------------------------------------
  --
  -- The inputs connect via a pipelined multiplexer
  --
  input_ports: process(clk)
  begin
    if clk'event and clk='1' then
      case port_id(1 downto 0) is
        -- read simple toggle switches and buttons at address 00 hex
        when "00" => in_port <= btn_west & btn_north & btn_south & btn_east & switch;
   
	     -- read LCD data at address 02 hex
        when "10" => in_port <= lcd_d & "0000";
		  
        -- Don't care used for all other addresses to ensure minimum
        -- logic implementation
        when others => in_port <= "XXXXXXXX";
      end case;
    end if;
  end process input_ports;
  --
  -----------------------------------------------------------------------
  -- KCPSM3 output ports
  -----------------------------------------------------------------------
  --
  -- adding the output registers to the processor
  --
  output_ports: process(clk)
  begin
    if clk'event and clk='1' then
      if write_strobe='1' then
        -- Write to LEDs at address 80 hex.
        if port_id(7)='1' then
          led <= out_port;
        end if;
		  
        -- LCD data output and controls at address 40 hex.
        if port_id(6)='1' then
          lcd_output_data <= out_port(7 downto 4);
          lcd_drive <= out_port(3);
          lcd_rs <= out_port(2);
          lcd_rw_control <= out_port(1);
          lcd_e <= out_port(0);
        end if;
      end if;
    end if;
  end process output_ports;
 
end Behavioral;
