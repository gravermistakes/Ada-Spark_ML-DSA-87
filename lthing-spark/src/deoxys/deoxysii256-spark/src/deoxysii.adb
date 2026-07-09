------------------------------------------------------------------------------
--  Deoxysii — M1 body: real Deoxys-II-256-128 SCT-2 mode (DEOXY_1_41.md
--  M-3/M-4) over Deoxysii.Mode (tweak/pad10 algebra) and the frozen
--  Deoxysii.TBC seam (called as an opaque forward-only oracle).
--
--  Fail-closed (I5): Decrypt writes Msg := (others => 0) up front, recovers
--  candidate plaintext into it while re-deriving the tag, and on a tag
--  mismatch overwrites Msg with Deoxysii.CT.Zeroize before returning
--  Ok = False -- the only operation on Msg in the failure branch is that
--  zeroizing write.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Deoxysii.Mode;
with Deoxysii.TBC;
with Deoxysii.CT;

package body Deoxysii is

   procedure Encrypt (Key   : Key_256;
                      Nonce : Nonce_120;
                      AD    : Byte_Seq;
                      Msg   : Byte_Seq;
                      CT    : out Byte_Seq;
                      Tag   : out Tag_128)
   is
      use Deoxysii.Mode;
      use Deoxysii.TBC;

      Auth : Tag_128 := (others => 0);
      T    : Tag_128;

      --  AD'Length / Msg'Length are routed through Long_Long_Integer: for
      --  the fully unconstrained (frozen) Byte_Seq = array (Natural range
      --  <>), the degenerate bound AD'First = 0, AD'Last = Natural'Last
      --  gives a mathematical length of 2**31, which does not fit back in
      --  Natural -- Long_Long_Integer has ample headroom, and the final
      --  Length/16 result is always << Natural'Last, so the closing
      --  conversion back to Natural is unconditionally provable.
      AD_Full  : constant Natural :=
        Natural (Long_Long_Integer (AD'Length) / 16);
      AD_Rem   : constant Natural :=
        Natural (Long_Long_Integer (AD'Length) mod 16);
      Msg_Full : constant Natural :=
        Natural (Long_Long_Integer (Msg'Length) / 16);
      Msg_Rem  : constant Natural :=
        Natural (Long_Long_Integer (Msg'Length) mod 16);
   begin
      CT := (others => 0);

      --  Phase 1: authenticate AD (M-3).
      for I in 1 .. AD_Full loop
         declare
            Idx : constant Natural := I - 1;
            Blk : constant Block_128 :=
              To_Block (AD (AD'First + 16 * Idx .. AD'First + 16 * Idx + 15));
            E   : constant Block_128 :=
              TBC_Encrypt_384 (Key, Counter_Tweak (Prefix_AD_Full, Idx), Blk);
         begin
            Auth := Xor_Tag (Auth, E);
         end;
      end loop;

      if AD_Rem > 0 then
         declare
            Blk : constant Block_128 :=
              Pad10 (AD (AD'First + 16 * AD_Full .. AD'Last));
            E   : constant Block_128 :=
              TBC_Encrypt_384
                (Key, Counter_Tweak (Prefix_AD_Last, AD_Full), Blk);
         begin
            Auth := Xor_Tag (Auth, E);
         end;
      end if;

      --  Phase 2: authenticate Msg -> running tag, then finalize (M-3).
      T := Auth;
      for J in 1 .. Msg_Full loop
         declare
            Idx : constant Natural := J - 1;
            Blk : constant Block_128 :=
              To_Block
                (Msg (Msg'First + 16 * Idx .. Msg'First + 16 * Idx + 15));
            E   : constant Block_128 :=
              TBC_Encrypt_384 (Key, Counter_Tweak (Prefix_Msg_Full, Idx), Blk);
         begin
            T := Xor_Tag (T, E);
         end;
      end loop;

      if Msg_Rem > 0 then
         declare
            Blk : constant Block_128 :=
              Pad10 (Msg (Msg'First + 16 * Msg_Full .. Msg'Last));
            E   : constant Block_128 :=
              TBC_Encrypt_384
                (Key, Counter_Tweak (Prefix_Msg_Last, Msg_Full), Blk);
         begin
            T := Xor_Tag (T, E);
         end;
      end if;

      T := Tag_128
             (TBC_Encrypt_384 (Key, Finalize_Tweak (Nonce), Block_128 (T)));

      --  Phase 3: encrypt with keystream derived from the finalized tag
      --  (counter-style, forward E only, M-3).
      for J in 1 .. Msg_Full loop
         declare
            Idx : constant Natural := J - 1;
            KS  : constant Block_128 :=
              TBC_Encrypt_384
                (Key, Keystream_Tweak (T, Idx), Keystream_Input (Nonce));
            Blk : constant Block_128 :=
              To_Block
                (Msg (Msg'First + 16 * Idx .. Msg'First + 16 * Idx + 15));
            C   : constant Block_128 := Xor_Block (Blk, KS);
         begin
            for K in 0 .. 15 loop
               CT (CT'First + 16 * Idx + K) := C (K);
            end loop;
         end;
      end loop;

      if Msg_Rem > 0 then
         declare
            KS : constant Block_128 :=
              TBC_Encrypt_384
                (Key, Keystream_Tweak (T, Msg_Full), Keystream_Input (Nonce));
         begin
            for K in 0 .. Msg_Rem - 1 loop
               CT (CT'First + 16 * Msg_Full + K) :=
                 Msg (Msg'First + 16 * Msg_Full + K) xor KS (K);
            end loop;
         end;
      end if;

      Tag := T;
   end Encrypt;

   procedure Decrypt (Key   : Key_256;
                      Nonce : Nonce_120;
                      AD    : Byte_Seq;
                      CT    : Byte_Seq;
                      Tag   : Tag_128;
                      Msg   : out Byte_Seq;
                      Ok    : out Boolean)
   is
      use Deoxysii.Mode;
      use Deoxysii.TBC;

      Auth : Tag_128 := (others => 0);
      Tp   : Tag_128;

      --  See Encrypt for why these route through Long_Long_Integer.
      AD_Full : constant Natural :=
        Natural (Long_Long_Integer (AD'Length) / 16);
      AD_Rem  : constant Natural :=
        Natural (Long_Long_Integer (AD'Length) mod 16);
      CT_Full : constant Natural :=
        Natural (Long_Long_Integer (CT'Length) / 16);
      CT_Rem  : constant Natural :=
        Natural (Long_Long_Integer (CT'Length) mod 16);
   begin
      Msg := (others => 0);

      --  Phase 1: authenticate AD (identical to Encrypt, M-3).
      for I in 1 .. AD_Full loop
         declare
            Idx : constant Natural := I - 1;
            Blk : constant Block_128 :=
              To_Block (AD (AD'First + 16 * Idx .. AD'First + 16 * Idx + 15));
            E   : constant Block_128 :=
              TBC_Encrypt_384 (Key, Counter_Tweak (Prefix_AD_Full, Idx), Blk);
         begin
            Auth := Xor_Tag (Auth, E);
         end;
      end loop;

      if AD_Rem > 0 then
         declare
            Blk : constant Block_128 :=
              Pad10 (AD (AD'First + 16 * AD_Full .. AD'Last));
            E   : constant Block_128 :=
              TBC_Encrypt_384
                (Key, Counter_Tweak (Prefix_AD_Last, AD_Full), Blk);
         begin
            Auth := Xor_Tag (Auth, E);
         end;
      end if;

      Tp := Auth;

      --  Phase 2: forward-only recovery (M-4). Regenerate the keystream
      --  from the RECEIVED tag, recover Msg, and re-accumulate the running
      --  tag over the recovered plaintext. Never calls a TBC inverse.
      for J in 1 .. CT_Full loop
         declare
            Idx  : constant Natural := J - 1;
            KS   : constant Block_128 :=
              TBC_Encrypt_384
                (Key, Keystream_Tweak (Tag, Idx), Keystream_Input (Nonce));
            CBlk : constant Block_128 :=
              To_Block
                (CT (CT'First + 16 * Idx .. CT'First + 16 * Idx + 15));
            MBlk : constant Block_128 := Xor_Block (CBlk, KS);
            E    : constant Block_128 :=
              TBC_Encrypt_384 (Key, Counter_Tweak (Prefix_Msg_Full, Idx), MBlk);
         begin
            for K in 0 .. 15 loop
               Msg (Msg'First + 16 * Idx + K) := MBlk (K);
            end loop;
            Tp := Xor_Tag (Tp, E);
         end;
      end loop;

      if CT_Rem > 0 then
         declare
            KS : constant Block_128 :=
              TBC_Encrypt_384
                (Key, Keystream_Tweak (Tag, CT_Full), Keystream_Input (Nonce));
         begin
            for K in 0 .. CT_Rem - 1 loop
               Msg (Msg'First + 16 * CT_Full + K) :=
                 CT (CT'First + 16 * CT_Full + K) xor KS (K);
            end loop;
         end;
         declare
            Blk : constant Block_128 :=
              Pad10 (Msg (Msg'First + 16 * CT_Full .. Msg'Last));
            E   : constant Block_128 :=
              TBC_Encrypt_384
                (Key, Counter_Tweak (Prefix_Msg_Last, CT_Full), Blk);
         begin
            Tp := Xor_Tag (Tp, E);
         end;
      end if;

      Tp := Tag_128
              (TBC_Encrypt_384 (Key, Finalize_Tweak (Nonce), Block_128 (Tp)));

      --  Verify, fail-closed (M-4/M-5): constant-time compare; on mismatch
      --  the ONLY operation on Msg is the zeroizing write.
      if Deoxysii.CT.CT_Equal (Tp, Tag) then
         Ok := True;
      else
         Deoxysii.CT.Zeroize (Msg);
         Ok := False;
      end if;
   end Decrypt;

end Deoxysii;
