/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * bsearch.c
 *
 * Code generation for function 'bsearch'
 *
 */

/* Include files */
#include "bsearch.h"
#include "register_in_lite_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
int32_T b_bsearch(const emxArray_real_T *x, real_T xi)
{
  const real_T *x_data;
  int32_T high_i;
  int32_T low_ip1;
  int32_T n;
  x_data = x->data;
  high_i = x->size[1];
  n = 1;
  low_ip1 = 2;
  while (high_i > low_ip1) {
    int32_T mid_i;
    mid_i = (n >> 1) + (high_i >> 1);
    if (((n & 1) == 1) && ((high_i & 1) == 1)) {
      mid_i++;
    }
    if (xi >= x_data[mid_i - 1]) {
      n = mid_i;
      low_ip1 = mid_i + 1;
    } else {
      high_i = mid_i;
    }
  }
  return n;
}

/* End of code generation (bsearch.c) */
