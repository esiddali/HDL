
library ieee;
use ieee.std_logic_1164.all;
-- Avoid using ieee.std_logic_arith.all
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Processor is 
   generic  (
      DATA_WIDTH : integer;
      ADDRESS_WIDTH : integer
   );
   port(
      program_address : out std_logic_vector (ADDRESS_WIDTH-1 downto 0);
      program_data : in std_logic_vector (DATA_WIDTH-1 downto 0);
      reset :in std_logic;
      clock :in std_logic
   );
end Processor;

architecture Behavioral of Processor is
   signal pc : std_logic_vector (ADDRESS_WIDTH-1 downto 0) := (others => '0');
   signal nothing : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
   signal destination : std_logic_vector (7-1 downto 0);
   signal source : std_logic_vector (DATA_WIDTH-1 downto 0);
   signal immediate_flag : std_logic;
   signal instruction : std_logic_vector (DATA_WIDTH-1 downto 0);
   signal a_reg : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
   signal b_reg : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
   signal sum : std_logic_vector (DATA_WIDTH-1 downto 0);

   component Memory
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
   end component;

begin
   program_memory : Memory
      generic map (
         DATA_WIDTH => DATA_WIDTH,
         ADDRESS_WIDTH => ADDRESS_WIDTH,
         DEPTH => 16
      )
      port map (
         data_in => nothing,
         address => pc,
         data_out => instruction
      );

   -- High bit is immediate flag
   immediate_flag <= instruction(DATA_WIDTH-1);
   -- Next seven bits are the destination register
   destination <= instruction(DATA_WIDTH-2 downto DATA_WIDTH-8);
   -- Low 16 bits are the source registor or immediate value if immediate_flag is set
   source <= x"00" & instruction(DATA_WIDTH-8-1 downto 0);
   sum <= a_reg + b_reg;
   process(clock, reset)
   begin
      if reset = '1' then
         a_reg <= (others => '0');
         b_reg <= (others => '0');
         pc <= (others => '0');
      else
         if (rising_edge(clock)) then
            pc <= pc + 1;
            if immediate_flag = '1' then
               if to_integer(unsigned(destination)) = 0 then
                  pc <= source;
               end if;
               if to_integer(unsigned(destination)) = 1 then
                  a_reg <= source;
               end if;
               if to_integer(unsigned(destination)) = 2 then
                  b_reg <= source;
               end if;
            else
               if to_integer(unsigned(source)) = 3 then
                  if to_integer(unsigned(destination)) = 0 then
                     pc <= sum;
                  end if;
                  if to_integer(unsigned(destination)) = 1 then
                     a_reg <= sum;
                  end if;
                  if to_integer(unsigned(destination)) = 2 then
                     b_reg <= sum;
                  end if;
               end if;
            end if;
         end if;
      end if;
   end process;
end Behavioral; 
