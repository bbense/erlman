defmodule Erlman do
  @moduledoc """
  This module attempts to duplicate the functionality of Code.get_docs 
  by parsing the erlang man pages. The intent is to eventually extend
  the iex h command to provide documenatation for at least the standard
  erlang modules.

  It also includes a minimal duplication of the iex h helper for testing.
  This h function requires quoting the string. 

  """
  require ErlmanNroff
  
  @doc """
  Returns path to man pages by finding erl executable and attempting
  to find the man/man3/ets.3 manpage using that directory path.
  """
  def manpath do
    start = to_string(:os.find_executable('erl'))
    finish = Path.split(start) |>
             Stream.scan(&Path.join(&2,&1)) |> 
             Enum.filter( fn(p)  -> File.exists?(Path.join([p,"man","man3","ets.3"])) end ) |>
             List.last
    Path.join(finish,"man")
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

  @doc """
  Returns the man page for function_name as a string. 
  Returns `nofile` if it cannot find the manpage for the 
  functions module.
  """
  def manstring(function_name) do 
    case manpage(function_name) do
      {:ok, manfile} -> File.read!(manfile)
      {:error, :enoent} -> :nofile
    end
  end


  @doc """
  Split string into list of function strings. 
  We assume erlang nroff that has this format. 

      .B
      function(arg1, arg2) -> ResultType
  """
  def list_functions(string) do
    # Need to merge back any elements of the Enum that do not start with the 
    # function pattern. See :binary.split\3 for example. 
    # :erlang.get_cookie is not working.
    {list, last_string} = String.split(string,"\n.B\n") |> 
                          Enum.reduce({[], ""}, fn(str, acc ) -> next_str(str,acc) end )
    list ++ [last_string]
  end 

  defp next_str(str, acc) do
    {list, dstring} = acc 
    if(is_func_doc?(str)) do
      {list ++ [dstring], str}
    else 
      {list, dstring<>"\n.SS "<>str}
    end 
  end 

  @doc """
  Return true if string starts with Erlang function pattern
  """
  def is_func_doc?(string) do
   string =~ ~r/^\w+\(.*\) \-\> /
  end

  @doc """
  Splits manpage string into Module and Function Parts. 
  """
  def split(manstring) do
    String.split(manstring,".SH EXPORTS", parts: 2)
  end

  @doc """
  Parse a function string.
  foo(arg,arg,arg) -> ResultType
  functions should be the result of :module.module_info(:exports)

  Return should look like 
   {{_function, _arity}, _line, _kind, _signature, text} 
   signature is a list of tuples of the form {:arg,[],nil}
  """
  def parse_function(nroff_docstring,functions) do
    fkey = match_function(nroff_docstring, functions)
    arity = get_arity(nroff_docstring)
    signature = get_signature(arity)
    {{fkey, arity}, 1, :def, signature, ErlmanNroff.to_markdown(".SS "<>nroff_docstring) }
  end

  @doc """
  Checks docstring against list of module function exports.
  Does not check for arity. 
  """
  def match_function(nroff_dstring, functions) do 
    found = Dict.keys(functions) |> 
            Enum.map(fn(x) -> Atom.to_string(x) end ) |> 
            Enum.find(fn(fname) -> String.starts_with?(nroff_dstring,fname) end )
    case found do 
      nil -> nil
      _   -> String.to_atom(found)
    end 
  end 

  @doc """
  Find first \(, count the number of commas until the \)
  """
  def get_arity(nroff_docstring) do
    String.codepoints(nroff_docstring) |>
    Stream.transform(false , fn(x,acc) -> 
                      case x do 
                        "("  -> {[], true }  
                        ","  -> {[0], acc }
                        ")"  -> {:halt, acc} 
                        _    -> if(acc, do: {[0], false }, else: {[], acc } )
                      end 
                     end ) |>
    Enum.count 
  end 

  @doc """
  Returns a largely bogus function signature.
  """
  def get_signature(arity) do
    0..arity |> Enum.map(fn(x) -> { "arg"<>Integer.to_string(x) , [], nil } end )
  end 

  @doc """ 
  Emulate behaviour of Code.gets_docs as far as possible.

  Returns the docs for the given module.
  The return value depends on the kind value:

  :docs - list of all docstrings attached to functions and macros using the @doc attribute
  :moduledoc - tuple {<line>, <doc>} where line is the line on which module definition starts and doc is the string attached to the module using the @moduledoc attribute
  :all - a keyword list with both :docs and :moduledoc

  """
  def get_docs(module,kind) do
    mandoc = Erlman.manstring(module)
    if mandoc == :nofile do
      nil
    else 
     funcs = function_exports(module)
     parse_docs(funcs,mandoc,kind)
    end
  end

  def parse_docs(funcs,mandoc,kind ) do
    [nroff_mod,nroff_func] = Erlman.split(mandoc)
    case kind do 
      :docs      -> get_function_docs(funcs,nroff_func)
      :moduledoc -> get_moduledoc(nroff_mod)
      :all       -> get_all_docs(funcs,mandoc)
      _          -> nil
    end
  end 

  @doc """
  Return the results of :module.module_info(:exports)
  Will raise error if :module is not loaded. 
  """
  def function_exports(module) do
    code = module<>".module_info(:exports)"
    Code.eval_string(code,[],__ENV__) |> elem(0)
  end 

  @doc """
    Return a list of tuples of the form 
    {{_function, _arity}, _line, _kind, _signature, text} 
  """
  def get_function_docs(funcs,nroff_func) do
    Erlman.list_functions(nroff_func) |>
    Enum.filter_map(fn(d_str) -> Erlman.match_function(d_str,funcs) end , 
                    fn(d_str) -> Erlman.parse_function(d_str,funcs) end )
  end

  def get_moduledoc(nroff_mod) do
    {1,ErlmanNroff.to_markdown(nroff_mod)}
  end 

  def get_all_docs(_mandocs,_funcs) do
    true
  end 

  def find_arity(module,fname) do
    function_exports(":"<>module) |>
    Enum.filter_map(fn(tup) -> elem(tup,0) == String.to_atom(fname) end, 
                    fn(tup) -> elem(tup,1) end )
  end

  defp mandirs(path) do
    File.ls!(path) |> 
    Enum.filter_map(fn(entry) -> Regex.match?(~r/^man[1-8]/, entry) end , fn(entry) -> Path.join(path,entry) end ) |>
    Enum.filter(fn(entry) -> File.dir?(entry) end)
  end

  def convert(elixir_erlang_ref) do 
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
