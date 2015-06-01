defmodule Erlman do

  require Nroff

  def manpath do
	 "/usr/local/Cellar/erlang/17.5/lib/erlang/man"
  end

  @doc """
  Expects the Elixir version of the erlang function or module name
  and returns the path to it's man page.

  ## Example

        iex> {:ok,path} = Erlman.manpage(":crypto.hash")
        {:ok, "/usr/local/Cellar/erlang/17.5/lib/erlang/man/man3/crypto.3" }

  """
  def manpage(elixir_erlang_ref) do
    target = convert(elixir_erlang_ref) |> Enum.at(0)
    manfile = mandirs(Erlman.manpath) |>
              Enum.find_value(fn(dir) -> has_man?(dir,target) end)
    case manfile do
      nil -> {:error, :enoent}
       _  -> {:ok, manfile}
    end
  end

  def manstring(function_name) do 
    case manpage(function_name) do
      {:ok, manfile}    -> File.read!(manfile)
      {:error, :enoent} -> :nofile
    end
  end

  def module_doc(elixir_erlang_ref) do
    doc = manstring(elixir_erlang_ref)
    Nroff.to_markdown(doc)
  end

  def function_doc(elixir_erlang_ref) do
    function = convert(elixir_erlang_ref) |> Enum.at(1)
    doc = manstring(elixir_erlang_ref)
    fdoc = Nroff.find(doc,function)
    Nroff.to_markdown(doc)
  end 

  defp mandirs(path) do
    File.ls!(path) |> 
    Enum.filter_map(fn(entry) -> Regex.match?(~r/^man[1-8]/, entry) end , fn(entry) -> Path.join(path,entry) end ) |>
    Enum.filter(fn(entry) -> File.dir?(entry) end)
  end

  defp convert(elixir_erlang_ref) do 
    String.lstrip(elixir_erlang_ref, ?: ) |>
    String.split(".")
  end

  defp has_man?(dir,target) do
    manfile = page(dir,target)
    case File.exists?(manfile) do
      true -> manfile
      _    -> false
    end
  end 

  defp page(dir,target) do
    section = target<>"."<>String.last(dir)
    Path.join(dir,section)
  end 
  
end
