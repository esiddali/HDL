
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

   -- Registers
   constant NUM_REGISTERS : integer := 8;    
   type RegisterFile is array (0 to NUM_REGISTERS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
   signal registers : RegisterFile := (others => x"0000");
   constant PREFIX_INDEX : integer := 0;
   constant A_REG_INDEX : integer := 1;
   constant B_REG_INDEX : integer := 2;
   constant C_REG_INDEX : integer := 3;
   constant PC_INDEX : integer := NUM_REGISTERS-1;

   -- Arithmetic
   signal sum : std_logic_vector (DATA_WIDTH-1 downto 0);
   signal difference : std_logic_vector (DATA_WIDTH-1 downto 0);
   signal equal : std_logic;
   signal gt : std_logic;
   signal lt : std_logic;
   signal memory_write : std_logic;
   signal memory_data_in : std_logic_vector (DATA_WIDTH-1 downto 0);
   signal memory_data_out : std_logic_vector (DATA_WIDTH-1 downto 0);




   component ROM
      generic  (
         DATA_WIDTH : integer := 16;
         ADDRESS_WIDTH : integer := 16;
         DEPTH : natural := 256;
         FILENAME : string := "instructions.txt"

      );
      port (
         address : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
         data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
      );
   end component;



   component RAM
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
   end component;




   function boolean_to_logic(value : boolean) return std_logic is
   begin
      if value then
         return '1';
      else
         return '0';
      end if; 
   end function boolean_to_logic;

begin
   program_memory : ROM
      generic map (
         DATA_WIDTH => DATA_WIDTH,
         ADDRESS_WIDTH => ADDRESS_WIDTH,
         DEPTH => 256
      )
      port map (
         address => registers(PC_INDEX),
         data_out => instruction
      );

   data_memory : RAM
      generic map (
         DATA_WIDTH => DATA_WIDTH,
         ADDRESS_WIDTH => ADDRESS_WIDTH,
         DEPTH => 256
      )
      port map (
         address => registers(C_REG_INDEX),
         data_in => memory_data_in,
         data_out => memory_data_out,
         clock => clock,
         write => memory_write
      );


   -- High bit is immediate flag
   immediate_flag <= instruction(DATA_WIDTH-1);
   arithmetic_flag <= instruction(DATA_WIDTH-9);
   arithmetic_op <= instruction(DATA_WIDTH-10 downto 0);

   -- Next seven bits are the destination register
   destination <= instruction(DATA_WIDTH-2 downto DATA_WIDTH-8);
   -- Low 16 bits are the source registor or immediate value if immediate_flag is set
   source <= registers(PREFIX_INDEX)(DATA_WIDTH-8-1 downto 0) & instruction(DATA_WIDTH-8-1 downto 0);
   sum <= registers(A_REG_INDEX) + registers(B_REG_INDEX);
   difference <= registers(A_REG_INDEX) - registers(B_REG_INDEX);

   lt <= boolean_to_logic(to_integer(unsigned(registers(A_REG_INDEX))) < to_integer(unsigned(registers(B_REG_INDEX))));
   
   gt <= boolean_to_logic(to_integer(unsigned(registers(A_REG_INDEX))) > to_integer(unsigned(registers(B_REG_INDEX))));

   equal <= boolean_to_logic(to_integer(unsigned(registers(A_REG_INDEX))) = to_integer(unsigned(registers(B_REG_INDEX))));

   process(clock, reset)
   variable dest : integer;
   variable src : integer;
   begin
      if reset = '1' then
         registers(B_REG_INDEX) <= (others => '0');
         registers(A_REG_INDEX) <= (others => '0');
         registers(PC_INDEX) <= (others => '0');
      else
         if (rising_edge(clock)) then
            dest := to_integer(unsigned(destination));
            src := to_integer(unsigned(source));
            registers(PC_INDEX) <= registers(PC_INDEX) + 1;
            registers(PREFIX_INDEX) <= x"0000";

            if immediate_flag = '1' then
               if dest < NUM_REGISTERS then
                  registers(dest) <= source;
               end if;
               if dest = NUM_REGISTERS and equal = '1' then
                  registers(PC_INDEX) <= source;
               end if;
               if dest = NUM_REGISTERS+1 and equal = '0' then
                  registers(PC_INDEX) <= source;
               end if;
               if dest = NUM_REGISTERS+2 and lt = '1' then
                  registers(PC_INDEX) <= source;
               end if;
               if dest = NUM_REGISTERS+3 and gt = '1' then
                  registers(PC_INDEX) <= source;
               end if;
            else
               if arithmetic_flag = '1' then

                  -- Addition
                  if to_integer(unsigned(arithmetic_op)) = 1 then
                     registers(dest) <= sum;
                  end if;

                  -- Subtraction
                  if to_integer(unsigned(arithmetic_op)) = 2 then
                     registers(dest) <= difference;
                  end if;

                  -- Equal
                  if to_integer(unsigned(arithmetic_op)) = 3 then
                     registers(dest) <= (DATA_WIDTH-1 downto 1 => '0') & equal;
                  end if;

                  -- Greater than
                  if to_integer(unsigned(arithmetic_op)) = 4 then
                     registers(dest) <= (DATA_WIDTH-1 downto 1 => '0') & gt;
                  end if;

                  -- Less than
                  if to_integer(unsigned(arithmetic_op)) = 5 then
                     registers(dest) <= (DATA_WIDTH-1 downto 1 => '0') & lt;
                  end if;
                  
                  -- AND
                  if to_integer(unsigned(arithmetic_op)) = 6 then
                     registers(dest) <= registers(A_REG_INDEX) AND registers(B_REG_INDEX);
                  end if;

                  -- OR
                  if to_integer(unsigned(arithmetic_op)) = 7 then
                     registers(dest) <= registers(A_REG_INDEX) OR registers(B_REG_INDEX);
                  end if;

                  -- XOR
                  if to_integer(unsigned(arithmetic_op)) = 8 then
                     registers(dest) <= registers(A_REG_INDEX) XOR registers(B_REG_INDEX);
                  end if;

                  -- inc
                  if to_integer(unsigned(arithmetic_op)) = 9 then
                     registers(dest) <= registers(dest) + '1';
                  end if;

                  -- dec
                  if to_integer(unsigned(arithmetic_op)) = 10 then
                     registers(dest) <= registers(dest) - '1';
                  end if;
               else
                  registers(dest) <= registers(src);
               end if;

            end if;
         end if;
      end if;
   end process;
end Behavioral; 
