(** Direct Inversion of the Iterative Subspace algorithm.

At iteration {% $m$ %}, one has:

- {% $\mathbf{p}_m$ %}, a vector of parameters
- {% $\mathbf{e}_m$ %}, an approximate error vector

The DIIS approximate solution for iteration {% $m+1$ %} is given by

{% \begin{align*}
\mathbf{p}_{m+1} & = \sum_{i=1}^m c_i (\mathbf{p}^f + \mathbf{e}_i) \\
                 & = \sum_{i=1}^m c_i \mathbf{p}^f + \sum_i c_i \mathbf{e}_i 
\end{align*} %}

where {% $\mathbf{p}^f$ %} is the exact solution. One wants to minimize the
norm of the error vector imposing the constraint that {% $\sum_{i=1}^m c_i = 1$ %}
with a Langrange multiplier {% $\lambda$ %}.

{%
\begin{align*}
\mathcal{L} & = ||\sum_i c_i \mathbf{e}_i||^2 - \lambda \left(\sum_i c_i - 1\right) \\
            & = \sum_{ij} c_i c_j B_{ij} - \lambda \left(\sum_{i=1}^m c_i - 1\right)
\end{align*}
%}
with
{% $B_{ij} = \langle \mathbf{e}_i | \mathbf{e}_j \rangle$ %}.

Equating zero to the derivatives of {% $\mathcal{L}$ %} with respect to {% $c_i$ %} and {% $\lambda$ %} leads to 

{% \begin{equation*}
\begin{bmatrix}
B_{11} & B_{12} & B_{13} & ... & B_{1m} & 1 \\
B_{21} & B_{22} & B_{23} & ... & B_{2m} & 1 \\
B_{31} & B_{32} & B_{33} & ... & B_{3m} & 1 \\
\vdots & \vdots & \vdots & \vdots & \ddots & \vdots \\
B_{m1} & B_{m2} & B_{m3} & ... & B_{mm} & 1 \\
1      & 1      & 1      & ... & 1      & 0
\end{bmatrix} \begin{bmatrix} c_1 \\ c_2 \\ c_3 \\ \vdots \\ c_m \\ -\lambda \end{bmatrix}=
\begin{bmatrix} 0 \\ 0 \\ 0 \\ \vdots \\ 0 \\ 1 \end{bmatrix}
\end{equation*}

%}

The coefficients are then used to update {% $\mathbf{p}$ %} as
{% $$
\mathbf{p}_{m+1}=\sum_{i=1}^m c_i\mathbf{p}_i.
$$ %}

*)

type 'a t

val make : ?mmax:int -> unit -> 'a t
(** Initialize DIIS with a maximum size.*)

val append : p:'a Vector.t -> e:'a Vector.t -> 'a t -> 'a t
(** Append a parameter vector [p] and the corresponding error vector [e]. *)

val next : 'a t -> 'a Vector.t
(** Returns a new parameter vector. *)


