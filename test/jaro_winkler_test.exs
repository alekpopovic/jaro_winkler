defmodule JaroWinklerTest do
  use ExUnit.Case
  doctest JaroWinkler

  describe "exec/2" do
    test "returns 1.0 for identical strings" do
      assert JaroWinkler.exec("same", "same") == 1.0
      assert JaroWinkler.exec("hello", "hello") == 1.0
      assert JaroWinkler.exec("", "") == 1.0
      assert JaroWinkler.exec("a", "a") == 1.0
    end

    test "returns 0.0 when one string is empty" do
      assert JaroWinkler.exec("", "words") == 0.0
      assert JaroWinkler.exec("words", "") == 0.0
      assert JaroWinkler.exec("", "a") == 0.0
      assert JaroWinkler.exec("a", "") == 0.0
    end

    test "calculates correct distance for example cases" do
      assert JaroWinkler.exec("martha", "marhta") == 0.9611111111111111
    end

    test "handles completely different strings" do
      distance = JaroWinkler.exec("abc", "xyz")
      assert distance == 0.0
    end

    test "handles single character strings" do
      assert JaroWinkler.exec("a", "b") == 0.0
      assert JaroWinkler.exec("a", "a") == 1.0
    end

    test "handles strings with partial matches" do
      distance = JaroWinkler.exec("hello", "hallo")
      assert distance > 0.0 and distance < 1.0
    end

    test "handles different length strings" do
      distance1 = JaroWinkler.exec("short", "much longer string")
      distance2 = JaroWinkler.exec("much longer string", "short")
      assert distance1 == distance2
      assert distance1 >= 0.0 and distance1 <= 1.0
    end

    test "handles case sensitivity" do
      distance = JaroWinkler.exec("Hello", "hello")
      assert distance > 0.0 and distance < 1.0
    end

    test "handles strings with repeated characters" do
      distance = JaroWinkler.exec("aaa", "aab")
      assert distance > 0.0 and distance < 1.0
    end

    test "handles longer strings with complex patterns" do
      distance = JaroWinkler.exec("kitten", "sitting")
      assert distance > 0.0 and distance < 1.0
    end

    test "handles strings with special characters" do
      distance = JaroWinkler.exec("hello!", "hello?")
      assert distance > 0.0 and distance < 1.0
    end

    test "result is always between 0.0 and 1.0" do
      test_pairs = [
        {"martha", "marhta"},
        {"hello", "world"},
        {"test", "testing"},
        {"abc", "def"},
        {"same", "same"},
        {"", "empty"},
        {"long string here", "another long string"}
      ]

      for {str1, str2} <- test_pairs do
        distance = JaroWinkler.exec(str1, str2)
        assert distance >= 0.0 and distance <= 1.0,
               "Distance #{distance} for '#{str1}' and '#{str2}' is not between 0.0 and 1.0"
      end
    end

    test "is symmetric" do
      test_pairs = [
        {"martha", "marhta"},
        {"hello", "world"},
        {"test", "testing"},
        {"short", "much longer"},
        {"", "something"}
      ]

      for {str1, str2} <- test_pairs do
        distance1 = JaroWinkler.exec(str1, str2)
        distance2 = JaroWinkler.exec(str2, str1)
        assert distance1 == distance2,
               "Distance not symmetric for '#{str1}' and '#{str2}': #{distance1} != #{distance2}"
      end
    end

    test "handles strings longer than 128 characters" do
      long_str1 = String.duplicate("a", 150)
      long_str2 = String.duplicate("b", 150)
      long_str3 = long_str1

      distance1 = JaroWinkler.exec(long_str1, long_str2)
      distance2 = JaroWinkler.exec(long_str1, long_str3)

      assert distance1 == 0.0
      assert distance2 == 1.0
    end
  end
end
