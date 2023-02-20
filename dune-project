(lang dune 2.9)

(name Game)

(generate_opam_files true)

(package
 (name Game)
 (depends
  (ANSITerminal
   (>= 0.8.5))
  (ocaml
   (>= 4.02.3))
  (ounit2
   (>= 2.2.6))
  (yojson
   (>= 2.0.2))
  dune))
