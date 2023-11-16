all: delete
	ls
	@echo "#Abstract Syntax Tree:"
	cat ast.ml
	ocamlc -c ast.ml

	@echo "#Static Checker:"
	cat check.ml
	ocamlc -c check.ml

	@echo "#Semantic Domains:"
	cat data.ml
	ocamlc -c data.ml

	@echo "# Type declarations:"
	cat miniooDeclarations.ml
	ocamlc -c miniooDeclarations.ml

	@echo "#Operational semantics:"
	cat eval.ml
	ocamlc -c eval.ml

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
	ocamlc -o minioo ast.cmo check.cmo data.cmo miniooDeclarations.cmo eval.cmo lexer.cmo Syntax.cmo minioo.cmo
	ls
	
	@echo "# using MiniOO"

	@echo "Test 1:"
	@echo "var x; x = 1" | ./minioo

	@echo "Test 2:"
	@echo "var x; var y; var z; x = 5" | ./minioo

	@echo "Test 3:"
	@echo "{var x; x = 1; var y; y = 2}" | ./minioo

	@echo "Test 4:"
	@echo "var x; var y; var z; {x = 1; {y = 2; z = 3}}" | ./minioo
	
	@echo "Test 5:"
	@echo "{var x; {var y; {var z; z = x - 1; z = 1}; z = 1}; y = z - 1}" | ./minioo

	@echo "Test 3': (correct later)"
	@echo "{var x; {var y; {var z; z = x - 1; z = 1}; y = 1}; y = z - 1}" | ./minioo
	
	@echo "Test 4:"
	@echo "var x; var y; var z; z = 1 - y - z - x" | ./minioo
	
	@echo "Test 5:"
	@echo "{var z; skip; var z; z = 1 - z}" | ./minioo
	
	@echo "Test 6:"
	@echo "var a; a = proc y: y = y - 1" | ./minioo

	@echo "Test 7:"
	@echo "var x; {x = 1; {if x == 1 x = 2 else x = 3; x = 10}}" | ./minioo
	
	@echo "Test 8:"
	@echo "{var x; x = 1; var y; y = null}" | ./minioo

	@echo "Test 9:"
	@echo "var a; {a = proc y: y = y - 1; a = 1}" | ./minioo

	@echo "Test 10:"
	@echo "var x; if true x = 1 else x = 3" | ./minioo

	@echo "Test 11:"
	@echo "var x; x.@p = 1" | ./minioo

	@echo "Test 12:"
	@echo "var a; {a = proc y: y = y - 1; a(5)}" | ./minioo

	@echo "Test 13:"
	@echo "1-1(1-1)" | ./minioo

	@echo "Test 14:"
	@echo "var x; {x = 1 ||| {if x == 1 x = 2 else x = 3; x = 10}}" | ./minioo

	@echo "Test 15:"
	@echo "var x; {atom(x = 1) ||| {if x == 1 x = 2 else x = 3; x = 10}}" | ./minioo

	@echo "Test 16:"
	@echo "var x; malloc(x)" | ./minioo

	@echo "Test 17:"
	@echo "var x; y = 1" | ./minioo

	@echo "Test 18:"
	@echo "var x;{x = 1; var y; x = a - 1}" | ./minioo

	@echo "Test 19:"
	@echo "var x; malloc(y)" | ./minioo

	@echo "Test 20:"
	@echo "var x; {var a; a = 1; {x = 1; if x == 1 {x = 1; malloc(b)} else x = 3}}" | ./minioo

	@echo "Test 21:"
	@echo "var a; {a = proc y: z = y - 1; a(5)}" | ./minioo

	@echo "Test 22:"
	@echo "var p; {p = proc y:if y < 1 p = 1 else p(y - 1); p(1)}" | ./minioo
	
	@echo "# the end."

delete:
	/bin/rm -f minioo *.cmi *.cmo lexer.cmi lexer.cmo lexer.ml syntax.cmi syntax.cmo syntax.ml syntax.mli syntax.conflicts makefile~
