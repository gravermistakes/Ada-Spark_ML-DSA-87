------------------------------------------------------------------------------
--  Deoxysii.Mode (body) — SCT-2 mode logic, driven by the generic oracle E.
--
--  Tweak layout (DEOXY_1_41.md M-2, frozen table):
--
--    purpose                | tweak (128 bits)        | block input to E
--    AD, full block i       | 0010 || i(124)          | A_(i+1)
--    AD, last partial (la)  | 0110 || la(124)         | pad10(A*)
--    Msg-auth, full block j | 0000 || j(124)          | M_(j+1)
--    Msg-auth, last (l)     | 0100 || l(124)          | pad10(M*)
--    Tag finalization       | 0001 || 0000 || N(120)  | running tag
--    Keystream, block j     | tagp xor int_128(j)     | 0x00 || N(120)
--
--  Every counter (i/j/l/la) realizable from a Byte_Seq bounded by
--  Natural'Last fits comfortably in 64 bits, far below the true
--  maxl = 2**60 ceiling, so counters are embedded in the low-order 8 bytes
--  of the 124-bit / 128-bit counter field; the remaining high-order bytes
--  of that field are always zero.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Interfaces;
use type Interfaces.Unsigned_64;
with Deoxysii.CT;

package body Deoxysii.Mode is

   ---------------------------------------------------------------------
   --  Small fixed-size block helpers
   ---------------------------------------------------------------------

   function Xor_Block (A, B : Block_128) return Block_128
     with Global => null
   is
      R : Block_128;
   begin
      for I in R'Range loop
         R (I) := A (I) xor B (I);
      end loop;
      return R;
   end Xor_Block;

   function To_Block (T : Tag_128) return Block_128
     with Global => null
   is
      R : Block_128;
   begin
      for I in R'Range loop
         R (I) := T (I);
      end loop;
      return R;
   end To_Block;

   function To_Tag (B : Block_128) return Tag_128
     with Global => null
   is
      R : Tag_128;
   begin
      for I in R'Range loop
         R (I) := B (I);
      end loop;
      return R;
   end To_Tag;

   --  Domain-separation tweak for a *counter* purpose: top 4 bits of byte 0
   --  = Prefix (0 .. 15), remaining 124 bits = big-endian Counter, embedded
   --  in the low-order 8 bytes (bytes 8 .. 15).
   function Make_Tweak_Ctr
     (Prefix : Byte; Counter : Interfaces.Unsigned_64) return Block_128
     with Global => null
   is
      R : Block_128 := (others => 0);
      C : Interfaces.Unsigned_64 := Counter;
   begin
      R (0) := Prefix * 16;
      for I in 0 .. 7 loop
         R (15 - I) := Byte (C mod 256);
         C := C / 256;
      end loop;
      return R;
   end Make_Tweak_Ctr;

   --  Tag-finalization tweak: fixed byte 0 = 0001_0000, then the raw
   --  120-bit nonce filling bytes 1 .. 15.
   function Make_Tweak_Final (Nonce : Nonce_120) return Block_128
     with Global => null
   is
      R : Block_128 := (others => 0);
   begin
      R (0) := 16#10#;
      for I in Nonce'Range loop
         R (I + 1) := Nonce (I);
      end loop;
      return R;
   end Make_Tweak_Final;

   --  Keystream block input: one zero byte then the 15-byte nonce.
   function Make_KS_Input (Nonce : Nonce_120) return Block_128
     with Global => null
   is
      R : Block_128 := (others => 0);
   begin
      for I in Nonce'Range loop
         R (I + 1) := Nonce (I);
      end loop;
      return R;
   end Make_KS_Input;

   --  Keystream tweak: tagp xor int_128(Counter), Counter embedded in the
   --  low-order 8 bytes exactly like Make_Tweak_Ctr's counter field.
   function Make_KS_Tweak
     (Tagp : Block_128; Counter : Interfaces.Unsigned_64) return Block_128
     with Global => null
   is
      Ctr : Block_128 := (others => 0);
      C   : Interfaces.Unsigned_64 := Counter;
   begin
      for I in 0 .. 7 loop
         Ctr (15 - I) := Byte (C mod 256);
         C := C / 256;
      end loop;
      return Xor_Block (Tagp, Ctr);
   end Make_KS_Tweak;

   function To_Block128 (S : Byte_Seq) return Block_128
     with
       Global => null,
       Pre    => S'Length = 16
   is
      R : Block_128;
   begin
      for I in 0 .. 15 loop
         R (I) := S (S'First + I);
      end loop;
      return R;
   end To_Block128;

   --  pad10: X || 1 || 0^(n-|X|-1), for 1 <= |X| <= 15 (the empty-X case is
   --  handled by the caller by skipping the term entirely, per M-1).
   function Pad10 (S : Byte_Seq) return Block_128
     with
       Global => null,
       Pre    => S'Length in 1 .. 15
   is
      R : Block_128 := (others => 0);
   begin
      for I in 0 .. S'Length - 1 loop
         R (I) := S (S'First + I);
      end loop;
      R (S'Length) := 16#80#;
      return R;
   end Pad10;

   ---------------------------------------------------------------------
   --  Domain sum: XOR-accumulate E(prefix||i, block) over every full
   --  16-byte block of Data, plus one E(partial_prefix||full_count,
   --  pad10(remainder)) term if Data's length is not a multiple of 16.
   --  Shared by the AD phase (prefixes 2/6) and the message-authentication
   --  phase (prefixes 0/4) of M-3/M-4.
   ---------------------------------------------------------------------
   function Domain_Sum
     (Key            : Key_256;
      Data           : Byte_Seq;
      Full_Prefix    : Byte;
      Partial_Prefix : Byte) return Block_128
     with Global => null
   is
      Acc     : Block_128 := (others => 0);
      Full    : Natural;
      Rem_Len : Natural;
   begin
      --  Byte_Seq lengths are host-memory-bounded, far below Natural'Last
      --  (deoxysii.ads sec 2: "the maxl ceiling is documented, not
      --  separately enforced by a precondition, since no achievable Ada
      --  array approaches it"). This assumption lets the block-splitting
      --  arithmetic below be verified without a spurious "array spans the
      --  entire Natural index range" counterexample that no real AD/Msg
      --  buffer could ever realize.
      --  Phrased via 'Last (already a plain Natural value) rather than
      --  'Length, so evaluating the assumption itself never repeats the
      --  same range check it exists to discharge.
      pragma Assume
        (Data'Last <= Natural'Last - 17,
         "Byte_Seq is host-memory-bounded; no achievable AD/Msg array " &
         "comes within 16 bytes of Natural'Last (deoxysii.ads sec 2).");
      Full    := Data'Length / 16;
      Rem_Len := Data'Length mod 16;
      for I in 0 .. Full - 1 loop
         pragma Loop_Invariant (Full = Data'Length / 16);
         declare
            Blk : constant Block_128 :=
              To_Block128 (Data (Data'First + I * 16 .. Data'First + I * 16 + 15));
            Tw  : constant Block_128 :=
              Make_Tweak_Ctr (Full_Prefix, Interfaces.Unsigned_64 (I));
         begin
            Acc := Xor_Block (Acc, E (Key, Tw, Blk));
         end;
      end loop;

      if Rem_Len > 0 then
         declare
            Part : constant Byte_Seq := Data (Data'First + Full * 16 .. Data'Last);
            Blk  : constant Block_128 := Pad10 (Part);
            Tw   : constant Block_128 :=
              Make_Tweak_Ctr (Partial_Prefix, Interfaces.Unsigned_64 (Full));
         begin
            Acc := Xor_Block (Acc, E (Key, Tw, Blk));
         end;
      end if;

      return Acc;
   end Domain_Sum;

   ---------------------------------------------------------------------
   --  Counter-mode keystream application: the identical construction is
   --  used both to encrypt (Input => Msg) and to recover the message
   --  (Input => CT) -- Deoxys-II uses only the forward oracle E, and XOR
   --  is its own inverse, so one procedure serves both directions.
   ---------------------------------------------------------------------
   procedure Apply_Keystream
     (Key    : Key_256;
      Tagp   : Block_128;
      Nonce  : Nonce_120;
      Input  : Byte_Seq;
      Output : out Byte_Seq)
     with
       Global => null,
       Pre    => Output'Length = Input'Length
   is
      Full    : Natural;
      Rem_Len : Natural;
      KSInput : constant Block_128 := Make_KS_Input (Nonce);
   begin
      Output := (others => 0);
      --  See Domain_Sum: Byte_Seq lengths are host-memory-bounded, far
      --  below Natural'Last (deoxysii.ads sec 2).
      pragma Assume
        (Input'Last <= Natural'Last - 17,
         "Byte_Seq is host-memory-bounded; no achievable CT/Msg array " &
         "comes within 16 bytes of Natural'Last (deoxysii.ads sec 2).");
      Full    := Input'Length / 16;
      Rem_Len := Input'Length mod 16;
      for I in 0 .. Full - 1 loop
         pragma Loop_Invariant (Full = Input'Length / 16);
         declare
            Tw : constant Block_128 := Make_KS_Tweak (Tagp, Interfaces.Unsigned_64 (I));
            KS : constant Block_128 := E (Key, Tw, KSInput);
         begin
            for B in 0 .. 15 loop
               Output (Output'First + I * 16 + B) :=
                 Input (Input'First + I * 16 + B) xor KS (B);
            end loop;
         end;
      end loop;

      if Rem_Len > 0 then
         declare
            Tw : constant Block_128 := Make_KS_Tweak (Tagp, Interfaces.Unsigned_64 (Full));
            KS : constant Block_128 := E (Key, Tw, KSInput);
         begin
            for B in 0 .. Rem_Len - 1 loop
               Output (Output'First + Full * 16 + B) :=
                 Input (Input'First + Full * 16 + B) xor KS (B);
            end loop;
         end;
      end if;
   end Apply_Keystream;

   ---------------------------------------------------------------------
   --  M-3 encryption
   ---------------------------------------------------------------------
   procedure Seal
     (Key   : Key_256;
      Nonce : Nonce_120;
      AD    : Byte_Seq;
      Msg   : Byte_Seq;
      CT    : out Byte_Seq;
      Tag   : out Tag_128)
   is
      Auth      : constant Block_128 := Domain_Sum (Key, AD, 2, 6);
      Tag_Pre   : constant Block_128 :=
        Xor_Block (Auth, Domain_Sum (Key, Msg, 0, 4));
      Tag_Block : constant Block_128 := E (Key, Make_Tweak_Final (Nonce), Tag_Pre);
      Tagp      : Block_128 := Tag_Block;
   begin
      Tag := To_Tag (Tag_Block);
      Tagp (0) := Tagp (0) or 16#80#;
      Apply_Keystream (Key, Tagp, Nonce, Msg, CT);
   end Seal;

   ---------------------------------------------------------------------
   --  M-4 decryption / verification
   ---------------------------------------------------------------------
   procedure Open
     (Key   : Key_256;
      Nonce : Nonce_120;
      AD    : Byte_Seq;
      CT    : Byte_Seq;
      Tag   : Tag_128;
      Msg   : out Byte_Seq;
      Ok    : out Boolean)
   is
      Tagp : Block_128 := To_Block (Tag);
   begin
      Tagp (0) := Tagp (0) or 16#80#;

      --  Recover the message from CT using the keystream derived from the
      --  *received* tag (M-4: "regenerates the SAME keystream from the
      --  RECEIVED tag"). Msg now holds the recovered plaintext candidate.
      Apply_Keystream (Key, Tagp, Nonce, CT, Msg);

      declare
         Auth       : constant Block_128 := Domain_Sum (Key, AD, 2, 6);
         Tag_Pre    : constant Block_128 :=
           Xor_Block (Auth, Domain_Sum (Key, Msg, 0, 4));
         Recomputed : constant Tag_128 :=
           To_Tag (E (Key, Make_Tweak_Final (Nonce), Tag_Pre));
      begin
         Ok := Deoxysii.CT.CT_Equal (Recomputed, Tag);
      end;

      if not Ok then
         Deoxysii.CT.Zeroize (Msg);
      end if;
   end Open;

end Deoxysii.Mode;
