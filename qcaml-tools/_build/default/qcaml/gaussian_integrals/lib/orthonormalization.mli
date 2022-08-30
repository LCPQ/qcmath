(** Orthonormalization of the basis. *)

open Gaussian
open Linear_algebra

type t = (Basis.t, Basis.t) Matrix.t

val make: ?thresh:float -> ?basis:Basis.t -> cartesian:bool -> Overlap.t -> t
(** Returns a matrix or orthonormal vectors in the basis. The vectors are
    linearly independent up to a threshold [thresh]. If [cartesian] is
    [false], the [basis] argument needs to be given and the space spanned by
    the vectors is the same as the space spanned by the basis in spherical
    coordinates (5d,7f,...). 
*)

val make_lowdin: thresh:float -> overlap:Overlap.t -> t
(** Lowdin orthonormalization *)
