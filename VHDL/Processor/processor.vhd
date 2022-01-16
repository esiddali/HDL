
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
   -- Instructional
   signal instruction : std_logic_vector (DATA_WIDTH-1 downto 0);
   signal immediate_flag : std_logic;
   signal destination : std_logic_vector (7-1 downto 0);
   signal source : std_logic_vector (DATA_WIDTH-1 downto 0);
   signal arithmetic_flag : std_logic;
   signal arithmetic_op : std_logic_vector (DATA_WIDTH-10 downto 0);
   signal nothing : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');

   -- Registers
   signal prefix : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
   signal a_reg : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
   signal b_reg : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
   signal pc : std_logic_vector (ADDRESS_WIDTH-1 downto 0) := (others => '0');

   -- Arithmetic
   signal sum : std_logic_vector (DATA_WIDTH-1 downto 0);
   signal difference : std_logic_vector (DATA_WIDTH-1 downto 0);
   signal equal : std_logic;
   signal gt : std_logic;
   signal lt : std_logic;


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
   arithmetic_flag <= instruction(DATA_WIDTH-9);
   arithmetic_op <= instruction(DATA_WIDTH-10 downto 0);

   -- Next seven bits are the destination register
   destination <= instruction(DATA_WIDTH-2 downto DATA_WIDTH-8);
   -- Low 16 bits are the source registor or immediate value if immediate_flag is set
   source <= x"00" & instruction(DATA_WIDTH-8-1 downto 0);
   sum <= a_reg + b_reg;
   difference <= a_reg - b_reg;
   equal <= '0';

   process(a_reg, b_reg)
   begin
      lt <= '0';
      gt <= '0';
      equal <= '0';
      if to_integer(unsigned(a_reg)) = to_integer(unsigned(b_reg)) then
         equal <= '1';
      end if;
      if to_integer(unsigned(a_reg)) < to_integer(unsigned(b_reg)) then
         lt <= '1';
      end if;
      if to_integer(unsigned(a_reg)) > to_integer(unsigned(b_reg)) then
         gt <= '1';
      end if;
   end process;

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
                  prefix <= source;
               end if;
               if to_integer(unsigned(destination)) = 1 then
                  a_reg <= source;
               end if;
               if to_integer(unsigned(destination)) = 2 then
                  b_reg <= source;
               end if;
               if to_integer(unsigned(destination)) = 3 then
                  pc <= source;
               end if;
               if to_integer(unsigned(destination)) = 4 and equal = '1' then
                  pc <= source;
               end if;
               if to_integer(unsigned(destination)) = 5 and equal = '0' then
                  pc <= source;
               end if;
               if to_integer(unsigned(destination)) = 6 and lt = '1' then
                  pc <= source;
               end if;
               if to_integer(unsigned(destination)) = 7 and gt = '1' then
                  pc <= source;
               end if;
            else
               if arithmetic_flag = '1' then
                  -- Addition
                  if to_integer(unsigned(arithmetic_op)) = 1 then
                     if to_integer(unsigned(destination)) = 0 then
                        prefix <= sum;
                     end if;   
                     if to_integer(unsigned(destination)) = 1 then
                        a_reg <= sum;
                     end if;
                     if to_integer(unsigned(destination)) = 2 then
                        b_reg <= sum;
                     end if;
                     if to_integer(unsigned(destination)) = 3 then
                        pc <= sum;
                     end if;
                  end if;

                  -- Subtraction
                  if to_integer(unsigned(arithmetic_op)) = 2 then
                     if to_integer(unsigned(destination)) = 0 then
                        prefix <= difference;
                     end if;   
                     if to_integer(unsigned(destination)) = 1 then
                        a_reg <= difference;
                     end if;
                     if to_integer(unsigned(destination)) = 2 then
                        b_reg <= difference;
                     end if;
                     if to_integer(unsigned(destination)) = 3 then
                        pc <= difference;
                     end if;
                  end if;


               end if;
            end if;
         end if;
      end if;
   end process;
end Behavioral; 
