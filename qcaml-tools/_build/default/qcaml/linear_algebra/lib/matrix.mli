(** Type for matrices. The ['a] and ['b] types are labels for the rows and columns. *)

type ('a,'b) t

val dim1: ('a,'b) t -> int
(** First dimension of the matrix *) 

val dim2: ('a,'b) t -> int
(** Second dimension of the matrix *) 

val make : int -> int -> float -> ('a,'b) t
(** Creates a matrix initialized with the given value.
    @param m: First dimension
    @param n: Seconfd dimension
    @param f: Value used to initialize the matrix elements
*)

val make0 : int -> int -> ('a,'b) t
(** Creates a zero-initialized matrix. *)

val create : int -> int -> ('a,'b) t
(** Creates an uninitialized matrix. *)

val reshape_inplace : int -> int -> ('a,'b) t -> ('c,'d) t
(** Changes the dimensions of the matrix *)

val reshape_vec_inplace : int -> int -> ('a*'b) Vector.t -> ('a,'b) t
(** Reshapres a vector into a matrix *)

val init_cols : int -> int -> (int -> int -> float) -> ('a,'b) t
(** Creates an uninitialized matrix. *)

val identity: int -> ('a,'b) t
(** Creates an identity matrix. *)

val of_diag: 'a Vector.t -> ('a,'a) t
(** Creates a diagonal matrix. *)

val diag: ('a,'a) t -> 'a Vector.t 
(** Returns the diagonal of a matrix. *)

val fill_inplace: ('a,'b) t -> float -> unit
(** Fills the matrix with the give value. *)

val add_const_diag : float -> ('a,'b) t -> ('a,'b) t 
(** Adds a constant to the diagonal *)
  
val add_const_diag_inplace : float -> ('a,'b) t -> unit
(** Adds a constant to the diagonal *)
  
val add_const_inplace : float -> ('a,'b) t -> unit 
(** Adds a constant to the diagonal *)
  
val add_const : float -> ('a,'b) t -> ('a,'b) t
(** Adds a constant to the diagonal *)
  
val add : ('a,'b) t -> ('a,'b) t -> ('a,'b) t
(** Adds two matrices *)
  
val sub : ('a,'b) t -> ('a,'b) t -> ('a,'b) t
(** Subtracts two matrices *)

val mul : ('a,'b) t -> ('a,'b) t -> ('a,'b) t
(** Multiplies two matrices element-wise *)
  
val div : ('a,'b) t -> ('a,'b) t -> ('a,'b) t
(** Divides two matrices element-wise *)
  
val amax : ('a,'b) t -> float
(** Maximum of the absolute values of the elements of the matrix. *)
  
val add_inplace : c:('a,'b) t -> ('a,'b) t -> ('a,'b) t -> unit
(** [add_inplace c a b] : performs [c = a+b] in-place. *)
  
val sub_inplace : c:('a,'b) t -> ('a,'b) t -> ('a,'b) t -> unit
(** [sub_inplace c a b] : performs [c = a+b] in-place. *)

val mul_inplace : c:('a,'b) t -> ('a,'b) t -> ('a,'b) t -> unit
(** [mul_inplace c a b] : performs [c = a*b] element-wise in-place. *)
  
val div_inplace : c:('a,'b) t -> ('a,'b) t -> ('a,'b) t -> unit
(** [div_inplace c a b] : performs [c = a/b] element-wise in-place. *)
  
(*
val to_bigarray : ('a,'b) t -> (float, Stdlib.Bigarray.float64_elt, Stdlib.Bigarray.fortran_layout) Stdlib.Bigarray.Array2.t
(** Converts the matrix into a Bigarray in Fortran layout *)

val of_bigarray : (float, Stdlib.Bigarray.float64_elt, Stdlib.Bigarray.fortran_layout) Stdlib.Bigarray.Array2.t -> ('a,'b) t 
(** Converts a [Bigarray.Array2] in Fortran layout into a matrix *)

*)
val to_bigarray_inplace :
  ('a,'b) t -> (float, Stdlib.Bigarray.float64_elt, Stdlib.Bigarray.fortran_layout) Stdlib.Bigarray.Array2.t
(** Converts the matrix into a Bigarray in Fortran layout in place*)

val of_bigarray_inplace :
  (float, Stdlib.Bigarray.float64_elt, Stdlib.Bigarray.fortran_layout) Stdlib.Bigarray.Array2.t -> ('a,'b) t 
(** Converts a [Bigarray.Array2] in Fortran layout into a matrix in place*)

val to_col_vecs : ('a,'b) t -> 'a Vector.t array
(** Converts the matrix into an array of vectors *)

val to_col_vecs_list : ('a,'b) t -> 'a Vector.t list
(** Converts the matrix into a list of vectors *)

val of_col_vecs : 'a Vector.t array -> ('a,'b) t
(** Converts an array of vectors into a matrix *)

val of_col_vecs_list : 'a Vector.t list -> ('a,'b) t
(** Converts a list of vectors  into a matrix *)

val to_array : ('a,'b) t -> float array array
(** Converts the matrix into an array of arrays *)

val of_array : float array array -> ('a,'b) t
(** Converts an array of arrays into a matrix *)

val copy: ?m:int -> ?n:int -> ?br:int -> ?bc:int -> ?ar:int -> ?ac:int -> ('a,'b) t -> ('a,'b) t
(** Copies all or part of a two-dimensional matrix A to a new matrix B *)

val copy_inplace: ?m:int -> ?n:int -> ?br:int -> ?bc:int -> b:('a,'b) t -> ?ar:int -> ?ac:int -> ('a,'b) t -> unit
(** Copies all or part of a two-dimensional matrix A to an existing matrix B *)

(*
val col: ('a,'b) t -> int -> 'a Vector.t
(** Returns a column of the matrix as a vector *)
*)

val col_inplace: ('a,'b) t -> int -> 'a Vector.t
(** Returns a column of the matrix as a vector *)

val transpose: ('a,'b) t -> ('b,'a) t
(** Returns the transposed matrix *)

val transpose_inplace: ('a,'a) t -> unit
(** Transposes the matrix in place. *)

val detri: ('a,'b) t -> ('a,'b) t 
(** Takes an upper-triangular matrix, and makes it a symmetric matrix
by mirroring the defined triangle along the diagonal. *)

val detri_inplace: ('a,'b) t -> unit 
(** Takes an upper-triangular matrix, and makes it a symmetric matrix
by mirroring the defined triangle along the diagonal. *)

val as_vec_inplace: ('a,'b) t -> ('a*'b) Vector.t
(** Interpret the matrix as a vector (reshape). *)
  
val as_vec: ('a,'b) t -> ('a*'b) Vector.t
(** Return a copy of the reshaped matrix into a vector *)
  
val random:  ?rnd_state:Random.State.t -> ?from:float -> ?range:float -> int -> int -> ('a,'b) t
(** Creates a random matrix, similarly to [Vector.random] *)

val map: (float -> float) -> ('a,'b) t -> ('a,'b) t
(** Apply the function to all elements of the matrix *)

val map_inplace: (float -> float) -> b:('a,'b) t -> ('a,'b) t -> unit
(** [map_inplace f b a] : Apply the function to all elements of the
    matrix [a] and store the results in [b] *)

val scale: float -> ('a,'b) t -> ('a,'b) t
(** Multiplies the matrix by a constant *)
  
val scale_inplace: float -> ('a,'b) t -> unit
(** Multiplies the matrix by a constant *)
  
val scale_cols: ('a,'b) t -> 'b Vector.t -> ('a,'b) t
(** Multiplies the matrix by a constant *)
  
val scale_cols_inplace: ('a,'b) t -> 'b Vector.t -> unit
(** Multiplies the matrix by a constant *)
  
val scale_rows: 'a Vector.t -> ('a,'b) t -> ('a,'b) t
(** Multiplies the matrix by a constant *)
  
val scale_rows_inplace: 'a Vector.t -> ('a,'b) t -> unit
(** Multiplies the matrix by a constant *)
  
val sycon: ('a,'b) t -> float
(** Returns the condition number of a matrix *)
  
val outer_product : ?alpha:float -> 'a Vector.t -> 'b Vector.t -> ('a,'b) t
(** Computes M = %{ $\alpha u.v^t$ %} *)

val outer_product_inplace : ('a,'b) t -> ?alpha:float -> 'a Vector.t -> 'b Vector.t -> unit
(** Computes M = %{ $\alpha u.v^t$ %} *)


val gemv_n_inplace : ?m:int -> ?n:int -> ?beta:float -> 'a Vector.t ->
  ?alpha:float -> ?ar:int -> ?ac:int -> ('a,'b) t -> 'b Vector.t -> 
  unit
(** Performs the Lapack GEMV operation. Default values:
[beta=0.] [alpha=1.0].
[gemv ~beta y ~alpha m v]: %{ $Y = \beta Y + \alpha M V$
The vector Y is updated in-place.
*)

val gemv_t_inplace : ?m:int -> ?n:int -> ?beta:float -> 'b Vector.t ->
  ?alpha:float -> ?ar:int -> ?ac:int -> ('a,'b) t -> 'a Vector.t ->
  unit
(** Performs the Lapack GEMV operation. Default values:
[beta=0.] [alpha=1.0].
[gemv ~beta y ~alpha m v]: %{ $Y = \beta Y + \alpha M^\dagger V$
The vector Y is updated in-place.
*)

val gemv_n : ?m:int -> ?n:int -> ?beta:float -> ?y:'a Vector.t ->
  ?alpha:float -> ?ar:int -> ?ac:int -> ('a,'b) t -> 'b Vector.t ->
  'a Vector.t
(** Performs the Lapack GEMV operation. Default values:
[beta=0.] [alpha=1.0].
[gemv ~beta y ~alpha m v]: %{ $Y = \beta Y + \alpha M^\dagger V$ *)

val gemv_t : ?m:int -> ?n:int -> ?beta:float -> ?y:'b Vector.t ->
  ?alpha:float -> ?ar:int -> ?ac:int -> ('a,'b) t -> 'a Vector.t ->
  'b Vector.t
(** Performs the Lapack GEMV operation. Default values:
[beta=0.] [alpha=1.0].
[gemv ~beta y ~alpha m v]: %{ $Y = \beta Y + \alpha M^\dagger V$
*)

val gemm_inplace : ?m:int -> ?n:int -> ?k:int -> ?beta:float ->
  c:('a,'b) t -> ?transa:[`N | `T] -> ?alpha:float ->
    ('c,'d) t -> ?transb:[`N | `T] -> ('e,'f) t -> unit
(** Performs the Lapack GEMM operation. Default values:
[beta=0.] [transa=`N] [alpha=1.0] [transb=`N].
[gemm ~beta c ~alpha a b]: %{ $C = \beta C + \alpha A B$ *)

val gemm_nn_inplace : ?m:int -> ?n:int -> ?k:int -> ?beta:float ->
  c:('a,'c) t -> ?alpha:float -> ('a,'b) t -> ('b,'c) t -> unit
(** Performs gemm with [~transa=`N] and [~transb=`N]. *)

val gemm_nt_inplace : ?m:int -> ?n:int -> ?k:int -> ?beta:float ->
  c:('a,'c) t -> ?alpha:float -> ('a,'b) t -> ('c,'b) t -> unit
(** Performs gemm with [~transa=`N] and [~transb=`T]. *)

val gemm_tt_inplace : ?m:int -> ?n:int -> ?k:int -> ?beta:float ->
  c:('a,'c) t -> ?alpha:float -> ('b,'a) t -> ('c,'b) t -> unit
(** Performs gemm with [~transa=`T] and [~transb=`T]. *)

val gemm_tn_inplace : ?m:int -> ?n:int -> ?k:int -> ?beta:float ->
  c:('a,'c) t -> ?alpha:float -> ('b,'a) t -> ('b,'c) t -> unit
(** Performs gemm with [~transa=`T] and [~transb=`N]. *)


val gemm: ?m:int -> ?n:int -> ?k:int -> ?beta:float ->
  ?c:('a,'b) t  -> ?transa:[`N | `T] -> ?alpha:float ->
  ('c,'d) t -> ?transb:[`N | `T] -> ('e,'f) t -> ('a,'b) t 
(** Performs the Lapack GEMM operation. Default values:
[beta=0.] [transa=`N] [alpha=1.0] [transb=`N] 
[gemm ~beta ~alpha a b]: %{ $C = \beta C + \alpha A B$ *)

val gemm_nn: ?m:int -> ?n:int -> ?k:int -> ?beta:float ->
  ?c:('a,'c) t -> ?alpha:float -> ('a,'b) t -> ('b,'c) t -> ('a,'c) t 
(** Performs gemm with [~transa=`N] and [~transb=`N]. *)

val gemm_nt: ?m:int -> ?n:int -> ?k:int -> ?beta:float ->
  ?c:('a,'c) t -> ?alpha:float -> ('a,'b) t -> ('c,'b) t -> ('a,'c) t 
(** Performs gemm with [~transa=`N] and [~transb=`T]. *)

val gemm_tn: ?m:int -> ?n:int -> ?k:int -> ?beta:float -> 
  ?c:('a,'c) t -> ?alpha:float -> ('b,'a) t -> ('b,'c) t -> ('a,'c) t 
(** Performs gemm with [~transa=`T] and [~transb=`N]. *)

val gemm_tt: ?m:int -> ?n:int -> ?k:int -> ?beta:float ->
  ?c:('a,'c) t -> ?alpha:float -> ('b,'a) t -> ('c,'b) t -> ('a,'c) t 
(** Performs gemm with [~transa=`T] and [~transb=`T]. *)


val gemm_trace: ?transa:[`N | `T] -> ('a,'b) t -> ?transb:[`N | `T] -> ('c,'d) t -> float 
(** Computes the trace of a GEMM. Default values:
[transa=`N] [transb=`N] 
[gemm_trace a b]: %{ $C =  Tr(A B)$ *)

val gemm_nn_trace: ('a,'b) t -> ('b,'c) t -> float 
(** Computes the trace of a GEMM with [~transa=`N] and [~transb=`N]. *)

val gemm_nt_trace: ('a,'b) t -> ('c,'b) t -> float 
(** Computes the trace of a GEMM with [~transa=`N] and [~transb=`T]. *)

val gemm_tn_trace: ('b,'a) t -> ('b,'c) t -> float 
(** Computes the trace of a GEMM with [~transa=`T] and [~transb=`N]. *)

val gemm_tt_trace: ('b,'a) t -> ('c,'b) t -> float 
(** Computes the trace of a GEMM with [~transa=`T] and [~transb=`T]. *)

val svd: ('a,'b) t -> ('a,'b) t * 'b Vector.t * ('b,'b) t
(** Singular value decomposition of A(m,n) when m >= n. *)

val svd': ('a,'b) t -> ('a,'a) t * 'a Vector.t * ('a,'b) t
(** Singular value decomposition of A(m,n) when m < n. *)

val qr: ('a,'b) t -> ('a,'b) t * ('b,'b) t
(** QR factorization *)
             
val normalize_mat : ('a,'b) t -> ('a,'b) t
(** Returns the matrix with all the column vectors normalized *)

val normalize_mat_inplace : ('a,'b) t -> unit
(** Returns the matrix with all the column vectors normalized *)

val diagonalize_symm : ('a,'a) t -> ('a,'a) t * 'a Vector.t
(** Diagonalize a symmetric matrix. Returns the eigenvectors and the eigenvalues. *)

val exponential : ('a,'a) t -> ('a,'a) t
(** Computes the exponential of a square matrix. *)

val exponential_antisymmetric: ('a,'a) t -> ('a,'a) t
(** Computes the exponential of an antisymmetric square matrix. *)

val xt_o_x : o:('a,'a) t -> x:('a,'b) t -> ('b,'b) t
(** Computes {% $\mathbf{X^\dag\, O\, X}$ %} *)

val x_o_xt : o:('b,'b) t -> x:('a,'b) t -> ('a,'a) t
(** Computes {% $\mathbf{X\, O\, X^\dag}$ %} *)

val debug_matrix: string -> ('a,'b) t -> unit                                                     
(** Prints a matrix in stdout for debug *)

val of_file : string -> ('a,'b) t
(** Reads a matrix from a file with format "%d %d %f" corresponding to
    [i, j, A.{i,j}]. *)

val relabel : ('a,'b) t -> ('c,'d) t

val sym_of_file : string -> ('a,'b) t
(** Reads a symmetric matrix from a file with format "%d %d %f" corresponding to
    [i, j, A.{i,j}]. *)

val sysv_inplace : b:('a,'b) t -> ('a,'a) t -> unit
(** Solves %{ $AX=B$ %} when A is symmetric, and stores the result in B. *)
  
val sysv : b:('a,'b) t -> ('a,'a) t -> ('a,'b) t
(** Solves %{ $AX=B$ %} when A is symmetric *)
  
val (%:) : ('a,'b) t -> (int*int) -> float
(** [t%.(i,j)] returns the element at i,j. *)

val set : ('a,'b) t -> int -> int -> float -> unit
(** [set t i j v] sets the (i,j)-th element to v *)

val to_file : filename:string -> ?sym:bool -> ?cutoff:float -> ('a,'b) t -> unit
(** Write the matrix to a file. *)
  
val pp : Format.formatter -> ('a,'b) t -> unit

