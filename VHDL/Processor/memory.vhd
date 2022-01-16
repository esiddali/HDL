
library ieee;
use ieee.std_logic_1164.all;
-- Avoid using ieee.std_logic_arith.all
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity Memory is
   generic  (
      DATA_WIDTH : integer := 16;
      ADDRESS_WIDTH : integer := 16;
      DEPTH : natural := 16;
      FILENAME : string := "zero.txt"
   );
   port (
      data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
      address : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
   );
end Memory;

architecture mem_arch of Memory is

type MemoryType is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);


impure function init_ram_hex return MemoryType is
  file text_file : text open read_mode is FILENAME;
  variable text_line : line;
  variable ram_content : MemoryType;
begin
  for i in 0 to DEPTH - 1 loop
    readline(text_file, text_line);
    hread(text_line, ram_content(i));
  end loop;
 
  return ram_content;
end function;


signal store : MemoryType := init_ram_hex;

begin
    -- Asynchronous assignments
    data_out <= store(to_integer(unsigned(address)));
end mem_arch;
