//data Memory 

.data 
num0: .word 1 # posic 0   //00000001
num1: .word 2 # posic 4   //00000002
num2: .word 4 # posic 8   //00000004
num3: .word 8 # posic 12  //00000008
num4: .word 16 # posic 16  //00000010
num5: .word 32 # posic 20 //00000020
num6: .word 0 # posic 24  //00000000 //En la instruccion 27 la memory toma el valor de: 00000001
num7: .word 0 # posic 28  //00000000 //En la instruccion 28 la memory toma el valor de: 00000002
num8: .word 0 # posic 32  //00000000 //En la instruccion 29 la memory toma el valor de: 00000004
num9: .word 0 # posic 36  //00000000 //En la instruccion 30 la memory toma el valor de: 00000008
num10: .word 0 # posic 40 //00000000 //En la instruccion 31 la memory toma el valor de: 00000010
num11: .word 0 # posic 44 //00000000 //En la instruccion 32 la memory toma el valor de: 00000020

//Instruction memory

.text 
main:
  lw $t1, 0($zero) //lw reg 9, memory(0 + 0) // reg 9 -> 00000001 // 8c090000
  lw $t2, 4($zero) //lw reg 10, memory(4 + 0) // reg 10 -> 00000002 // 8c0a0004
  lw $t3, 8($zero)  //lw reg 11, memory(8 + 0) // reg 11 -> 00000004 // 8c0b0008
  lw $t4, 12($zero) //lw reg 12, memory(12 + 0) // reg 12 -> 00000008 // 8c0c000C
  lw $t5, 16($zero) //lw reg 13, memory(16 + 0) // reg 13 -> 00000010 // 8c0d0010
  lw $t6, 20($zero) //lw reg 14, memory(20 + 0) // reg 14 -> 00000020 // 8c0e0014
  sw $t1, 24($zero) //sw reg 9,  memory(24 + 0) // memory(24 + 0) = reg 9 -> 00000001 // ac090018
  sw $t2, 28($zero) //sw reg 10,  memory(28 + 0) // memory(28 + 0) = reg 10 -> 00000002 // ac0a001c
  sw $t3, 32($zero) //sw reg 11,  memory(32 + 0) // memory(32 + 0) = reg 11 -> 00000004 // ac0b0020
  sw $t4, 36($zero) //sw reg 12,  memory(36 + 0) // memory(36 + 0) = reg 12 -> 00000008 // ac0c0024
  sw $t5, 40($zero) //sw reg 13,  memory(40 + 0) // memory(40 + 0) = reg 13 -> 00000010 // ac0d0028
  sw $t6, 44($zero) //sw reg 14,  memory(44 + 0) // memory(44 + 0) = reg 14 -> 00000020 // ac0e002c
  lw $t1, 24($zero) //lw reg 9, memory(24 + 0) // reg 9 -> 00000001 // 8c090018
  lw $t2, 28($zero) //lw reg 10, memory(28 + 0) // reg 10 -> 00000002 // 8c0a001c
  lw $t3, 32($zero) //lw reg 11, memory(32 + 0) // reg 11 -> 00000004 // 8c0b0020
  lw $t4, 36($zero)  //lw reg 12, memory(36 + 0) // reg 12 -> 00000008 // 8c0c0024
  lw $t5, 40($zero)  //lw reg 13, memory(40 + 0) // reg 13 -> 00000010 // 8c0d0028
  lw $t6, 44($zero)  //lw reg 14, memory(44 + 0) // reg 14 -> 00000020 // 8c0e002c
  add $t7, $t1, $t2 // add reg 15, reg 9, reg 10 // reg 15 = reg 9 + reg 10 // reg 15 -> 00000003 // 012a7820
  add $s0, $t3, $t4 // add reg 16, reg 11, reg 12 // reg 16 = reg 11 + reg 12 // reg 16 -> 0000000c // 016c8020
  sub $s1, $t5, $t1 // sub reg 17, reg 13, reg 9 // reg 17 = reg 13 - reg 9 // reg 17 -> 0000000f // 01a98822
  sub $s2, $t6, $t2 // sub reg 18, reg 14, reg 10 // reg 18 = reg 14 + reg 10 // reg 18 -> 0000001e // 01ca9022
  and $s3, $t1, $t2 // and reg 19, reg 9, reg 10 // reg 19 = reg 9 and reg 10 // reg 19 -> 00000000 // 012a9824
  and $s4, $t7, $t2 // and reg 20, reg 15, reg 10 // reg 20 = reg 15 and reg 10 // reg 20 -> 00000002 // 01eaa024
  or $s5, $t1, $t2 // or reg 21, reg 9, reg 10 // reg 21 = reg 9 or reg 10 // reg 21 -> 00000003 // 012aa825
  or $s6, $s0, $t2 // or reg 22, reg 16, reg 10 // reg 22 = reg 16 or reg 10 // reg 22 -> 0000000e // 020ab025
  slt $s7, $t1, $t2 // slt reg 23, reg 16, reg 10 // reg 23 = reg 9 < reg 10 // reg 23 -> 00000001 // 012ab82a
  slt $t8, $s0, $t2 // slt reg 28, reg 16, reg 10 // reg 28 = reg 15 < reg 10 // reg 20 -> 00000000 // 020ac02a
  lui $t1, 1 // lui reg 9, 1 // reg 28 = reg 15 < reg 10 // reg 20 -> 00010000 // 3c090001  // Tenemos un bug y nuestro programa guarda 00000020
  lui $t2, 2 // slt reg 10, 2// reg 28 = reg 15 < reg 10 // reg 20 -> 00020000 // 3c0a0002  // Tenemos un bug y nuestro programa guarda 00000020
  addi $t3, $t3, 6 // addi reg 11, reg 11, 6 // reg 11 = reg 11 + 6 // reg 11 -> 0000000A // 216b0006
  ori $t4, $t4, 70 // ori reg 12, reg 12, 70 // reg 12 = reg 12 ori 70 // reg 20 -> 00000070 // 358c0070
  andi $t7, $t7, 2 // andi reg 20, reg 20, 2 // reg 20 = reg 20 andi 2 // reg 20 -> 00000002 // 31ef0002

//Como deberian quedar los registros al finalizar  

$t1 reg 9 -> 00010000
$t2 reg 10 -> 00020000
$t3 reg 11 -> 0000000A
$t4 reg 12 -> 0000011A
$t5 reg 13 -> 00000010
$t6 reg 14 -> 00000020
$t7 reg 15 -> 00000002
$s0 reg 16 -> 0000000C
$s1 reg 17 -> 0000000f
$s2 reg 18 -> 0000001E
$s3 reg 19 -> 00000000
$s4 reg 20 -> 00000002
$s5 reg 21 -> 00000003
$s6 reg 22 -> 0000000E
$s7 reg 23 -> 00000001
$t8 reg 24 -> 00000000


