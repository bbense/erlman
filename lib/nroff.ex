defmodule Nroff do

	@man_macros ~W(.TH .SH .SS .TP .LP .RS .RE .nf .fi .br .B )

	def to_markdown(string) do
		String.split(string,"\n") |>
		Enum.map_join("\n",fn(line) -> translate(line) end) 
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
	
	def swap_inline(line) do 
		String.replace(line,"\\fI","`") |> 
		String.replace("\\fR","`") |>
		String.replace("\\&","")
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
		"# "<>line 
	end

	def swap_macro(".SH", line) do
		"## "<>line 
	end

  def swap_macro(".SS", line) do
    "### "<>line 
  end

  def swap_macro(".TP", line) do
    line 
  end

  def swap_macro(".LP", line) do
    line 
  end

  def swap_macro(".RS", line) do
    line 
  end

  def swap_macro(".RE", line) do
    line 
  end

  def swap_macro(".nf", line) do
    "> "<>line 
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