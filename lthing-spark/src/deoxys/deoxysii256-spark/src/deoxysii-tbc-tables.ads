------------------------------------------------------------------------------
--  Deoxysii.TBC.Tables — P-lane constants (SUBAGENT-P owns).
--
--  Compile-time constant arrays per DEOXY_1_41.md:
--    SBOX   (P-3, AES forward S-box; SBOX(16#25#) = 16#3F# self-test below).
--           Kept as a correctness oracle for tests/sbox_const_time.adb; the
--           runtime Sub_Bytes/Inv_Sub_Bytes path (deoxysii-tbc.adb, REAL-2)
--           no longer reads this table — it computes the S-box via
--           constant-time GF(2^8) inversion + affine transform instead.
--    SR     (P-4, ShiftRows destination map; gather: new[i] := old[SR[i]]),
--    Inv_SR (REAL-1, functional inverse of SR, for TBC_Decrypt_384 only),
--    H      (P-7, tweakey byte permutation; gather form new[i] := old[H[i]]),
--    RCON   (P-8, 17 round constants; RCON(0) = 16#2F#, LANDMINE-1 resolved:
--           table row authoritative, RCON(i) = x^(15+i) in GF(2^8)/0x11B).
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package Deoxysii.TBC.Tables is

   --  Index/permutation helper types ---------------------------------------

   subtype Index16 is Natural range 0 .. 15;
   type Perm16 is array (Index16) of Index16;

   --  P-3: AES forward S-box, full 256-entry table, row = high nibble,
   --  col = low nibble (v1.41 App A.1). -------------------------------------

   type SBox_Table is array (Byte) of Byte;

   SBOX : constant SBox_Table :=
     (16#63#, 16#7C#, 16#77#, 16#7B#, 16#F2#, 16#6B#, 16#6F#, 16#C5#,
      16#30#, 16#01#, 16#67#, 16#2B#, 16#FE#, 16#D7#, 16#AB#, 16#76#,

      16#CA#, 16#82#, 16#C9#, 16#7D#, 16#FA#, 16#59#, 16#47#, 16#F0#,
      16#AD#, 16#D4#, 16#A2#, 16#AF#, 16#9C#, 16#A4#, 16#72#, 16#C0#,

      16#B7#, 16#FD#, 16#93#, 16#26#, 16#36#, 16#3F#, 16#F7#, 16#CC#,
      16#34#, 16#A5#, 16#E5#, 16#F1#, 16#71#, 16#D8#, 16#31#, 16#15#,

      16#04#, 16#C7#, 16#23#, 16#C3#, 16#18#, 16#96#, 16#05#, 16#9A#,
      16#07#, 16#12#, 16#80#, 16#E2#, 16#EB#, 16#27#, 16#B2#, 16#75#,

      16#09#, 16#83#, 16#2C#, 16#1A#, 16#1B#, 16#6E#, 16#5A#, 16#A0#,
      16#52#, 16#3B#, 16#D6#, 16#B3#, 16#29#, 16#E3#, 16#2F#, 16#84#,

      16#53#, 16#D1#, 16#00#, 16#ED#, 16#20#, 16#FC#, 16#B1#, 16#5B#,
      16#6A#, 16#CB#, 16#BE#, 16#39#, 16#4A#, 16#4C#, 16#58#, 16#CF#,

      16#D0#, 16#EF#, 16#AA#, 16#FB#, 16#43#, 16#4D#, 16#33#, 16#85#,
      16#45#, 16#F9#, 16#02#, 16#7F#, 16#50#, 16#3C#, 16#9F#, 16#A8#,

      16#51#, 16#A3#, 16#40#, 16#8F#, 16#92#, 16#9D#, 16#38#, 16#F5#,
      16#BC#, 16#B6#, 16#DA#, 16#21#, 16#10#, 16#FF#, 16#F3#, 16#D2#,

      16#CD#, 16#0C#, 16#13#, 16#EC#, 16#5F#, 16#97#, 16#44#, 16#17#,
      16#C4#, 16#A7#, 16#7E#, 16#3D#, 16#64#, 16#5D#, 16#19#, 16#73#,

      16#60#, 16#81#, 16#4F#, 16#DC#, 16#22#, 16#2A#, 16#90#, 16#88#,
      16#46#, 16#EE#, 16#B8#, 16#14#, 16#DE#, 16#5E#, 16#0B#, 16#DB#,

      16#E0#, 16#32#, 16#3A#, 16#0A#, 16#49#, 16#06#, 16#24#, 16#5C#,
      16#C2#, 16#D3#, 16#AC#, 16#62#, 16#91#, 16#95#, 16#E4#, 16#79#,

      16#E7#, 16#C8#, 16#37#, 16#6D#, 16#8D#, 16#D5#, 16#4E#, 16#A9#,
      16#6C#, 16#56#, 16#F4#, 16#EA#, 16#65#, 16#7A#, 16#AE#, 16#08#,

      16#BA#, 16#78#, 16#25#, 16#2E#, 16#1C#, 16#A6#, 16#B4#, 16#C6#,
      16#E8#, 16#DD#, 16#74#, 16#1F#, 16#4B#, 16#BD#, 16#8B#, 16#8A#,

      16#70#, 16#3E#, 16#B5#, 16#66#, 16#48#, 16#03#, 16#F6#, 16#0E#,
      16#61#, 16#35#, 16#57#, 16#B9#, 16#86#, 16#C1#, 16#1D#, 16#9E#,

      16#E1#, 16#F8#, 16#98#, 16#11#, 16#69#, 16#D9#, 16#8E#, 16#94#,
      16#9B#, 16#1E#, 16#87#, 16#E9#, 16#CE#, 16#55#, 16#28#, 16#DF#,

      16#8C#, 16#A1#, 16#89#, 16#0D#, 16#BF#, 16#E6#, 16#42#, 16#68#,
      16#41#, 16#99#, 16#2D#, 16#0F#, 16#B0#, 16#54#, 16#BB#, 16#16#);

   --  Self-test (v1.41 A.1 example); gnatprove discharges this as a VC.
   pragma Assert (SBOX (16#25#) = 16#3F#);

   --  P-4: ShiftRows destination map (v1.41 l.523). ------------------------

   SR : constant Perm16 :=
     (0, 5, 10, 15,  4, 9, 14, 3,  8, 13, 2, 7,  12, 1, 6, 11);

   --  REAL-1: inverse ShiftRows permutation, the functional inverse of SR
   --  (Inv_SR(SR(i)) = i for all i), derived mechanically: for each i,
   --  Inv_SR(SR(i)) := i. Used by TBC_Decrypt_384 only. -----------------

   Inv_SR : constant Perm16 :=
     (0, 13, 10, 7,  4, 1, 14, 11,  8, 5, 2, 15,  12, 9, 6, 3);

   --  P-7: tweakey byte permutation h (v1.41 l.593-620 == JoC 438-460). -----

   H : constant Perm16 :=
     (1, 6, 11, 12,  5, 10, 15, 0,  9, 14, 3, 4,  13, 2, 7, 8);

   --  P-8: round constants RCON(0..16). RCON(0) = 16#2F# (LANDMINE-1: table
   --  row authoritative, not the inconsistent 1-based caption). ------------

   type RCON_Table is array (0 .. 16) of Byte;

   RCON : constant RCON_Table :=
     (16#2F#, 16#5E#, 16#BC#, 16#63#, 16#C6#, 16#97#, 16#35#, 16#6A#,
      16#D4#, 16#B3#, 16#7D#, 16#FA#, 16#EF#, 16#C5#, 16#91#, 16#39#,
      16#72#);

end Deoxysii.TBC.Tables;
