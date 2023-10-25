all: delete
	ls
	@echo "# Type declarations:"
	cat miniooDeclarations.ml
	ocamlc -c miniooDeclarations.ml

	@echo "#Abstract Syntax Tree:"
	cat ast.ml
	ocamlc -c ast.ml

	@echo "# Lexer specification:"
	cat lexer.mll
	ocamllex lexer.mll
	ls
	@echo "# Parser specification:"
	cat syntax.mly
	@echo "# Parser creation:"
	menhir syntax.mly
	ls
	@echo "# types of values returned by lexems:"
	cat Syntax.mli
	@echo "# Compilation of the lexer and parser:"
	ocamlc -c Syntax.mli
	ocamlc -c lexer.ml
	ocamlc -c Syntax.ml
	@echo "# Specification of MiniOO"
	cat minioo.ml 
	@echo "# compilation of the MiniOO"
	ocamlc -c minioo.ml
	@echo "# linking of the lexer, parser & MiniOO"
	ocamlc -o minioo ast.cmo miniooDeclarations.cmo lexer.cmo Syntax.cmo minioo.cmo
	ls
	@echo "# using MiniOO"
	@echo "Test 1:"
	@echo "{var x; x = 1; var y; y = 1}" | ./minioo
	
	@echo "Test 2:"
	@echo "{var x; {var y; {var z; z = x - 1; z = 1}; z = 1}; y = z - 1}" | ./minioo

	@echo "Test 2': (correct later)"
	@echo "{var x; {var y; {var z; z = x - 1; z = 1}; y = 1}; y = z - 1}" | ./minioo
	
	@echo "Test 3:"
	@echo "var x; var y; var z; z = 1 - y - z - x" | ./minioo
	
	@echo "Test 4:"
	@echo "{var z; skip; var z; z = 1 - z}" | ./minioo
	
	@echo "Test 5:"
	@echo "var a; a = proc y: y = y - 1" | ./minioo

	@echo "Test 6:"
	@echo "var x; {x = 1; {if x == 1 x = 2 else x = 3; x = 10}}" | ./minioo
	
	@echo "Test 7:"
	@echo "{var x; x = 1; var y; y = null}" | ./minioo

	@echo "Test 8:"
	@echo "var a; {a = proc y: y = y - 1; a = 1}" | ./minioo

	@echo "Test 9:"
	@echo "var x; if true x = 1 else x = 3" | ./minioo

	@echo "Test 10:"
	@echo "var x; x.@p = 1" | ./minioo

	@echo "Test 11:"
	@echo "var a; {a = proc y: y = y - 1; a(5)}" | ./minioo

	@echo "Test 12:"
	@echo "1-1(1-1)" | ./minioo

	@echo "Test 13:"
	@echo "var x; {x = 1 ||| {if x == 1 x = 2 else x = 3; x = 10}}" | ./minioo

	@echo "Test 14:"
	@echo "var x; {atom(x = 1) ||| {if x == 1 x = 2 else x = 3; x = 10}}" | ./minioo

	@echo "Test 15:"
	@echo "var x; malloc(x)" | ./minioo

	@echo "# the end."

delete:
	/bin/rm -f minioo *.cmi *.cmo lexer.cmi lexer.cmo lexer.ml syntax.cmi syntax.cmo syntax.ml syntax.mli syntax.conflicts makefile~
