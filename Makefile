.PHONY: test check

build:
	dune build

utop:
	OCAMLRUNPARAM=b dune utop src

creature_tests:
	OCAMLRUNPARAM=b dune exec test/creature_tests.exe

move_tests:
	OCAMLRUNPARAM=b dune exec test/move_tests.exe

play:
	OCAMLRUNPARAM=b dune exec bin/main.exe

clean:
	dune clean
	
doc:
	dune build @doc

zip:
	rm -f fight.zip
	zip -r fight.zip . -x@exclude.lst
