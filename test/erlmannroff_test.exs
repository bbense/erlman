defmodule ErlmanNroffTest do
  use ExUnit.Case

  test "Can swap inline " do
    assert ErlmanNroff.swap_inline("\\fB") == "`"
  end

  

end
