/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * gradient.c
 *
 * Code generation for function 'gradient'
 *
 */

/* Include files */
#include "gradient.h"
#include "eml_int_forloop_overflow_check.h"
#include "register_in_lite_data.h"
#include "register_in_lite_emxutil.h"
#include "register_in_lite_types.h"
#include "rt_nonfinite.h"
#include <emmintrin.h>

/* Variable Definitions */
static emlrtRSInfo
    kc_emlrtRSI =
        {
            70,         /* lineNo */
            "gradient", /* fcnName */
            "C:\\Program "
            "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\gradien"
            "t.m" /* pathName */
};

static emlrtRSInfo
    lc_emlrtRSI =
        {
            121,        /* lineNo */
            "gradFlat", /* fcnName */
            "C:\\Program "
            "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\gradien"
            "t.m" /* pathName */
};

static emlrtRSInfo
    mc_emlrtRSI =
        {
            129,        /* lineNo */
            "gradFlat", /* fcnName */
            "C:\\Program "
            "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\gradien"
            "t.m" /* pathName */
};

static emlrtRSInfo
    nc_emlrtRSI =
        {
            134,        /* lineNo */
            "gradFlat", /* fcnName */
            "C:\\Program "
            "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\gradien"
            "t.m" /* pathName */
};

static emlrtRSInfo
    oc_emlrtRSI =
        {
            145,        /* lineNo */
            "gradFlat", /* fcnName */
            "C:\\Program "
            "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\gradien"
            "t.m" /* pathName */
};

static emlrtRSInfo
    pc_emlrtRSI =
        {
            117,        /* lineNo */
            "gradFlat", /* fcnName */
            "C:\\Program "
            "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\gradien"
            "t.m" /* pathName */
};

static emlrtRTEInfo
    i_emlrtRTEI =
        {
            25,         /* lineNo */
            23,         /* colNo */
            "gradient", /* fName */
            "C:\\Program "
            "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\gradien"
            "t.m" /* pName */
};

static emlrtRTEInfo
    pc_emlrtRTEI =
        {
            54,         /* lineNo */
            13,         /* colNo */
            "gradient", /* fName */
            "C:\\Program "
            "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\gradien"
            "t.m" /* pName */
};

static emlrtRTEInfo
    qc_emlrtRTEI =
        {
            115,        /* lineNo */
            20,         /* colNo */
            "gradient", /* fName */
            "C:\\Program "
            "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\gradien"
            "t.m" /* pName */
};

/* Function Definitions */
void gradient(const emlrtStack *sp, const emxArray_real_T *x,
              emxArray_real_T *varargout_1, emxArray_real_T *varargout_2)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  const real_T *x_data;
  real_T *varargout_1_data;
  int32_T blocksize;
  int32_T hi;
  int32_T i;
  int32_T j;
  int32_T k;
  int32_T lo;
  int32_T mid;
  int32_T scalarLB_tmp;
  int32_T vectorUB_tmp;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  x_data = x->data;
  if ((x->size[0] == 1) || (x->size[1] == 1)) {
    emlrtErrorWithMessageIdR2018a(sp, &i_emlrtRTEI, "MATLAB:maxlhs",
                                  "MATLAB:maxlhs", 0);
  }
  if (x->size[1] < 2) {
    i = varargout_1->size[0] * varargout_1->size[1];
    varargout_1->size[0] = x->size[0];
    varargout_1->size[1] = x->size[1];
    emxEnsureCapacity_real_T(sp, varargout_1, i, &pc_emlrtRTEI);
    varargout_1_data = varargout_1->data;
    blocksize = x->size[0] * x->size[1];
    for (i = 0; i < blocksize; i++) {
      varargout_1_data[i] = 0.0;
    }
  } else {
    st.site = &kc_emlrtRSI;
    blocksize = x->size[0];
    i = varargout_1->size[0] * varargout_1->size[1];
    varargout_1->size[0] = x->size[0];
    varargout_1->size[1] = x->size[1];
    emxEnsureCapacity_real_T(&st, varargout_1, i, &qc_emlrtRTEI);
    varargout_1_data = varargout_1->data;
    b_st.site = &lc_emlrtRSI;
    if (x->size[0] > 2147483646) {
      c_st.site = &ib_emlrtRSI;
      check_forloop_overflow_error(&c_st);
    }
    scalarLB_tmp = (x->size[0] / 2) << 1;
    vectorUB_tmp = scalarLB_tmp - 2;
    for (k = 0; k <= vectorUB_tmp; k += 2) {
      _mm_storeu_pd(&varargout_1_data[k],
                    _mm_sub_pd(_mm_loadu_pd(&x_data[blocksize + k]),
                               _mm_loadu_pd(&x_data[k])));
    }
    for (k = scalarLB_tmp; k < blocksize; k++) {
      varargout_1_data[k] = x_data[blocksize + k] - x_data[k];
    }
    i = x->size[1] - 1;
    b_st.site = &mc_emlrtRSI;
    for (j = 2; j <= i; j++) {
      lo = (j - 2) * blocksize;
      mid = (j - 1) * blocksize;
      hi = j * blocksize;
      b_st.site = &nc_emlrtRSI;
      if (blocksize > 2147483646) {
        c_st.site = &ib_emlrtRSI;
        check_forloop_overflow_error(&c_st);
      }
      for (k = 0; k <= vectorUB_tmp; k += 2) {
        _mm_storeu_pd(&varargout_1_data[mid + k],
                      _mm_div_pd(_mm_sub_pd(_mm_loadu_pd(&x_data[hi + k]),
                                            _mm_loadu_pd(&x_data[lo + k])),
                                 _mm_set1_pd(2.0)));
      }
      for (k = scalarLB_tmp; k < blocksize; k++) {
        varargout_1_data[mid + k] = (x_data[hi + k] - x_data[lo + k]) / 2.0;
      }
    }
    lo = (x->size[1] - 2) * x->size[0];
    hi = (x->size[1] - 1) * x->size[0] - 1;
    b_st.site = &oc_emlrtRSI;
    for (k = 0; k <= vectorUB_tmp; k += 2) {
      i = (hi + k) + 1;
      _mm_storeu_pd(
          &varargout_1_data[i],
          _mm_sub_pd(_mm_loadu_pd(&x_data[i]), _mm_loadu_pd(&x_data[lo + k])));
    }
    for (k = scalarLB_tmp; k < blocksize; k++) {
      i = (hi + k) + 1;
      varargout_1_data[i] = x_data[i] - x_data[lo + k];
    }
  }
  if (x->size[0] < 2) {
    i = varargout_2->size[0] * varargout_2->size[1];
    varargout_2->size[0] = x->size[0];
    varargout_2->size[1] = x->size[1];
    emxEnsureCapacity_real_T(sp, varargout_2, i, &pc_emlrtRTEI);
    varargout_1_data = varargout_2->data;
    blocksize = x->size[0] * x->size[1];
    for (i = 0; i < blocksize; i++) {
      varargout_1_data[i] = 0.0;
    }
  } else {
    st.site = &kc_emlrtRSI;
    mid = x->size[0];
    hi = x->size[1];
    i = varargout_2->size[0] * varargout_2->size[1];
    varargout_2->size[0] = x->size[0];
    varargout_2->size[1] = x->size[1];
    emxEnsureCapacity_real_T(&st, varargout_2, i, &qc_emlrtRTEI);
    varargout_1_data = varargout_2->data;
    b_st.site = &pc_emlrtRSI;
    if (x->size[1] > 2147483646) {
      c_st.site = &ib_emlrtRSI;
      check_forloop_overflow_error(&c_st);
    }
    for (k = 0; k < hi; k++) {
      blocksize = k * mid;
      varargout_1_data[blocksize] = x_data[blocksize + 1] - x_data[blocksize];
      i = mid - 1;
      b_st.site = &mc_emlrtRSI;
      scalarLB_tmp = (((mid - 2) / 2) << 1) + 2;
      vectorUB_tmp = scalarLB_tmp - 2;
      for (j = 2; j <= vectorUB_tmp; j += 2) {
        lo = blocksize + j;
        _mm_storeu_pd(&varargout_1_data[lo - 1],
                      _mm_div_pd(_mm_sub_pd(_mm_loadu_pd(&x_data[lo]),
                                            _mm_loadu_pd(&x_data[lo - 2])),
                                 _mm_set1_pd(2.0)));
      }
      for (j = scalarLB_tmp; j <= i; j++) {
        lo = blocksize + j;
        varargout_1_data[lo - 1] = (x_data[lo] - x_data[lo - 2]) / 2.0;
      }
      blocksize += mid;
      varargout_1_data[blocksize - 1] =
          x_data[blocksize - 1] - x_data[blocksize - 2];
    }
  }
}

/* End of code generation (gradient.c) */
