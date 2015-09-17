defmodule ErlmanH_HelperTest do
  use ExUnit.Case

  test "Can find get_cookie" do
   {status , _docstring} = Erlman.H_Helper.documentation(:erlang, :get_cookie)
   assert status == :found
  end



end
