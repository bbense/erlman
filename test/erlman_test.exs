defmodule ErlmanTest do
  use ExUnit.Case

  test "Can find mandir " do
    assert String.ends_with? Erlman.manpath , "/man"
  end

  test "Can find manpage" do
  	{status, path } = Erlman.manpage(":crypto")
    assert status == :ok 
    assert String.ends_with? path, "man/man3/crypto.3" 
  end 

  test "Return file not found" do 
    assert Erlman.manpage(":foobar") == {:error, :enoent}
  end 

  test "Can read module for function into string" do
    {_, path } = Erlman.manpage(":crypto")
  	assert  File.read!(path) == Erlman.manstring(":crypto.hash")
  end

  test "get_arity works for 0" do 
    assert Erlman.get_arity("timestamp() -> Timestamp\n\n\n\n") == 0 
  end 

  test "get_arity works for 1" do 
    assert Erlman.get_arity("timestamp(Foo) -> Timestamp\n\n\n\n") == 1
  end 

  test "get_arity works for 2" do 
    assert Erlman.get_arity("timestamp(Foo, Bar) -> Timestamp\n\n\n\n") == 2
  end 

  # test "list_functions work when merging parts" do
  #   nroff = "\n.B\nhappy(Arg) -> Result\n Do not worry, be happy\n\.B\nSinging\nin the rain\n"
  #   md = 
  # end

end
