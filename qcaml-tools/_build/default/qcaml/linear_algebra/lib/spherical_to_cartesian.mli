(** Conversion from spherical coordinate to cartesian corrdinates. *)

open Common

type num_cartesian_ao
type num_spherical_ao
  
val matrix : Angular_momentum.t -> (num_cartesian_ao, num_spherical_ao) Matrix.t
(** Returns a transformation matrix to rotate between the basis of atom-centered
    spherical coordinates to x,y,z coordinates.

    The first index of the result matrix is the index of the cartesian shell, as
    obtained by the [index] function, and the second index is the index of the 
    spherical shell.

    Example:
{[
  SphericalToCartesian.matrix Angular_momentum.D -> 
]}
*)

val index : nx:int -> ny:int -> nz:int -> int
(** Unique index given to a triplet of powers. Used to identify a cartesian shell.

    Example:
{[
  let nx, ny, nz = 3, 2, 1 in
  SphericalToCartesian.index ~nx ~ny ~nz -> 8
]}
*)
