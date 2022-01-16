

library ieee;
use ieee.std_logic_1164.all;
-- Avoid using ieee.std_logic_arith.all
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ProcessorTest is
    generic  (
        DATA_WIDTH : integer := 16;
        ADDRESS_WIDTH : integer := 16
    );
end ProcessorTest;

architecture arch of ProcessorTest is
    component Processor
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
    end component;

    signal program_address : std_logic_vector (ADDRESS_WIDTH-1 downto 0);
    signal program_data : std_logic_vector (DATA_WIDTH-1 downto 0);
    signal reset : std_logic := '0';
    signal clock : std_logic := '0';
    signal runSimulation : std_logic := '1';
    constant CLOCKS : integer := 16;

begin

dut : Processor
generic map(
    DATA_WIDTH      => DATA_WIDTH,
    ADDRESS_WIDTH   => ADDRESS_WIDTH
)
port map(
    program_address => program_address,
    program_data => program_data,
    clock      => clock,
    reset => reset
);

process begin
    wait for 5 ns;
    clock <= not clock;
    if runSimulation = '0' then
        wait;
    end if;
end process;

stimulus : process
begin
    wait until rising_edge(clock);
    reset <= '1';
    wait until rising_edge(clock);
    reset <= '0';
    wait until rising_edge(clock);

    for i in 0 to CLOCKS loop
        wait until rising_edge(clock);
    end loop;



    runSimulation <= '0';
    wait;
end process stimulus;

end arch;