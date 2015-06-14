defmodule ErlmanNroffTest do
  use ExUnit.Case

  test "Can swap inline " do
    assert ErlmanNroff.swap_inline("\\fB") == "`\n"
  end

  test ".B makes next line sub sub header" do
   nroff = ".B\n{scope, part()}:\n"
   md    = "\n#### {scope, part()}:\n"
   assert ErlmanNroff.to_markdown(nroff) == md 
  end 
  

end
