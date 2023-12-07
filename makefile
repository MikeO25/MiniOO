all: delete
	ls
	@echo "#Abstract Syntax Tree:"
	ocamlc -c ast.ml

	@echo "#Static Checker:"
	ocamlc -c check.ml

	@echo "#Semantic Domains:"
	ocamlc -c domains.ml

	@echo "#Helpers:"
	ocamlc -c helpers.ml

	@echo "#Operational Semantics:"
	ocamlc -c eval.ml

	@echo "# Lexer Specification:"
	ocamllex lexer.mll

	@echo "# Parser Creation:"
	menhir syntax.mly

	@echo "# Compilation of the lexer and parser:"
	ocamlc -c Syntax.mli
	ocamlc -c lexer.ml
	ocamlc -c Syntax.ml

	@echo "# compilation of the MiniOO"
	ocamlc -c minioo.ml
	@echo "# linking of the lexer, parser & MiniOO"
	ocamlc -o minioo ast.cmo check.cmo domains.cmo helpers.cmo eval.cmo lexer.cmo Syntax.cmo minioo.cmo
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
	@echo "var x; var y; var z; {x = 10; {y = 6; z = x - y}}" | ./minioo

	@echo "Test 6:"
	@echo "var x; var y; var z; {x = 10; {y = 6; if y < x then z = 3 else z = 2}}" | ./minioo

	@echo "Test 7:"
	@echo "var x; var y; var z; {x = 1; {y = 1; if y == x then z = 100 else z = 0}}" | ./minioo

	@echo "Test 8:"
	@echo "var first; var second; var n; var i; var temp; {first = 0; {second = 1; {n = 10; {i=0; while i < n {i = i + 1; {temp = second; {second = first + second; first = temp}}}}}}}" | ./minioo	
	
	@echo "Test 9:"
	@echo "var x; {var x; {x = 1; x = 3}; x = 2}" | ./minioo	

	@echo "Test 10:"
	@echo "var f; var x; {f = proc y: if y < 5 then x = 100 else x = 10; f(2)}" | ./minioo

	@echo "Test 11:"
	@echo "var sum; var acc; sum = proc n: if 0 < n then {acc = acc + n; {n = n-1; sum(n)}} else skip" | ./minioo

	@echo "Test 12:"
	@echo "var sum; var acc; {sum = proc n: if 0 < n then {acc = acc + n; {n = n-1; sum(n)}} else skip; {acc = 0; sum(10)}}" | ./minioo

	@echo "Test 13:"
	@echo "var f; { {var f; {f = 2; skip}; skip}; f = 1}" | ./minioo
	
	@echo "Test 14:"
	@echo "var x; var y; {malloc(x); {x.@a = 2; {y = @b; x.y = 3}}}" | ./minioo

	@echo "Test 15:"
	@echo "var x; var y; {malloc(x); {malloc(y); {x.@a = 2; y.@b = x.@a + 1}}}" | ./minioo

	@echo "Test 16: parallelism"
	@echo "var x; {x=1 ||| x=2} | ./minioo"
	@echo "var x; {x=1 ||| x=2}" | ./minioo

	@echo "Test 16:"
	@echo "{var x; {var y; {var z; z = x - 1; z = 1}; z = 1}; y = z - 1}" | ./minioo

	@echo "Test 17"
	@echo "{var x; {var y; {var z; z = x - 1; z = 1}; y = 1}; y = z - 1}" | ./minioo
	
	@echo "Test 18:"
	@echo "var x; var y; var z; z = 1 - y - z - x" | ./minioo
	
	@echo "Test 19:"
	@echo "{var z; skip; var z; z = 1 - z}" | ./minioo
	
	@echo "Test 20:"
	@echo "var a; a = proc y: y = y - 1" | ./minioo

	@echo "Test 21:"
	@echo "var x; {x = 1; {if x == 1 then x = 2 else x = 3; x = 10}}" | ./minioo
	
	@echo "Test 22:"
	@echo "{var x; var y; {x=1; y=1}; skip}" | ./minioo

	@echo "Test 23:"
	@echo "var a; {a = proc y: y = y - 1; a = 1}" | ./minioo

	@echo "Test 24:"
	@echo "var x; if true then x = 1 else x = 3" | ./minioo

	@echo "Test 25:"
	@echo "var x; x.@p = 1" | ./minioo

	@echo "Test 26:"
	@echo "var a; {a = proc y: y = y - 1; a(5)}" | ./minioo

	@echo "Test 27:"
	@echo "1-1(1-1)" | ./minioo

	@echo "Test 28:"
	@echo "var x; {x = 1 ||| {if x == 1 then x = 2 else x = 3; x = 10}}" | ./minioo

	@echo "Test 29:"
	@echo "var x; {atom(x = 1) ||| {if x == 1 then x = 2 else x = 3; x = 10}}" | ./minioo

	@echo "Test 30:"
	@echo "var x; malloc(x)" | ./minioo

	@echo "Test 31:"
	@echo "var x; y = 1" | ./minioo

	@echo "Test 32:"
	@echo "var x;{x = 1; var y; x = a - 1}" | ./minioo

	@echo "Test 33:"
	@echo "var x; malloc(y)" | ./minioo

	@echo "Test 34:"
	@echo "var x; {var a; a = 1; {x = 1; if x == 1 then {x = 1; malloc(b)} else x = 3}}" | ./minioo

	@echo "Test 35:"
	@echo "var a; {a = proc y: z = y - 1; a(5)}" | ./minioo

	@echo "Test 36:"
	@echo "var p; {p = proc y:if y < 1 then p = 1 else p(y - 1); p(1)}" | ./minioo
	
	@echo "# the end."

test:
	@echo "test 1: declare and assign (i)\n"
	@echo "echo 'var x; x = 1' | ./minioo"
	@echo "var x; x = 1" | ./minioo

	@echo "test 2: declare and assign (ii)\n"
	@echo "echo 'var x; var y; var z; x = 5' | ./minioo"
	@echo "var x; var y; var z; x = 5" | ./minioo

	@echo "test 3: declare and assign (iii)\n"
	@echo "echo '{var x; x = 1; var y; y = 2}' | ./minioo"
	@echo "{var x; x = 1; var y; y = 2}" | ./minioo

	@echo "test 4: simple field assign (i)"
	@echo "var x; {malloc(x); x.@a = 2}" | ./minioo

	@echo "test 5: simple field assign (ii)"
	@echo "var x; var y; {malloc(x); {x.@a = 2; {y = @b; x.y = 3}}}" | ./minioo

	@echo "test 6: simple field assign (iii)"
	@echo "var x; var y; {malloc(x); {malloc(y); {x.@a = 2; y.@b = x.@a + 1}}}" | ./minioo

delete:
	/bin/rm -f minioo *.cmi *.cmo lexer.cmi lexer.cmo lexer.ml syntax.cmi syntax.cmo syntax.ml syntax.mli syntax.conflicts makefile~
