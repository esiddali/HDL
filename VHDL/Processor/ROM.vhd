
library ieee;
use ieee.std_logic_1164.all;
-- Avoid using ieee.std_logic_arith.all
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity ROM is
   generic  (
      DATA_WIDTH : integer := 16;
      ADDRESS_WIDTH : integer := 16;
      DEPTH : natural := 16;
      FILENAME : string := "zero.txt"
   );
   port (
      address : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
   );
end ROM;

architecture mem_arch of ROM is

type MemoryType is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

-- Initialize ROM from file (instructions.txt)
impure function init_rom_hex return MemoryType is
  file text_file : text open read_mode is FILENAME;
  variable text_line : line;
  variable rom_content : MemoryType;
begin
  for i in 0 to DEPTH - 1 loop
    readline(text_file, text_line);
    hread(text_line, rom_content(i));
  end loop; 
  return rom_content;
end function;

signal store : MemoryType := init_rom_hex;

begin
    -- Asynchronous assignments
    data_out <= store(to_integer(unsigned(address)));
end mem_arch;
