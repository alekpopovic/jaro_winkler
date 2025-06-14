
defmodule JaroWinkler do
  @moduledoc """
  `JaroWinkler` is a module for calculating Jaro-Winkler distance of two strings.

  ## Examples

      iex> JaroWinkler.exec("martha", "marhta")
      0.9611111111111111

      iex> JaroWinkler.exec("", "words")
      0.0

      iex> JaroWinkler.exec("same", "same")
      1.0

  """

  import Bitwise

  # DataWrapper implementation using tagged tuples
  defp build_data_wrapper(len) when len <= 128 do
    {:bitwise, 0}
  end

  defp build_data_wrapper(len) do
    internal = List.duplicate(false, len)
    {:vec, internal}
  end

  defp get_data_wrapper({:vec, v}, idx) do
    Enum.at(v, idx)
  end

  defp get_data_wrapper({:bitwise, v1}, idx) do
    (v1 >>> idx &&& 1) == 1
  end

  defp set_true_data_wrapper({:vec, v}, idx) do
    {:vec, List.replace_at(v, idx, true)}
  end

  defp set_true_data_wrapper({:bitwise, v1}, idx) do
    {:bitwise, v1 ||| (1 <<< idx)}
  end

  @doc """
  Calculates the Jaro-Winkler distance of two strings.

  The return value is between 0.0 and 1.0, where 1.0 means the strings are equal.
  """
  @spec exec(String.t(), String.t()) :: float()
  def exec(left_, right_) do
    llen = String.length(left_)
    rlen = String.length(right_)

    {left, right, s1_len, s2_len} =
      if llen < rlen do
        {right_, left_, rlen, llen}
      else
        {left_, right_, llen, rlen}
      end

    case {s1_len, s2_len} do
      {0, 0} -> 1.0
      {0, _} -> 0.0
      {_, 0} -> 0.0
      _ ->
        if left == right do
          1.0
        else
          calculate(left, right, s1_len, s2_len)
        end
    end
  end

  defp calculate(left, right, s1_len, s2_len) do
    range = matching_distance(s1_len, s2_len)
    s1m = build_data_wrapper(s1_len)
    s2m = build_data_wrapper(s2_len)
    left_as_bytes = :binary.bin_to_list(left)
    right_as_bytes = :binary.bin_to_list(right)

    {s1m_final, s2m_final, matching} =
      find_matches(right_as_bytes, left_as_bytes, s1m, s2m, range, s1_len, s2_len, 0, 0.0)

    if matching == 0.0 do
      0.0
    else
      transpositions = count_transpositions(right_as_bytes, left_as_bytes, s2m_final, s1m_final, s1_len, s2_len, 0, 0, 0.0)
      transpositions = Float.ceil(transpositions / 2.0)

      jaro = (matching / s1_len + matching / s2_len + (matching - transpositions) / matching) / 3.0

      prefix_length =
        left_as_bytes
        |> Enum.zip(right_as_bytes)
        |> Enum.take(4)
        |> Enum.take_while(fn {l, r} -> l == r end)
        |> length()
        |> Kernel.*(1.0)

      jaro + prefix_length * 0.1 * (1.0 - jaro)
    end
  end

  defp find_matches(right_as_bytes, left_as_bytes, s1m, s2m, range, s1_len, s2_len, i, matching) when i < s2_len do
    j_start = max(i - range, 0)
    l = min(i + range + 1, s1_len)

    {s1m_updated, s2m_updated, matching_updated} =
      find_match_in_range(right_as_bytes, left_as_bytes, s1m, s2m, i, j_start, l, matching)

    find_matches(right_as_bytes, left_as_bytes, s1m_updated, s2m_updated, range, s1_len, s2_len, i + 1, matching_updated)
  end

  defp find_matches(_right_as_bytes, _left_as_bytes, s1m, s2m, _range, _s1_len, _s2_len, _i, matching) do
    {s1m, s2m, matching}
  end

  defp find_match_in_range(right_as_bytes, left_as_bytes, s1m, s2m, i, j, l, matching) when j < l do
    if Enum.at(right_as_bytes, i) == Enum.at(left_as_bytes, j) and not get_data_wrapper(s1m, j) do
      s1m_updated = set_true_data_wrapper(s1m, j)
      s2m_updated = set_true_data_wrapper(s2m, i)
      {s1m_updated, s2m_updated, matching + 1.0}
    else
      find_match_in_range(right_as_bytes, left_as_bytes, s1m, s2m, i, j + 1, l, matching)
    end
  end

  defp find_match_in_range(_right_as_bytes, _left_as_bytes, s1m, s2m, _i, _j, _l, matching) do
    {s1m, s2m, matching}
  end

  defp count_transpositions(right_as_bytes, left_as_bytes, s2m, s1m, s1_len, s2_len, i, l, transpositions) when i < s2_len - 1 do
    if get_data_wrapper(s2m, i) do
      j = find_next_match(s1m, l, s1_len)
      new_l = j + 1

      new_transpositions =
        if Enum.at(right_as_bytes, i) != Enum.at(left_as_bytes, j) do
          transpositions + 1.0
        else
          transpositions
        end

      count_transpositions(right_as_bytes, left_as_bytes, s2m, s1m, s1_len, s2_len, i + 1, new_l, new_transpositions)
    else
      count_transpositions(right_as_bytes, left_as_bytes, s2m, s1m, s1_len, s2_len, i + 1, l, transpositions)
    end
  end

  defp count_transpositions(_right_as_bytes, _left_as_bytes, _s2m, _s1m, _s1_len, _s2_len, _i, _l, transpositions) do
    transpositions
  end

  defp find_next_match(s1m, j, s1_len) when j < s1_len do
    if get_data_wrapper(s1m, j) do
      j
    else
      find_next_match(s1m, j + 1, s1_len)
    end
  end

  defp find_next_match(_s1m, j, _s1_len), do: j

  defp matching_distance(s1_len, s2_len) do
    max_val = max(s1_len, s2_len)
    trunc(Float.floor(max_val / 2.0) - 1.0)
  end
end
