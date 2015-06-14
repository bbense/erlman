Erlman
======

** Library for accessing erl man pages  **

This module attempts to duplicate the functionality of Code.get_docs 
by parsing the erlang man pages. The intent is to eventually extend
the iex h command to provide documenatation for at least the standard
erlang modules.

It also includes a minimal duplication of the iex h helper for testing.
This h function requires quoting the string. Some examples below: 

	Erlman.h ":os"
## os 3 \"kernel 3.2\" \"Ericsson AB\" \"Erlang Module Definition\"
### NAME os \\- Operating System Specific Functions
### DESCRIPTION

The functions in this module are operating system specific. Careless use of these functions will result in programs that will only run on a specific platform. On the other hand, with careful use these functions can be of help in enabling a program to run on most platforms.

	Erlman.h ":erlang.element"

element(N, Tuple) -> term()

Types:

N = integer() >= 1
1..tuple_size(Tuple)

Tuple = tuple()

Returns the `N`th element (numbering from 1) of `Tuple`.

    > element(2, {a, b, c}).
    b

Allowed in guard tests.