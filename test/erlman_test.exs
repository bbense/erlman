defmodule ErlmanTest do
  use ExUnit.Case

  test "Can find mandir " do
    assert Erlman.manpath == "/usr/local/Cellar/erlang/17.5/lib/erlang/man"
  end

  test "Can find manpage" do
  	assert Erlman.manpage(":crypto") == {:ok ,"/usr/local/Cellar/erlang/17.5/lib/erlang/man/man3/crypto.3" }
  end 

  test "Return file not found" do 
    assert Erlman.manpage(":foobar") == {:error, :enoent}
  end 

  test "Can read module for function into string" do
  	assert  File.read!("/usr/local/Cellar/erlang/17.5/lib/erlang/man/man3/crypto.3") == Erlman.manstring(":crypto.hash")
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


end
