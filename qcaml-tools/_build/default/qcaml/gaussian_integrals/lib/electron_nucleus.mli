(** Electron-Nucleus attractive potential integrals, expressed as a matrix in a {!Basis.t}.

{% $$
V_{ij} = \left \langle \chi_i \left| \sum_A \frac{-Z_A}{ | \mathbf{r} - \mathbf{R}_A |} \right| \chi_j \right \rangle
$$ %}

*)

include module type of Matrix_on_basis

open Particles
open Gaussian

val of_basis_nuclei : basis:Basis.t -> Nuclei.t -> t
(** Build from a {Basis.t} and the nuclei (coordinates and charges). *)


