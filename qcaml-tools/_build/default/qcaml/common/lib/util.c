/* External C functions */

/*    | ~erf_float~   | Error function ~erf~ from =libm=                | */
/*    | ~erfc_float~  | Complementary error function ~erfc~ from =libm= | */
/*    | ~gamma_float~ | Gamma function ~gamma~ from =libm=              | */
/*    | ~popcnt~      | ~popcnt~ instruction                            | */
/*    | ~trailz~      | ~ctz~ instruction                               | */
/*    | ~leadz~       | ~bsf~ instruction                               | */
   

/* [[file:~/QCaml/common/util.org::*External%20C%20functions][External C functions:1]] */
#include <math.h>
#include <caml/mlvalues.h>
#include <caml/alloc.h>
/* External C functions:1 ends here */

/* Erf */


/* [[file:~/QCaml/common/util.org::*Erf][Erf:1]] */
CAMLprim value erf_float_bytecode(value x) {
  return copy_double(erf(Double_val(x)));
}  

CAMLprim double erf_float(double x) {
  return erf(x);
}
/* Erf:1 ends here */

/* Erfc */


/* [[file:~/QCaml/common/util.org::*Erfc][Erfc:1]] */
CAMLprim value erfc_float_bytecode(value x) {
  return copy_double(erfc(Double_val(x)));
}  

CAMLprim double erfc_float(double x) {
  return erfc(x);
}
/* Erfc:1 ends here */

/* Gamma */


/* [[file:~/QCaml/common/util.org::*Gamma][Gamma:1]] */
CAMLprim value gamma_float_bytecode(value x) {
  return copy_double(tgamma(Double_val(x)));
}  


CAMLprim double gamma_float(double x) {
  return tgamma(x);
}
/* Gamma:1 ends here */

/* Popcnt */


/* [[file:~/QCaml/common/util.org::*Popcnt][Popcnt:1]] */
CAMLprim int32_t popcnt(int64_t i) {
  return __builtin_popcountll (i);
}


CAMLprim value popcnt_bytecode(value i) {
  return caml_copy_int32(__builtin_popcountll (Int64_val(i)));
}
/* Popcnt:1 ends here */

/* Trailz */


/* [[file:~/QCaml/common/util.org::*Trailz][Trailz:1]] */
CAMLprim int32_t trailz(int64_t i) {
  return __builtin_ctzll (i);
}


CAMLprim value trailz_bytecode(value i) {
  return caml_copy_int32(__builtin_ctzll (Int64_val(i)));
}
/* Trailz:1 ends here */

/* Leadz */


/* [[file:~/QCaml/common/util.org::*Leadz][Leadz:1]] */
CAMLprim int32_t leadz(int64_t i) {
  return __builtin_clzll(i);
}


CAMLprim value leadz_bytecode(value i) {
  return caml_copy_int32(__builtin_clzll (Int64_val(i)));
}
/* Leadz:1 ends here */
