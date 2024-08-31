(lang dune 3.16)

(name bavar2)

(generate_opam_files true)

(source
 (github dx3mod/bavar2))

(authors "Mikhail Lopatin <dx3mod@bk.ru>")

(maintainers "Mikhail Lopatin <dx3mod@bk.ru>")

(license MIT)

(package
 (name bavar2)
 (synopsis "A domain-specific build system for AVR C/C++ projects")
 (depends ocaml dune)
 (tags
  (avr build-system)))
