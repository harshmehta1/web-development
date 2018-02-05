defmodule CalcTest do
  use ExUnit.Case
  doctest Calc

  test "division with parenthesis as denominator" do
    assert Calc.eval("4 / (1 - 2) + 3") == -1
  end

  test "nested parenthesis with equal precedence operators" do
    assert Calc.eval("(1 + (1 - 2) * (5 - 4))") == 0
  end

  test "extreme nested parenthesis - 1" do
    assert Calc.eval("11 + (5 * 2) - (6 - (7 + 8 * (10 + (8 * 10))))") == 742
  end

  test "extreme nested parenthesis with flipped operators" do
    assert Calc.eval("11 - (5 * 2) + (6 - (7 + 8 * (10 + (8 * 10))))") == -720
  end

  test "multiple operators multiple nested parenthesis" do
    assert Calc.eval("87 * (14 - ((5 / 8) - ((11 * 28) / 19)) - (9 * 7))") == -2958
  end

  test "simple expression" do
    assert Calc.eval("24 / 2 - 9 * 10") == -78
  end

end
