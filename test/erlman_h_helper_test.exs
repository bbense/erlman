defmodule ErlmanH_HelperTest do
  use ExUnit.Case

  test "Can find get_cookie" do
    {status , _docstring} = Erlman.H_Helper.documentation(:erlang, :get_cookie)
    assert status == :found
  end

  test "Format :timer.tc correctly" do
    {status , docstring} = Erlman.H_Helper.documentation(:timer, :tc, 3)
    assert status == :found
    [{_header,body_doc}] = docstring
    refute String.contains?(body_doc, ["\\fI","\\fR"])
  end

   test "Can find user" do
    {status , _docstring} = Erlman.H_Helper.documentation(:user)
    assert status == :found
  end

end
