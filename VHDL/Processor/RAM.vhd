
library ieee;
use ieee.std_logic_1164.all;
-- Avoid using ieee.std_logic_arith.all
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity RAM is
   generic  (
      DATA_WIDTH : integer := 16;
      ADDRESS_WIDTH : integer := 16;
      DEPTH : natural := 16
   );
   port (
      address : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);      
      data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
      clock : in std_logic;
      write : in std_logic
   );
end RAM;

architecture mem_arch of RAM is

type MemoryType is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

signal store : MemoryType := (others => x"0000");


begin
    -- Asynchronous assignments
    data_out <= store(to_integer(unsigned(address)));
    process(clock)
    begin
        -- When write flag is true, store data in memory
        if (rising_edge(clock)) then
            if write = '1' then
                store(to_integer(unsigned(address))) <= data_in;
            end if;
        end if;
    end process;
end mem_arch;


