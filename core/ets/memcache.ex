# Copyright(c) 2015-2018 ACCESS CO., LTD. All rights reserved.

use Croma

defmodule AntikytheraCore.Ets.Memcache do
  alias Croma.Result, as: R
  alias Antikythera.Time
  alias Antikythera.ExecutorPool.Id, as: EPoolId

  defun init() :: :ok do
    AntikytheraCore.Ets.create_read_optimized_table(table_name())
  end

  defun table_name() :: atom do
    :antikythera_memcache
  end

  defun read(key :: term, epool_id :: v[EPoolId.t]) :: R.t(term, :not_found) do
    case :ets.lookup(table_name(), {epool_id, key}) do
      []        -> {:error, :not_found}
      [element] -> {:ok   , element}
    end
  end

  defun write(key :: term, value :: term, expire_at :: v[Time.t], prob_expire_at :: v[Time.t], epool_id :: v[EPoolId.t]) :: :ok do
    :ets.insert(table_name(), {{epool_id, key}, expire_at, prob_expire_at, value})
    :ok
  end

  defun delete(key :: term, epool_id :: v[EPoolId.t]) :: :ok do
    :ets.delete(table_name(), {epool_id, key})
    :ok
  end
end
