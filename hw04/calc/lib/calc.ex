defmodule Calc do

@moduledoc """
Provides a String Expression Calculator
##  Example:
    > 1 + 2
    3
    > 5 * 7
    35
    > (1 - 1)
    0

"""
@doc """
Requests mathematical expression as input and passes them to eval()
"""
  def main() do
     IO.gets("> ")|> eval
    main()
  end

@doc """
splits the expression into a list and passes list to eval helper
"""
  def eval(exp) do
    expList = exp
              |> String.replace("(", "( ")
              |> String.replace(")", " )")
              |> String.split
    IO.inspect(eval_helper(expList, [], []))
  end

  @doc """
  Helps evaluate the given expression
  """
  def eval_helper([], [], opndStack) do
    opndStack |> hd
  end

  @doc """
  Helps evaluate the given expression
  """
  def eval_helper([], optStack, opndStack) do
    opr = hd(optStack)
    popOptStack = pop(optStack)
    val2 = hd(opndStack)
    popOpnStack = pop(opndStack)
    val1 = hd(popOpnStack)
    res = cal(val1, val2, opr)
          |> round
    newOpndStack = popOpnStack
                    |> pop
                    |> push(res)
    eval_helper([], popOptStack, newOpndStack)
  end

  @doc """
  Helps evaluate the given expression
  """
  def eval_helper([head | tail], optStack, opndStack) do

    firstEl = head

    cond do
      firstEl == "+" or firstEl == "-" or firstEl == "*" or firstEl == "/" ->
        oprHandler(tail, optStack, opndStack, firstEl)
      firstEl == "(" ->
        newOptStack = push(optStack, firstEl)
        eval_helper(tail, newOptStack, opndStack)
      firstEl == ")" ->
        oprHandler(tail, optStack, opndStack, firstEl)
      true ->
        opnd = String.to_integer(firstEl)
        newOpndStack = push(opndStack, opnd)
        eval_helper(tail, optStack, newOpndStack)

    end
  end

  def oprHandler(exp, [], opndStack,  opr) do
    newOptStack = push([], opr)
    eval_helper(exp, newOptStack, opndStack)
  end

  @doc """
  Handles an operator in the expression
  """
  def oprHandler(exp, optStack, opndStack, opr)do

    operator = hd(optStack)

    cond do
      operator == "(" and opr == ")" ->
        newOptStack = pop(optStack)
        eval_helper(exp, newOptStack, opndStack)
      is_grt?(operator, opr) ->
        newOptStack = pop(optStack)
        val2 = hd(opndStack)
        popOpndStack = pop(opndStack)
        val1 = hd(popOpndStack)
        res = cal(val1, val2, operator)
              |> round
        newOpndStack = pop(popOpndStack) |> push(res)
        oprHandler(exp, newOptStack, newOpndStack, opr)
      true ->
        newOptStack = push(optStack, opr)
        eval_helper(exp, newOptStack, opndStack)

    end

  end

@doc """
Calculates result of val1 op val2
"""
  def cal(val1, val2, op) do
    cond do
      op == "+" ->
        val1 + val2
        op == "-" ->
          val1 - val2
        op == "*" ->
          val1 * val2
        op == "/" ->
          val1 / val2
      end
    end

  #helper functions

  def push(lst, elem) do
    [elem | lst]
  end



  def pop(lst) do
    List.delete_at(lst, 0)
  end

@doc """
checks if precedence of opr is greater than opr2
"""
  def is_grt?(opr, opr2) do
    cond do
      opr == "(" or opr == ")" -> false
      opr2 == "(" or opr2 == ")" -> true
      opr == "/" -> true
      opr == "*" ->
        if opr2 == "/" do
          false
        else true
      end
      opr == "-" ->
        if opr2 == "/" or opr2 == "*" do
          false
        else true
        end
      opr == "+" -> false
      true -> true
    end
  end


end
