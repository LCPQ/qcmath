open Common
open Operators
    
type t =
{
  expo_p_inv  : float ;
  expo_q_inv  : float ;
  norm_pq_sq  : float ;
  maxm        : int   ;
  center_pq   : Coordinate.t ;
  center_pa   : Coordinate.t ;
  center_qc   : Coordinate.t ;
  zero_m_func : t -> float array ;
  operator    : Operator.t option;
}

let zero ?operator zero_m_func = 
{
  zero_m_func ;
  operator ;
  maxm=0 ; 
  expo_p_inv = 0.;
  expo_q_inv = 0.;
  norm_pq_sq = 0.;
  center_pq = Coordinate.zero ;
  center_pa = Coordinate.zero ;
  center_qc = Coordinate.zero ;
}


