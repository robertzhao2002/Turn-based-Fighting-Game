(lang dune 2.9)

(name Game)

(generate_opam_files true)

(package
 (name Game)
 (depends
  (ANSITerminal)
  (ounit2)
  (yojson)
  (ocaml
   (>= 4.02.3))
  dune))
