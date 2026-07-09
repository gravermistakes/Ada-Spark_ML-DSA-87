------------------------------------------------------------------------------
--  Deoxysii — Deoxys-II-256-128 (SCT-2 over Deoxys-BC-384), Ada/SPARK
--
--  Root package: shared type contract (DEOXYSIIS.md sec 2) and public mode
--  API (DEOXY_1_41.md M-6). Types and the Deoxysii.TBC seam are FROZEN at G0;
--  do not alter them (invariant I2).
--
--  Fail-closed (invariant I5): Decrypt returns Ok = False and a zeroized Msg
--  on any verification failure; no plaintext leaves the procedure on the
--  failure path.
--
--  Copyright (c) l'Evermoor.
--  Licensed under THE EVERMOOR SANCTUARY LICENSE
--    (ESL-ANCSA-MRA-IndiModSHA v1.3). See repository LICENSE for full terms.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package Deoxysii is

   --  Shared type contract (frozen at G0) --------------------------------

   type Byte is mod 2**8 with Size => 8;

   type Block_128 is array (0 .. 15) of Byte;   --  column-major state (P-1)
   type Key_256   is array (0 .. 31) of Byte;
   type Nonce_120 is array (0 .. 14) of Byte;   --  120-bit nonce
   type Tag_128   is array (0 .. 15) of Byte;

   type Byte_Seq is array (Natural range <>) of Byte;

   subtype State is Block_128;

   type Subtweakeys is array (0 .. 16) of Block_128;   --  STK[0..16] (P-2)

   --  Public mode API (M-6) ----------------------------------------------

   procedure Encrypt (Key   : Key_256;
                      Nonce : Nonce_120;
                      AD    : Byte_Seq;
                      Msg   : Byte_Seq;
                      CT    : out Byte_Seq;
                      Tag   : out Tag_128)
     with Pre => CT'Length = Msg'Length;

   procedure Decrypt (Key   : Key_256;
                      Nonce : Nonce_120;
                      AD    : Byte_Seq;
                      CT    : Byte_Seq;
                      Tag   : Tag_128;
                      Msg   : out Byte_Seq;
                      Ok    : out Boolean)
     with Pre  => Msg'Length = CT'Length,
          Post => (if not Ok then (for all B of Msg => B = 0));

end Deoxysii;
