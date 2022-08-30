val canonical_ortho: ?thresh:float -> overlap:('a,'a) Matrix.t -> ('a,'b) Matrix.t ->
  ('a,'b) Matrix.t
(** Canonical orthogonalization. [overlap] is the overlap matrix {% $\mathbf{S}$ %},
    and the last argument contains the vectors {% $\mathbf{C}$ %} to orthogonalize.

{%
$$
\mathbf{C_\bot} = \mathbf{C\, U\, D^{-1/2}}, \;
\mathbf{U\, D\, V^\dag} = \mathbf{S}
$$
%}

    *)


val qr_ortho: ('a,'b) Matrix.t -> ('a,'b) Matrix.t
(** QR orthogonalization of the input matrix *)


