defmodule ErlmanNroff do
  @moduledoc """
  This module is meant to parse just enough nroff to convert the erlang man pages
  to markdown format compatible with Code.get_docs in elixir. It relies heavily 
  on the fact that Erlang man pages have a standard conversion from the original
  XML version of the documentation. 
  """
	@man_macros ~W(.TH .SH .SS .TP .LP .RS .RE .nf .fi .br .B )


  # Need to change this to a reduce, macro functions should return line and prepend for next line. 
	def to_markdown(string) do
		String.split(string,"\n") |>
		Enum.map_join(fn(line) -> translate(line) end) 
	end

	def find(string,function) do
		function
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
  Match up function docs to elements in functions returned
  from module:module_info
  """
  def parse_functions(funcs,nroff_funcs) do
    Enum.map(funcs, fn(x) -> { Atom.to_string(elem(x,0)), elem(x,1) } end ) |>


  end
	
	def swap_inline(line) do 
		newline = String.replace(line,"\\fI","`") |> 
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