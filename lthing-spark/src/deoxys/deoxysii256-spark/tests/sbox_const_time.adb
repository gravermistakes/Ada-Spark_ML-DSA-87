------------------------------------------------------------------------------
--  sbox_const_time — gate REAL-2: the constant-time S-box computation
--  (GF(2^8) inversion via a fixed square-and-multiply chain + affine
--  transform, deoxysii-tbc.adb) must exactly match the pinned SBOX table
--  for all 256 byte values, and its inverse must round-trip for all 256
--  byte values. Both checks are exhaustive (256/256), not sampled, and
--  compare against data already in the tree (SBOX) rather than any new or
--  hand-computed vector.
--  Prints [PASS]/[FAIL]; exit status Failure on any fail.
------------------------------------------------------------------------------

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Command_Line;    use Ada.Command_Line;
with Deoxysii;            use Deoxysii;
with Deoxysii.TBC;
with Deoxysii.TBC.Tables; use Deoxysii.TBC.Tables;

procedure Sbox_Const_Time is
   Table_Mismatches   : Natural := 0;
   Roundtrip_Failures : Natural := 0;
begin
   for X in Byte'Range loop
      if Deoxysii.TBC.Sub_Bytes_Byte (X) /= SBOX (X) then
         Table_Mismatches := Table_Mismatches + 1;
         if Table_Mismatches <= 5 then
            Put_Line ("[FAIL] Sub_Bytes_Byte(" & Byte'Image (X) & ") /= SBOX");
         end if;
      end if;
      if Deoxysii.TBC.Inv_Sub_Bytes_Byte
           (Deoxysii.TBC.Sub_Bytes_Byte (X)) /= X
      then
         Roundtrip_Failures := Roundtrip_Failures + 1;
         if Roundtrip_Failures <= 5 then
            Put_Line ("[FAIL] Inv_Sub_Bytes_Byte(Sub_Bytes_Byte("
                      & Byte'Image (X) & ")) /= X");
         end if;
      end if;
   end loop;

   Put_Line ("sbox table match:" & Natural'Image (256 - Table_Mismatches)
             & " / 256");
   Put_Line ("sbox inverse roundtrip:" & Natural'Image (256 - Roundtrip_Failures)
             & " / 256");

   --  Self-test from spec (DEOXY_1_41 App A.1): SBOX(0x25) = 0x3F.
   if Deoxysii.TBC.Sub_Bytes_Byte (16#25#) /= 16#3F# then
      Put_Line ("[FAIL] Sub_Bytes_Byte(0x25) /= 0x3F self-test");
      Table_Mismatches := Table_Mismatches + 1;
   end if;

   if Table_Mismatches = 0 and then Roundtrip_Failures = 0 then
      Put_Line ("[PASS] constant-time S-box matches SBOX table + inverse round-trips");
   else
      Put_Line ("[FAIL] constant-time S-box");
      Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
end Sbox_Const_Time;
