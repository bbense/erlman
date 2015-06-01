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

end
