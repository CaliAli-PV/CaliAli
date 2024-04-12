/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * svd.c
 *
 * Code generation for function 'svd'
 *
 */

/* Include files */
#include "svd.h"
#include "eml_int_forloop_overflow_check.h"
#include "register_in_lite_data.h"
#include "register_in_lite_emxutil.h"
#include "register_in_lite_types.h"
#include "rt_nonfinite.h"
#include "svd1.h"
#include "mwmathutil.h"

/* Variable Definitions */
static emlrtRSInfo ge_emlrtRSI = {
    14,    /* lineNo */
    "svd", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m" /* pathName
                                                                       */
};

static emlrtRSInfo he_emlrtRSI = {
    36,    /* lineNo */
    "svd", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m" /* pathName
                                                                       */
};

static emlrtRSInfo ie_emlrtRSI = {
    42,    /* lineNo */
    "svd", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m" /* pathName
                                                                       */
};

static emlrtRSInfo je_emlrtRSI = {
    29,             /* lineNo */
    "anyNonFinite", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\anyNonFinite."
    "m" /* pathName */
};

static emlrtRSInfo ke_emlrtRSI =
    {
        44,          /* lineNo */
        "vAllOrAny", /* fcnName */
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
        "internal\\vAllOrAny.m" /* pathName */
};

static emlrtRSInfo le_emlrtRSI =
    {
        103,                  /* lineNo */
        "flatVectorAllOrAny", /* fcnName */
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
        "internal\\vAllOrAny.m" /* pathName */
};

static emlrtRTEInfo rc_emlrtRTEI = {
    41,    /* lineNo */
    14,    /* colNo */
    "svd", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m" /* pName
                                                                       */
};

static emlrtRTEInfo sc_emlrtRTEI = {
    49,    /* lineNo */
    9,     /* colNo */
    "svd", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m" /* pName
                                                                       */
};

static emlrtRTEInfo tc_emlrtRTEI = {
    43,    /* lineNo */
    9,     /* colNo */
    "svd", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m" /* pName
                                                                       */
};

static emlrtRTEInfo uc_emlrtRTEI = {
    44,    /* lineNo */
    9,     /* colNo */
    "svd", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m" /* pName
                                                                       */
};

static emlrtRTEInfo vc_emlrtRTEI = {
    45,    /* lineNo */
    9,     /* colNo */
    "svd", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m" /* pName
                                                                       */
};

static emlrtRTEInfo wc_emlrtRTEI = {
    18,    /* lineNo */
    9,     /* colNo */
    "svd", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m" /* pName
                                                                       */
};

static emlrtRTEInfo xc_emlrtRTEI = {
    1,     /* lineNo */
    20,    /* colNo */
    "svd", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\svd.m" /* pName
                                                                       */
};

/* Function Definitions */
void svd(const emlrtStack *sp, const emxArray_real_T *A, emxArray_real_T *U,
         emxArray_real_T *S, emxArray_real_T *V)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack st;
  emxArray_real_T *U1;
  emxArray_real_T *V1;
  emxArray_real_T *r;
  emxArray_real_T *s;
  const real_T *A_data;
  real_T *U_data;
  real_T *s_data;
  int32_T i;
  int32_T k;
  int32_T nx;
  boolean_T p;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  A_data = A->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  st.site = &ge_emlrtRSI;
  b_st.site = &je_emlrtRSI;
  c_st.site = &ke_emlrtRSI;
  nx = A->size[0] * A->size[1];
  p = true;
  d_st.site = &le_emlrtRSI;
  if (nx > 2147483646) {
    e_st.site = &ib_emlrtRSI;
    check_forloop_overflow_error(&e_st);
  }
  for (k = 0; k < nx; k++) {
    if ((!p) ||
        (muDoubleScalarIsInf(A_data[k]) || muDoubleScalarIsNaN(A_data[k]))) {
      p = false;
    }
  }
  emxInit_real_T(sp, &s, 1, &wc_emlrtRTEI);
  if (p) {
    st.site = &he_emlrtRSI;
    b_svd(&st, A, U, s, V);
    s_data = s->data;
  } else {
    emxInit_real_T(sp, &r, 2, &rc_emlrtRTEI);
    i = r->size[0] * r->size[1];
    r->size[0] = A->size[0];
    r->size[1] = A->size[1];
    emxEnsureCapacity_real_T(sp, r, i, &rc_emlrtRTEI);
    U_data = r->data;
    nx = A->size[0] * A->size[1];
    for (i = 0; i < nx; i++) {
      U_data[i] = 0.0;
    }
    emxInit_real_T(sp, &U1, 2, &xc_emlrtRTEI);
    emxInit_real_T(sp, &V1, 2, &xc_emlrtRTEI);
    st.site = &ie_emlrtRSI;
    b_svd(&st, r, U1, s, V1);
    emxFree_real_T(sp, &r);
    i = U->size[0] * U->size[1];
    U->size[0] = U1->size[0];
    U->size[1] = U1->size[1];
    emxEnsureCapacity_real_T(sp, U, i, &tc_emlrtRTEI);
    U_data = U->data;
    nx = U1->size[0] * U1->size[1];
    emxFree_real_T(sp, &U1);
    for (i = 0; i < nx; i++) {
      U_data[i] = rtNaN;
    }
    nx = s->size[0];
    i = s->size[0];
    s->size[0] = nx;
    emxEnsureCapacity_real_T(sp, s, i, &uc_emlrtRTEI);
    s_data = s->data;
    for (i = 0; i < nx; i++) {
      s_data[i] = rtNaN;
    }
    i = V->size[0] * V->size[1];
    V->size[0] = V1->size[0];
    V->size[1] = V1->size[1];
    emxEnsureCapacity_real_T(sp, V, i, &vc_emlrtRTEI);
    U_data = V->data;
    nx = V1->size[0] * V1->size[1];
    emxFree_real_T(sp, &V1);
    for (i = 0; i < nx; i++) {
      U_data[i] = rtNaN;
    }
  }
  i = S->size[0] * S->size[1];
  S->size[0] = U->size[1];
  S->size[1] = V->size[1];
  emxEnsureCapacity_real_T(sp, S, i, &sc_emlrtRTEI);
  U_data = S->data;
  nx = U->size[1] * V->size[1];
  for (i = 0; i < nx; i++) {
    U_data[i] = 0.0;
  }
  i = s->size[0] - 1;
  for (k = 0; k <= i; k++) {
    U_data[k + S->size[0] * k] = s_data[k];
  }
  emxFree_real_T(sp, &s);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

/* End of code generation (svd.c) */
