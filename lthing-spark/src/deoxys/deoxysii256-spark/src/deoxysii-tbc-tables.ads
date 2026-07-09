------------------------------------------------------------------------------
--  Deoxysii.TBC.Tables — P-lane constants (SUBAGENT-P owns).
--
--  SUBAGENT-P fills at P1/P2 with compile-time constant arrays:
--    SBOX  (P-3, AES forward S-box; include the SBOX(16#25#) = 16#3F#
--           self-test as an assertion),
--    SR    (P-4, ShiftRows destination map),
--    H     (P-7, tweakey byte permutation),
--    RCON  (P-8, round constants; RCON(0) = 16#2F#, LANDMINE-1 resolved).
--  Structure scaffolded at G0; contents are P's.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package Deoxysii.TBC.Tables is

end Deoxysii.TBC.Tables;
