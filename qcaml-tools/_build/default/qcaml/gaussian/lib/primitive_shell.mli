(** Set of Gaussians differing only by the powers of x, y and z, with a
    constant {!Angular_momentum.t}.

{% \\[
g_{n_x,n_y,n_z}(\mathbf{r}) = (x-X_A)^{n_x} (y-Y_A)^{n_y} (z-Z_A)^{n_z}
    \exp \left( -\alpha |\mathbf{r}-\mathbf{A}|^2 \right)
   \\] %}

where:

- {% $\mathbf{r} = (x,y,z)$ %} is the electron coordinate

- {% $\mathbf{A} = (X_A,Y_A,Z_A)$ %} is the coordinate of center A

- {% $n_x + n_y + n_z = l$ %}, the total angular momentum

- {% $\alpha$ %} is the exponent

*)

type t 

open Common

val to_string : t -> string
(** Pretty-printing of the primitive shell in a string. *)

val make : Angular_momentum.t -> Coordinate.t -> float -> t
(** Creates a primitive shell from the total angular momentum, the coordinates of the
    center and the exponent. *)

val exponent : t -> float 
(** Exponent {% $\alpha$ %}. *)

val center : t -> Coordinate.t
(** Coordinate {% $\mathbf{A}$ %}.of the center. *)

val ang_mom : t -> Angular_momentum.t
(** Total angular momentum : {% $l = n_x + n_y + n_z$ %}. *)

val norm : t -> float 
(** Norm of the shell, defined as
    {% \\[ || g_{l,0,0}(\mathbf{r}) || = 
      \sqrt{ \iiint \left[ (x-X_A)^{l}
      \exp (-\alpha |\mathbf{r}-\mathbf{A}|^2) \right]^2 \, dx\, dy\, dz}
    \\] %}
*)

val normalization : t -> float 
(** Normalization coefficient by which the shell has to be multiplied
    to be normalized :
    {% \\[ \mathcal{N} = \frac{1}{|| g_{l,0,0}(\mathbf{r}) ||} \\] %}.
*)

val norm_scales : t -> float array
(** Scaling factors {% $f(n_x,n_y,n_z)$ %} adjusting the normalization coefficient
    for the powers of {% $x,y,z$ %}. The normalization coefficients of the
    functions of the shell are given by {% $\mathcal{N}\times f$ %}.  They are
    given in the same order as [Angular_momentum.zkey_array ang_mom]: 
    {% \\[ f(n_x,n_y,n_z) = \frac{|| g_{l,0,0}(\mathbf{r}) ||}{|| g_{n_x,n_y,n_z}(\mathbf{r}) ||} \\] %}
*)

val size_of_shell : t -> int
(** Number of functions in the shell. *)

val zkey_array : t -> Zkey.t array
(** Returns the array of Zkeys associated with the primitive shell. *)

