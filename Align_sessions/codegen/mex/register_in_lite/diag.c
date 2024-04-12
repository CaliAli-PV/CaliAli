/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * diag.c
 *
 * Code generation for function 'diag'
 *
 */

/* Include files */
#include "diag.h"
#include "register_in_lite_emxutil.h"
#include "register_in_lite_types.h"
#include "rt_nonfinite.h"
#include "mwmathutil.h"

/* Variable Definitions */
static emlrtRTEInfo o_emlrtRTEI = {
    102,    /* lineNo */
    19,     /* colNo */
    "diag", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\diag.m" /* pName
                                                                       */
};

static emlrtRTEInfo pd_emlrtRTEI = {
    100,    /* lineNo */
    5,      /* colNo */
    "diag", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\diag.m" /* pName
                                                                       */
};

static emlrtRTEInfo qd_emlrtRTEI = {
    109,    /* lineNo */
    24,     /* colNo */
    "diag", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\diag.m" /* pName
                                                                       */
};

/* Function Definitions */
void diag(const emlrtStack *sp, const emxArray_real_T *v, emxArray_real_T *d)
{
  const real_T *v_data;
  real_T *d_data;
  int32_T m;
  v_data = v->data;
  if ((v->size[0] == 1) && (v->size[1] == 1)) {
    int32_T n;
    n = d->size[0];
    d->size[0] = 1;
    emxEnsureCapacity_real_T(sp, d, n, &pd_emlrtRTEI);
    d_data = d->data;
    d_data[0] = v_data[0];
  } else {
    int32_T n;
    if ((v->size[0] == 1) || (v->size[1] == 1)) {
      emlrtErrorWithMessageIdR2018a(
          sp, &o_emlrtRTEI, "Coder:toolbox:diag_varsizedMatrixVector",
          "Coder:toolbox:diag_varsizedMatrixVector", 0);
    }
    m = v->size[0];
    n = v->size[1];
    if (v->size[1] > 0) {
      m = muIntScalarMin_sint32(m, n);
    } else {
      m = 0;
    }
    n = d->size[0];
    d->size[0] = m;
    emxEnsureCapacity_real_T(sp, d, n, &qd_emlrtRTEI);
    d_data = d->data;
    n = m - 1;
    for (m = 0; m <= n; m++) {
      d_data[m] = v_data[m + v->size[0] * m];
    }
  }
}

/* End of code generation (diag.c) */
