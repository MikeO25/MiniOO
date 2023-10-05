all: delete
	ls
	@echo "# Type declarations:"
	cat miniooDeclarations.ml
	ocamlc -c miniooDeclarations.ml
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
	ocamlc -o minioo miniooDeclarations.cmo lexer.cmo Syntax.cmo minioo.cmo
	ls
	@echo "# using MiniOO"
	@echo "Test 1:"
	@echo "var x; x = 1; var y; y = 1" | ./minioo
	
	@echo "Test 2:"
	@echo "var x; {var y; {var z; z = x - 1 }}; y = z - 1" | ./minioo
	
	@echo "Test 3:"
	@echo "var x; var y; var z; z = 1 - y - z - x" | ./minioo
	
	@echo "Test 4:"
	@echo "var z; skip; var z; z = 1 - z" | ./minioo
	
	@echo "Test 5:"
	@echo "var a; a = proc y: y = y - 1;" | ./minioo
	
	@echo "Test 6:"
	@echo "var a; a = proc y: y = y - 1; a = 1" | ./minioo
	@echo "# the end."

delete:
	/bin/rm -f minioo *.cmi *.cmo lexer.cmi lexer.cmo lexer.ml syntax.cmi syntax.cmo syntax.ml syntax.mli makefile~
