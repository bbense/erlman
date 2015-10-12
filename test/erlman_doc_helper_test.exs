defmodule ErlmanDocHelperTest do
  use ExUnit.Case

  test "Can find get_cookie" do
    {status , _docstring} = Erlman.DocHelper.documentation(:erlang, :get_cookie)
    assert status == :found
  end

  test "Format :timer.tc correctly" do
    {status , docstring} = Erlman.DocHelper.documentation(:timer, :tc, 3)
    assert status == :found
    [{_header,body_doc}] = docstring
    refute String.contains?(body_doc, ["\\fI","\\fR"])
  end

  test "Can find user" do
    {status , _docstring} = Erlman.DocHelper.documentation(:user)
    assert status == :found
  end

  test "Can find rpc.info" do
    {status , _docstring} = Erlman.DocHelper.documentation(:rpc,:pinfo)
    assert status == :found
  end

end
