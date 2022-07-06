----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.06.2021 20:04:51
-- Design Name: 
-- Module Name: ALU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.STD_LOGIC_SIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( a : in STD_LOGIC_VECTOR (31 downto 0);
           b : in STD_LOGIC_VECTOR (31 downto 0);
           Control : in STD_LOGIC_VECTOR (2 downto 0);
           Salida : out STD_LOGIC_VECTOR (31 downto 0);
           Zero : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is
signal Result:STD_LOGIC_VECTOR(31 downto 0);
begin
    process(Control,a,b)
    begin
        case(Control) is
            when "000" => Result <= a and b;
            when "001" => Result <= a or b;
            when "010" => Result <= a + b;
            when "110" => Result <= a - b;
            when "100" => Result <= b(15 downto 0) & x"0000";
            when "111" =>
                if (a < b) then
                    Result <= x"00000001";
                else
                    Result <= x"00000000";
                end if;
            when others => Result <= x"00000000";
        end case;
    end process;
    
    Salida <= Result;
    
    process (Result)
    begin
        if(Result = x"00000000") then
            Zero <= '1';
        else
            Zero <= '0';
        end if;
    end process;
end Behavioral;
