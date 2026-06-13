------------------------------------------------------------------------------
--  LTHING.KAT_FFI — Imports for Keccak KAT testing
--
--  Flexible-rate versions of SHAKE functions for testing SHAKE128/256
--  at their specified rates (168/136) without the SHAKE512_Rate constraint.
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Interfaces;        use Interfaces;
with Interfaces.C;       use Interfaces.C;
with LTHING_Types;      use LTHING_Types;

package LTHING_KAT_FFI is

   --  Keccak state: 25 lanes of 64 bits (same as Crypto_FFI).
   subtype Lane_Index is Natural range 0 .. 24;
   type Keccak_State is array (Lane_Index) of Interfaces.Unsigned_64;

   --  keccak_f1600(state) — direct permutation, no rate/padding logic
   procedure Keccak_F1600
     (State : in out Keccak_State)
     with Global => null,
          Import => True,
          Convention => C,
          External_Name => "keccak_f1600";

   --  shake256_absorb(state, data, data_len, rate) — flexible rate
   procedure SHAKE_Absorb
     (State    : in out Keccak_State;
      Data     : Byte_Array;
      Data_Len : Interfaces.C.unsigned;
      Rate     : Interfaces.C.unsigned)
     with Global => null,
          Import => True,
          Convention => C,
          External_Name => "shake256_absorb",
          Pre => Data'Length > 0;

   --  shake256_squeeze(state, output, output_len, rate) — flexible rate
   procedure SHAKE_Squeeze
     (State      : in out Keccak_State;
      Output     : out Byte_Array;
      Output_Len : Interfaces.C.unsigned;
      Rate       : Interfaces.C.unsigned)
     with Global => null,
          Import => True,
          Convention => C,
          External_Name => "shake256_squeeze",
          Pre  => Output'Length > 0,
          Post => Output'Length = Output'Length;

end LTHING_KAT_FFI;
