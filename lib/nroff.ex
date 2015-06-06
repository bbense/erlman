defmodule ErlmanNroff do
  @moduledoc """
  This module is meant to parse just enough nroff to convert the erlang man pages
  to markdown format compatible with Code.get_docs in elixir. It relies heavily 
  on the fact that Erlang man pages have a standard conversion from the original
  XML version of the documentation. 
  """
	@man_macros ~W(.TH .SH .SS .TP .LP .RS .RE .nf .fi .br .B )

  # This is serious cheating, we should really implement the nroff state machine. 
  # But since that is mostly about indentation, see how far we can get. 
	def to_markdown(string) do
		String.split(string,"\n") |>
		Enum.map_join(fn(line) -> translate(line) end) 
	end

  @doc """
  Split string into list of function strings. 
  We assume erlang nroff that has this format. 

      .B
      function(arg1, arg2) -> ResultType
  """
	def list_functions(string) do
    String.split(string,"\n.B\n") 
	end 

	def translate(line) do
		case String.starts_with?(line, @man_macros) do
			true  -> swap_macro(line)
			false -> swap_inline(line)
		end 
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
    fkey = match_function(nroff_docstring,functions)
    signature = get_signature(nroff_docstring,Dict.get(functions,fkey))
    {fkey, Dict.get(functions,fkey), 1, :def, signature, to_markdown(nroff_docstring) }
  end

  def match_function(nroff_dstring, functions) do 
    found = Dict.keys(functions) |> 
            Enum.map(fn(x) -> Atom.to_string(x) end ) |> 
            Enum.find(fn(fname) -> String.starts_with(nroff_dstring,fname) end )
    case found do 
      nil -> nil
      _   -> String.to_atom(found)
    end 
  end 

  def get_signature(nroff_docstring,arity) do
    0..arity |> Enum.map(fn(x) -> { "arg"<>Integer.to_string(x) , [], nil } end )
  end 
	
	def swap_inline(line) do 
		newline = String.replace(line,"\\fI","`") |> 
              String.replace(line,"\\fB","`") |> 
		          String.replace("\\fR","`") |>
		          String.replace("\\&","") 
    newline<>"\n"
	end

	def get_macro(line) do
		[ macro | line ] = String.split(line,~r/\s/, parts: 2 )
		case line do 
			[] -> {macro, "" }
      _  -> {macro, Enum.at(line,0)}
    end 
	end 

	def swap_macro(line) do
		{ macro, line } = get_macro(line)
		swap_macro(macro,line)
	end 

	def swap_macro(".TH", line) do
		"# "<>line<>"\n"
	end

	def swap_macro(".SH", line) do
		"## "<>line<>"\n"
	end

  def swap_macro(".SS", line) do
    "### "<>line<>"\n" 
  end

  def swap_macro(".TP", line) do
    line 
  end

  def swap_macro(".LP", line) do
    line 
  end

  @doc """
    Indent count.to_i spaces
  """
  def swap_macro(".RS", count) do
    ""
  end

  def swap_macro(".RE", line) do
    line 
  end

  @doc """
    Turn off text fill
  """
  def swap_macro(".nf", line) do
    line 
  end

	def swap_macro(".fi", line) do
    line 
  end

  def swap_macro(".B", line) do
    line 
  end
 
  def swap_macro(".br", line) do
    "\n"<>line 
  end

end