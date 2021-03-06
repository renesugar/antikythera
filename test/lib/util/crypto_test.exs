# Copyright(c) 2015-2018 ACCESS CO., LTD. All rights reserved.

defmodule Antikythera.CryptoTest do
  use Croma.TestCase

  test "secure_compare/2" do
    assert Crypto.secure_compare("", "")
    assert Crypto.secure_compare("a", "a")
    refute Crypto.secure_compare("", "a")
    refute Crypto.secure_compare("a", "")
    refute Crypto.secure_compare("a", "b")
  end
end

defmodule Antikythera.Crypto.AesTest do
  use Croma.TestCase
  use ExUnitProperties

  property "ctr128_encrypt and decrypt with MD5" do
    check all {data, pw} <- {binary(), binary()} do
      assert Aes.ctr128_encrypt(data, pw) |> Aes.ctr128_decrypt(pw) == {:ok, data}
    end
  end

  property "ctr128_encrypt and decrypt with pbkdf2" do
    check all {data, pw, salt} <- {binary(), binary(), binary()} do
      kdf = fn pw ->
        {:ok, k} = :pbkdf2.pbkdf2(:sha, pw, salt, 100, 16)
        k
      end
      assert Aes.ctr128_encrypt(data, pw, kdf) |> Aes.ctr128_decrypt(pw, kdf) == {:ok, data}
    end
  end

  property "gcm128_encrypt and decrypt with MD5" do
    check all {data, pw} <- {binary(), binary()} do
      assert Aes.gcm128_encrypt(data, pw) |> Aes.gcm128_decrypt(pw) == {:ok, data}
    end
  end

  property "gcm128_encrypt and decrypt with pbkdf2" do
    check all {data, pw, salt} <- {binary(), binary(), binary()} do
      kdf = fn pw ->
        {:ok, k} = :pbkdf2.pbkdf2(:sha, pw, salt, 100, 16)
        k
      end
      assert Aes.gcm128_encrypt(data, pw, "aad", kdf) |> Aes.gcm128_decrypt(pw, "aad", kdf) == {:ok, data}
    end
  end

  property "gcm128_decrypt should return error for modified data" do
    check all {data, pw} <- {binary(), binary()} do
      enc = Aes.gcm128_encrypt(data, pw, "aad")
      assert Aes.gcm128_decrypt(enc <> "a", pw       , "aad"          ) == {:error, :decryption_failed}
      assert Aes.gcm128_decrypt(enc       , pw <> "a", "aad"          ) == {:error, :decryption_failed}
      assert Aes.gcm128_decrypt(enc       , pw       , "incorrect_aad") == {:error, :decryption_failed}
    end
  end
end
