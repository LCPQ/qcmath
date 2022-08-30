(** Multipole atomic integrals:

{% $$ \langle \chi_i | x | \chi_j \rangle $$ %}
{% $$ \langle \chi_i | y | \chi_j \rangle $$ %}
{% $$ \langle \chi_i | z | \chi_j \rangle $$ %}
{% $$ \langle \chi_i | x^2 | \chi_j \rangle $$ %}
{% $$ \langle \chi_i | y^2 | \chi_j \rangle $$ %}
{% $$ \langle \chi_i | z^2 | \chi_j \rangle $$ %}

*)

open Linear_algebra
open Gaussian

type t = (Basis.t, Basis.t) Matrix.t array

val matrix : t -> string -> (Basis.t, Basis.t) Matrix.t
(** Returns the requested matrix. Choices:
[x, y, z, x2, xy, yz, xz, y2, z2, z3, y3, z3, x4, y4, z4]
*)

val of_basis : Basis.t -> t

val to_file : filename:string -> (Basis.t, Basis.t) Matrix.t -> unit                                                
(** Write a matrix to a file *)

