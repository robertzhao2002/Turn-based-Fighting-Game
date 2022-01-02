.PHONY: test check

build:
	dune build

utop:
	OCAMLRUNPARAM=b dune utop src

test:
	OCAMLRUNPARAM=b dune exec test/command_tests.exe
	OCAMLRUNPARAM=b dune exec test/move_tests.exe
	OCAMLRUNPARAM=b dune exec test/creature_tests.exe
	OCAMLRUNPARAM=b dune exec test/trainer_tests.exe

command_tests:
	OCAMLRUNPARAM=b dune exec test/command_tests.exe

creature_tests:
	OCAMLRUNPARAM=b dune exec test/creature_tests.exe

move_tests:
	OCAMLRUNPARAM=b dune exec test/move_tests.exe

trainer_tests:
	OCAMLRUNPARAM=b dune exec test/trainer_tests.exe

play:
	OCAMLRUNPARAM=b dune exec bin/main.exe

clean:
	dune clean
	
doc:
	dune build @doc

zip:
	rm -f fight.zip
	zip -r fight.zip . -x@exclude.lst
