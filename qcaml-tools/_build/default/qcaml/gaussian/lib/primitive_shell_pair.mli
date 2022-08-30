(** Data structure describing a pair of primitive shells.

A primitive shell pair is the cartesian product between two sets of functions, each
set containing all the functions of a primitive shell. These are one-electron functions.

{% \\[
  \left\\{ p_{k_x,k_y,k_z}(\mathbf{r}) \right\\} =
      \left\\{ g_{n_x,n_y,n_z}(\mathbf{r}) \right\\} \times
      \left\\{ g_{m_x,m_y,m_z}'(\mathbf{r}) \right\\}
\\] %}

where
      
{%
\begin{align*}
  g_{n_x,n_y,n_z}(\mathbf{r})  & =
      (x-X_A)^{n_x} (y-Y_A)^{n_y} (z-Z_A)^{n_z} 
      \exp \left( -\alpha |\mathbf{r}-\mathbf{A}|^2 \right) \\
  g_{m_x,m_y,m_z}'(\mathbf{r}) & =
      (x-X_B)^{m_x} (y-Y_B)^{m_y} (z-Z_B)^{m_z}
      \exp \left( -\beta |\mathbf{r}-\mathbf{B}|^2 \right) 
\end{align*}
%}


{!a_minus_b}, {!a_minus_b_sq} and {!norm_coef_scale} depend only on the
centering of the two shells, and {!ang_mom} only depends on the angular
momenta of the two shells. Hence, these quantities need to be computed only
once when a {!ContractedShellPair.t} is built. Hence, there is the
{!create_make_of} function which creates a [make] function which is suitable
for a {!ContractedShellPair.t}.

References:

[1] {{:http://dx.doi.org/10.1002/qua.560400604} P.M. Gill, B.G. Johnson, and J.A. Pople, International Journal of Quantum Chemistry 40, 745 (1991)}.
*)

type t 

open Common

val make : Primitive_shell.t -> Primitive_shell.t -> t
(** Creates a primitive shell pair using two primitive shells. *)

val create_make_of : Primitive_shell.t -> Primitive_shell.t ->
  (Primitive_shell.t -> Primitive_shell.t -> float -> t option)
(** Creates a make function [Primitive_shell.t -> Primitive_shell.t -> float -> t] in which
    all the quantities common to the shell and independent of the exponent
    are pre-computed.

    The result is None if the normalization coefficient of the resulting
    function is below the cutoff given as a last argument.
*)

val ang_mom : t -> Angular_momentum.t
(** Total angular momentum of the shell pair: sum of the angular momenta of
    the shells.  *)

val center : t -> Coordinate.t
(** Coordinates of the center {% $\mathbf{P}$ %}. *)

val monocentric : t -> bool
(** True if both shells of the pair have the same center. *)


val shell_a : t -> Primitive_shell.t
(** Returns the first primitive shell that was used to build the shell pair. *)

val shell_b : t -> Primitive_shell.t
(** Returns the second primitive shell that was used to build the shell pair. *)

val normalization : t -> float
(** Normalization coefficient of the shell pair. *)

val norm_scales : t -> float array
(** Normalization factor, characteristic of the powers of x, y and z of
    both shells of the pair. It is the outer product of the 2 
    {!Primitive_shell.norm_coef_scale} arrays of the shells consituting the
    pair.
*)

val exponent : t -> float
(** Exponent of the Gaussian output of the Gaussian product : {% \\[ \alpha + \beta \\] %}*)

val exponent_inv : t -> float 
(** Inverse of the exponent : {% \\[ \sigma_P = \frac{1}{\alpha + \beta} \\] %}*)

val a_minus_b : t -> Coordinate.t
(** {% $\mathbf{A}-\mathbf{B}$ %} *)

val a_minus_b_sq : t -> float
(** {% $|\mathbf{A}-\mathbf{B}|^2$ %} *)

val center_minus_a : t -> Coordinate.t
(** {% $\mathbf{P}-\mathbf{A}$ %} *)


val equivalent : t -> t -> bool
(** True if two primitive shell pairs are equivalent. *)

val hash : t -> int
(** Returns an integer characteristic of the shell pair. *)

val cmp : t -> t -> int
(** Arbitray comparison function for sorting. *)

val zkey_array : t -> Zkey.t array
(** Returns the array of Zkeys associated with the shell pair. *)

