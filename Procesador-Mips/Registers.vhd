----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.06.2021 18:55:11
-- Design Name: 
-- Module Name: Registers - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.All;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Registers is
    Port ( Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Wr : in STD_LOGIC;
           Reg1_rd : in STD_LOGIC_VECTOR (4 downto 0);
           Reg2_rd : in STD_LOGIC_VECTOR (4 downto 0);
           Reg_wr : in STD_LOGIC_VECTOR (4 downto 0);
           Data_wr : in STD_LOGIC_VECTOR (31 downto 0);
           Data1_rd : out STD_LOGIC_VECTOR (31 downto 0);
           Data2_rd : out STD_LOGIC_VECTOR (31 downto 0));
end Registers;

architecture Behavioral of Registers is

TYPE T_REG is ARRAY(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
signal reg: T_REG;
    
begin

    process(Clk,Reset)
        begin   
            if (Reset = '1') then
                --Si la señal de reset es 1, se reinicia el contenido del registro
                reg <= (others => x"00000000");
            else
                if (Falling_Edge(Clk)) then
                    if( Wr = '1') then
                        -- Si nos encontramos en un flanco descendete del clock y la señal de write es 1, guardamos data_wr en el registro que nos idique reg_wr
                        reg(CONV_Integer(Reg_wr)) <= Data_wr;
                    end if;
                end if;
            end if;
        end process;
     --Data_rd va a tomar el valor del registro indicado, en caso de no tener un valor indicado va a tomar el valor de 00000000   
     Data1_rd <= x"00000000" when (Reg1_rd = x"00000")
     else   reg(CONV_Integer(Reg1_rd));
     Data2_rd <= x"00000000" when (Reg2_rd = x"00000")
     else   reg(CONV_Integer(Reg2_rd));
     

end Behavioral;
 