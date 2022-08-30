(** Set of contracted Gaussians differing only by the powers of x, y and z, with a
    constant {!Angular_momentum.t}.

{%
\begin{align*}
\chi_{n_x,n_y,n_z}(r) & = f(n_x,n_y,n_z) \sum_{i=1}^{m} \mathcal{N}_i d_i g_{i\,n_x,n_y,n_z}(r) \\
        & = (x-X_A)^{n_x} (y-Y_A)^{n_y} (z-Z_A)^{n_z} f(n_x,n_y,n_z) \sum_{i=1}^{m} \mathcal{N}_i  d_i \exp \left( -\alpha_i |r-R_A|^2 \right)
\end{align*}
%}

where:

- {% $g_{i\,n_x,n_y,n_z}(r)$ %} is the i-th {!Primitive_shell.t}

- {% $n_x + n_y + n_z = l$ %}, the total angular momentum

- {% $\alpha_i$ %} are the exponents (tabulated)

- {% $d_i$ %} are the contraction coefficients

- {% $\mathcal{N}_i$ %} is the normalization coefficient of the i-th primitive shell
  ({!Primitive_shell.norm_coef})

- {% $f(n_x,n_y,n_z)$ %} is a scaling factor adjusting the normalization coefficient for the
  particular powers of {% $x,y,z$ %} ({!Primitive_shell.norm_coef_scale})

*)

type t 

open Common    

val make : ?index:int -> (float * Primitive_shell.t) array -> t 
(** Creates a contracted shell from a list of coefficients and primitives.  *)

val with_index  : t -> int -> t
(** Returns a copy of the contracted shell with a modified index. *)

val index : t -> int
(** Index in the basis set, represented as an array of contracted shells. *)

val center : t -> Coordinate.t
(** Coordinate of the center {% $\mathbf{A} = (X_A,Y_A,Z_A)$ %}. *)

val ang_mom : t -> Angular_momentum.t
(** Total angular momentum : {% $l = n_x + n_y + n_z$ %}. *)

val size : t -> int
(** Number of primitive functions, {% $m$ %} in the definition. *)

val primitives : t -> Primitive_shell.t array
(** Array of primitive gaussians *)

val exponents : t -> float array
(** Array of exponents {% $\alpha_i$ %}. *)

val coefficients : t -> float array
(** Array of contraction coefficients {% $d_i$ %}. *)

val normalizations : t -> float array
(** Normalization coefficients {% $\mathcal{N}_i$ %} of the primitive shells. *)

val norm_scales : t -> float array
(** Scaling factors {% $f(n_x,n_y,n_z)$ %}, given in the same order as
    [Angular_momentum.zkey_array ang_mom]. *)

val size_of_shell : t -> int
(** Number of contracted functions in the shell: length of {!norm_coef_scale}. *)

val zkey_array : t -> Zkey.t array
(** Returns the array of Zkeys associated with the contracted shell. *)


val values : t -> Coordinate.t -> float array
(** Evaluates the all the functions of the [ContractedShell] at a given
    Cartesian coordinate. The order in which the functions are stored corresponds
    [Angular_momentum.(zkey_array @@ Singlet t.ang_mom)]
*)

(** {2 Printers} *)

val pp : Format.formatter -> t -> unit

