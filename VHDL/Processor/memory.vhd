
library ieee;
use ieee.std_logic_1164.all;
-- Avoid using ieee.std_logic_arith.all
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Memory is
   generic  (
      DATA_WIDTH : integer := 16;
      ADDRESS_WIDTH : integer := 16;
      DEPTH : natural := 8192
   );
   port (
      data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
      address : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
   );
end Memory;

architecture mem_arch of Memory is

type MemoryType is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
signal store : MemoryType := (x"0000", x"810F", x"8207", x"0186", others => x"0000");

begin
    -- Asynchronous assignments
    data_out <= store(to_integer(unsigned(address)));
end mem_arch;
