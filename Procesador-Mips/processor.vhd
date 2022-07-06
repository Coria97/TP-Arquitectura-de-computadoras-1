library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity processor is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	I_Addr      : out std_logic_vector(31 downto 0);
	I_RdStb     : out std_logic;
	I_WrStb     : out std_logic;
	I_DataOut   : out std_logic_vector(31 downto 0);
	I_DataIn    : in  std_logic_vector(31 downto 0);
	-- Data memory
	D_Addr      : out std_logic_vector(31 downto 0);
	D_RdStb     : out std_logic;
	D_WrStb     : out std_logic;
	D_DataOut   : out std_logic_vector(31 downto 0);
	D_DataIn    : in  std_logic_vector(31 downto 0)
);
end processor;

architecture processor_arq of processor is 
    --Definicion de señales y declaracion de componentes 
    
    --IF 
    signal IF_PcNext : std_logic_vector(31 downto 0);
    signal IF_PCIn : std_logic_vector(31 downto 0);
    signal IF_PcOut : std_logic_vector (31 downto 0);
    
    --ID
    signal ID_MemToReg : std_logic;
    signal ID_RegWrite : std_logic;
    signal ID_Branch : std_logic;
    signal ID_MemWrite : std_logic;
    signal ID_MemRead : std_logic;
    signal ID_AluOp : std_logic_vector(2 downto 0);
    signal ID_RegDst : std_logic;
    signal ID_AluSrc : std_logic;
    signal ID_Instruction : std_logic_vector(31 downto 0);
    signal ID_PcNext: std_logic_vector(31 downto 0);
    signal ID_SignExt: std_logic_vector(31 downto 0);
    signal ID_RegRd1: std_logic_vector(31 downto 0);
    signal ID_RegRd2: std_logic_vector(31 downto 0);
  
    component Registers
        Port ( 
           Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Wr : in STD_LOGIC;
           Reg1_rd : in STD_LOGIC_VECTOR (4 downto 0);
           Reg2_rd : in STD_LOGIC_VECTOR (4 downto 0);
           Reg_wr : in STD_LOGIC_VECTOR (4 downto 0);
           Data_wr : in STD_LOGIC_VECTOR (31 downto 0);
           Data1_rd : out STD_LOGIC_VECTOR (31 downto 0);
           Data2_rd : out STD_LOGIC_VECTOR (31 downto 0));
        end component;
        
    --EXE
    signal EXE_Rt: std_logic_vector(4 downto 0);
    signal EXE_Rd: std_logic_vector(4 downto 0);
    signal EXE_MemToReg: std_logic;
    signal EXE_RegWrite: std_logic;
    signal EXE_Branch: std_logic;
    signal EXE_MemWrite: std_logic;
    signal EXE_MemRead: std_logic;
    signal EXE_RegDst : std_logic;
    signal EXE_AluSrc: std_logic;
    signal EXE_AluOp : std_logic_vector(2 downto 0);
    signal EXE_PcNext: std_logic_vector(31 downto 0);
    signal EXE_RegRd1: std_logic_vector(31 downto 0);
    signal EXE_RegRd2: std_logic_vector(31 downto 0);
    signal EXE_SignExt: std_logic_vector(31 downto 0);
    signal EXE_BranchAddress: std_logic_vector(31 downto 0);
    signal EXE_AluMux: std_logic_vector(31 downto 0); 
    signal EXE_RegDestMux: std_logic_vector(4 downto 0);
    signal EXE_Zero: std_logic;
    signal EXE_AluResult: std_logic_vector(31 downto 0);
    signal EXE_AluControl : std_logic_vector(2 downto 0);

   component ALU
    Port ( a : in STD_LOGIC_VECTOR (31 downto 0);
           b : in STD_LOGIC_VECTOR (31 downto 0);
           Control : in STD_LOGIC_VECTOR (2 downto 0);
           Salida : out STD_LOGIC_VECTOR (31 downto 0);
           Zero : out STD_LOGIC);
    end component;
    
    --MEM
    signal MEM_MemToReg: std_logic;
    signal MEM_RegWrite: std_logic;
    signal MEM_Branch : std_logic;
    signal MEM_BranchAddress: std_logic_vector(31 downto 0);
    signal MEM_PcSrc : std_logic; 
    signal MEM_Zero: std_logic;
    signal MEM_AluResult: std_logic_vector(31 downto 0);
    signal MEM_RegDest: std_logic_vector(4 downto 0);
    signal MEM_MemRead: std_logic;
    signal MEM_MemWrite: std_logic;
    signal MEM_RegRd2: std_logic_vector(31 downto 0);
    
    --WB
    signal WB_RegWrite: std_logic;
    signal WB_MemToReg: std_logic;
    signal WB_ReadData: std_logic_vector(31 downto 0);
    signal WB_Address: std_logic_vector(31 downto 0);
    signal WB_MuxResult: std_logic_vector (31 downto 0);
    signal WB_RegDest : std_logic_vector(4 downto 0);
begin

----------------------------------------
-- INSTRUCTION FETCHING
----------------------------------------

    -- PC REGISTER
    PC_reg: process(Clk, Reset) 	
    begin
        if Reset = '1' then
            IF_PcOut <=(others => '0');
        elsif rising_edge(Clk) then
            IF_PcOut <= IF_PcIn;
        end if;
    end process;
    
    -- Actualizo IF_PcNext en la direccion donde estoy parado +4.
    IF_PcNext <= IF_PcOut + 4;
    
    -- MUX DIRECCION
    MUX_dir: process(MEM_PcSrc, MEM_BranchAddress, IF_PcNext)
    begin
        if MEM_PcSrc = '0' then
        -- Significa que no salto por lo tanto avanza a la siguiente direccion.
            IF_PcIn <= IF_PcNext;
        else
        -- Significa que salto y le asignamos la direccion de salto.
            IF_PcIn <= MEM_BranchAddress;
        end if;
    end process;
    
    -- ASIGNACION DE INSTRUCCIONES
     I_Addr <= IF_PcOut; -- Guardo la direccion de lectura que me asigna el PC.
     I_RdStb <= '1'; -- Este campo siempre va a estar en lectura. 
     I_WrStb <= '0'; -- Este campo siempre va a estar en 0 por que no podemos escribir en nuestro conjunto de instrucciones.
     I_DataOut <= x"00000000"; -- siemrpe va a ser 0 porque es lo que escribiria pero como no se puede escribir lo declaramos en 0 asi no tendriamos un cable suelto.
    
----------------------------------------
-- PIPELINE IF/ID
----------------------------------------

    IFID_reg: process(Clk, Reset)
    begin
        if Reset = '1' then
        -- Reinicio de señales
            ID_Instruction <= (others => '0');
            ID_PcNext <= (others => '0');
        elsif rising_edge(Clk) then
        -- Se asigna el conjunto de instrucciones leido y la direccion de PC
            ID_Instruction <= I_DataIn;
            ID_PcNext <= IF_PcNext;
        end if;
    end process;   
    
----------------------------------------
-- Decodificacion de la instruccion
----------------------------------------

    --Unidad de control 
    Control : process(ID_Instruction(31 downto 26))
    begin
        case ID_Instruction(31 downto 26) is
            when "000000" => --Significa que es una instruccion de R-type 
              ID_RegDst <= '1';
              ID_AluSrc <= '0';
              ID_MemToReg <= '0';
              ID_RegWrite <= '1';
              ID_MemRead <= '0';
              ID_MemWrite <= '0';
              ID_Branch <= '0';
              ID_AluOp <= "111";
            when "100011" => --Significa que es una instruccion Load Word
              ID_RegDst <= '0';
              ID_AluSrc <= '1';
              ID_MemToReg <= '1';
              ID_RegWrite <= '1';
              ID_MemRead <= '1';
              ID_MemWrite <= '0';
              ID_Branch <= '0';
              ID_AluOp <= "000";
            when "101011" => --Significa que es una instruccion de Store Word 
              ID_RegDst <= '0';
              ID_AluSrc <= '1';
              ID_MemToReg <= '0';
              ID_RegWrite <= '0';
              ID_MemRead <= '0';
              ID_MemWrite <= '1';
              ID_Branch <= '0';
              ID_AluOp <= "000";
            when "001111" => --Significa que es una instruccion de LUI 
              ID_RegDst <= '0';
              ID_AluSrc <= '1';
              ID_MemToReg <= '1';
              ID_RegWrite <= '1';
              ID_MemRead <= '0';
              ID_MemWrite <= '0';
              ID_Branch <= '0';
              ID_AluOp <= "101";
            when "000100" => --Significa que es una instruccion de BEQ 
              ID_RegDst <= '0';
              ID_AluSrc <= '0';
              ID_MemToReg <= '0';
              ID_RegWrite <= '0';
              ID_MemRead <= '0';
              ID_MemWrite <= '0';
              ID_Branch <= '1';
              ID_AluOp <= "001";
            when "001000" => --Significa que es una instruccion de ADDI 
              ID_RegDst <= '0';
              ID_AluSrc <= '1';
              ID_MemToReg <= '0';
              ID_RegWrite <= '1';
              ID_MemRead <= '0';
              ID_MemWrite <= '0';
              ID_Branch <= '0';
              ID_AluOp <= "010";
            when "001101" => --Significa que es una instruccion de ORI 
              ID_RegDst <= '0';
              ID_AluSrc <= '1';
              ID_MemToReg <= '0';
              ID_RegWrite <= '1';
              ID_MemRead <= '0';
              ID_MemWrite <= '0';
              ID_Branch <= '0';
              ID_AluOp <= "011";
            when "001100" => --Significa que es una instruccion de ANDI
              ID_RegDst <= '0';
              ID_AluSrc <= '1';
              ID_MemToReg <= '0';
              ID_RegWrite <= '1';
              ID_MemRead <= '0';
              ID_MemWrite <= '0';
              ID_Branch <= '0';
              ID_AluOp <= "100";  
            when others => -- Others
              ID_RegDst <= '0';
              ID_AluSrc <= '0';
              ID_MemToReg <= '0';
              ID_RegWrite <= '0';
              ID_MemRead <= '0';
              ID_MemWrite <= '0';
              ID_Branch <= '0';
              ID_AluOp <= "000";
        end case;  
    end process;
    
    --Inicializacion del banco
    Banco : registers PORT MAP(
           Clk => Clk,
           Reset => Reset,
           Wr => WB_RegWrite,
           Reg1_rd => ID_Instruction(25 downto 21),
           Reg2_rd => ID_Instruction(20 downto 16),
           Reg_wr => WB_RegDest,
           Data_wr => WB_MuxResult,
           Data1_rd => ID_RegRd1,
           Data2_rd => ID_RegRd2
           );
           
     --Extension del signo
     --Si ID_instruccion(15) el bit es 0 lo extiendo completando con 0 else completo con 1
     ID_SignExt <= (x"0000" & Id_Instruction(15 downto 0)) when (Id_Instruction(15) = '0') else (x"FFFF" & ID_Instruction(15 downto 0));

----------------------------------------
-- Pipeline ID/EX
----------------------------------------

    IDEX_Reg : process(Clk,Reset)
    begin
        if(Reset = '1') then
            --Reset
            EXE_PcNext <= (others => '0');
            EXE_RegRd1 <=(others => '0');
            EXE_RegRd2 <=(others => '0');
            EXE_SignExt <=(others => '0');
            EXE_RegDst <= '0';
            EXE_AluSrc <= '0';
            EXE_AluOp <= "000";
            EXE_Branch <= '0';
            EXE_MemWrite <='0';
            EXE_MemRead <= '0';
            EXE_MemToReg <= '0';
            EXE_RegWrite <='0';
            EXE_Rt <= (others => '0');
            EXE_Rd <= (others => '0');
        elsif (rising_edge(CLK)) then 
            -- Asignaciones en flanco ascendete del clock
            EXE_RegDst <= ID_RegDst;
            EXE_AluSrc <= ID_AluSrc;
            EXE_AluOp <= ID_AluOp;
            EXE_Branch <= ID_Branch;
            EXE_MemWrite <= ID_MemWrite;
            EXE_MemRead <= ID_MemRead;
            EXE_MemToReg <= ID_MemToReg;
            EXE_RegWrite <= ID_RegWrite;
            EXE_PcNext <= ID_PcNext;
            EXE_RegRd1 <= ID_RegRd1;   
            EXE_RegRd2 <= ID_RegRd2;   
            EXE_SignExt <= ID_SignExt;
            EXE_Rt <= ID_Instruction(20 downto 16);
            EXE_Rd <= ID_Instruction(15 downto 11);
        end if;
 end process; 

----------------------------------------
-- Ejecución 
----------------------------------------

    -- Branch address 
    EXE_BranchAddress <= EXE_PcNext + (EXE_SignExt(29 downto 0)& "00");
    
    --Mux AluSrc
    EXE_AluMux <= EXE_RegRd2 when(EXE_AluSrc = '0') else EXE_SignExt; 
    
    -- Inicializacion de la Alu 
    EXE_ALU: ALU PORT MAP(
       a => EXE_RegRd1,
       b => EXE_AluMux,
       Control => EXE_AluControl,
       Salida => EXE_AluResult,
       Zero => EXE_Zero
    );
    
    --Alu control
    EXE_ALUCtrl : process (EXE_SignExt(5 downto 0), EXE_AluOp)
    begin
      case(EXE_AluOp) is
        when "111" => --Type R-Format
             case (EXE_SignExt(5 downto 0)) is 
                 when "100000" =>  --ADD                  
                       EXE_AluControl <= "010";   
                 when "100010" => --SUB
                       EXE_AluControl <= "110";
                 when "100100" => -- AND
                       EXE_AluControl <= "000";
                 when "100101" => -- OR
                       EXE_AluControl <= "001";
                 when "101010" => -- SLT
                       EXE_AluControl <= "111";
                 when others => 
                       EXE_AluControl <= "000";
             end case;
        when "000" =>  -- LOAD , STORE y LUI
            EXE_AluControl <= "010";
        when "101" =>  -- LUI
            EXE_AluControl <= "100";
        when "001" =>  --BEQ
            EXE_AluControl <= "110";
        when "010" =>  --ADDI
            EXE_AluControl <= "010";
        when "011" =>  --ORI
            EXE_AluControl <= "001";
        when "100" => -- ANDI
            EXE_AluControl <= "000";
        when others =>  
            EXE_AluControl <= "000"; 
      end case;   
    end process;
    
    --Mux destino
    EXE_RegDestMux <= EXE_Rt when (EXE_RegDst = '0') else EXE_Rd;

----------------------------------------
-- Pipeline EM/MEM
----------------------------------------
    EMMEM_Reg : process(Clk,Reset)
    Begin 
        if Reset = '1' then 
            MEM_Branch <= '0';
            MEM_MemRead <= '0';
            MEM_MemWrite <= '0';
            MEM_MemToReg <= '0'; 
            MEM_RegWrite <= '0';
            MEM_BranchAddress <= (others => '0');
            MEM_Zero <= '0';
            MEM_AluResult <= (others => '0');
            MEM_RegRd2 <= (others => '0');
            MEM_RegDest <= (others => '0');
        elsif rising_edge(Clk) then
            MEM_Branch <= EXE_Branch ;
            MEM_MemRead <= EXE_MemRead;
            MEM_MemWrite <= EXE_MemWrite; 
            MEM_MemToReg <= EXE_MemToReg; 
            MEM_RegWrite <= EXE_RegWrite ;
            MEM_BranchAddress <= EXE_BranchAddress;
            MEM_Zero <= EXE_Zero;
            MEM_AluResult <= EXE_AluResult;
            MEM_RegRd2 <= EXE_RegRd2;
            MEM_RegDest <= EXE_RegDestMux;
        end if;
    end process;

----------------------------------------
-- Memoria
----------------------------------------

    -- Branch And 
    MEM_PcSrc <= MEM_Branch and MEM_Zero;
    
    -- Data Memory
    D_Addr <= MEM_AluResult; 
    D_DataOut <= MEM_RegRd2;
    D_RdStb <= MEM_MemRead;
    D_WrStb <= MEM_MemWrite; 

----------------------------------------
-- Pipeline MEM/WB
----------------------------------------
    
   MEMWB_Reg : process (Clk,Reset)
    begin
        if (Reset = '1') then
            WB_MemToReg <= '0';
            WB_RegWrite <= '0';
            WB_ReadData <= (others => '0');
            WB_Address <= (others => '0');
            WB_RegDest <= (others => '0');
        elsif (rising_edge(Clk)) then
            WB_MemToReg <= MEM_MemToReg;
            WB_RegWrite <= MEM_RegWrite; 
            WB_ReadData <= D_DataIn ;
            WB_Address <= MEM_AluResult;
            WB_RegDest <= MEM_RegDest;
        end if;
    end process;

----------------------------------------
-- Pipeline MEM/WB
----------------------------------------
    
    --Mux resultado a guardar en el banco
    WB_MuxResult <= WB_ReadData when (WB_MemToReg = '1') else WB_Address;

end processor_arq;



