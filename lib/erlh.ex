defmodule Erlh do
  @moduledoc """
  A stub version of iex h command for testing
  the Erlman.get_docs functions

  """
  require Erlman
  
  # There needs to be a whole lot of clean up wrt whether module is an atom or string. 
  # Most of the standard functions are documented in :erlang, Try prepending :erlang if 
  # Module not found? 
  def h(elixir_erlang_ref) do
    search = Erlman.convert(elixir_erlang_ref)
    case Enum.count(search) do
      1 -> docs = Erlman.get_docs(elixir_erlang_ref, :moduledoc) 
           if(docs, do: print_doc(elixir_erlang_ref, elem(docs, 1)), else: IO.puts "#{elixir_erlang_ref} not found\n")
      2 -> docs = Erlman.get_docs(":"<>List.first(search), :docs)
           if(docs, do: find_andprint_fdoc(search, docs), else: IO.puts "#{elixir_erlang_ref} not found\n")
    end
  end 

  def find_andprint_fdoc(search, doc_list ) do
    [module,fname] = search
    arity = Erlman.find_arity(module,fname)
    arity |> Enum.map(fn(a) -> print_func(doc_list,search,a) end )
  end 

  def print_func(doc_list, search, arity) do
    [module, fname] = search
    doc_tup = List.keyfind(doc_list, { String.to_atom(fname), arity }, 0 )
    { _tup, _line, _kind, _sig, info } = doc_tup
    print_doc("def :#{module}.#{fname}",info)
  end 

  defp print_doc(heading, doc) do
    doc = doc || ""
    if opts = IEx.Config.ansi_docs do
      IO.ANSI.Docs.print_heading(heading, opts)
      IO.ANSI.Docs.print(doc, opts)
    else
      IO.puts "* #{heading}\n"
      IO.puts doc
    end
  end
  
end
