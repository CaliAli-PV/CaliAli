/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * ndgrid.c
 *
 * Code generation for function 'ndgrid'
 *
 */

/* Include files */
#include "ndgrid.h"
#include "eml_int_forloop_overflow_check.h"
#include "register_in_lite_data.h"
#include "register_in_lite_emxutil.h"
#include "register_in_lite_types.h"
#include "rt_nonfinite.h"

/* Variable Definitions */
static emlrtRSInfo ob_emlrtRSI = {
    43,       /* lineNo */
    "ndgrid", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\ndgrid.m" /* pathName
                                                                         */
};

static emlrtRSInfo pb_emlrtRSI = {
    59,       /* lineNo */
    "looper", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\ndgrid.m" /* pathName
                                                                         */
};

static emlrtRSInfo qb_emlrtRSI = {
    63,       /* lineNo */
    "looper", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\ndgrid.m" /* pathName
                                                                         */
};

static emlrtRTEInfo lc_emlrtRTEI = {
    41,       /* lineNo */
    35,       /* colNo */
    "ndgrid", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\ndgrid.m" /* pName
                                                                         */
};

/* Function Definitions */
void ndgrid(const emlrtStack *sp, const emxArray_real_T *varargin_1,
            const emxArray_real_T *varargin_2, emxArray_real_T *varargout_1,
            emxArray_real_T *varargout_2)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack st;
  const real_T *varargin_1_data;
  const real_T *varargin_2_data;
  real_T *varargout_1_data;
  int32_T b;
  int32_T b_b;
  int32_T b_k;
  int32_T k;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  varargin_2_data = varargin_2->data;
  varargin_1_data = varargin_1->data;
  b = varargout_1->size[0] * varargout_1->size[1];
  varargout_1->size[0] = varargin_1->size[1];
  varargout_1->size[1] = varargin_2->size[1];
  emxEnsureCapacity_real_T(sp, varargout_1, b, &lc_emlrtRTEI);
  varargout_1_data = varargout_1->data;
  st.site = &ob_emlrtRSI;
  b = varargin_2->size[1];
  b_st.site = &pb_emlrtRSI;
  if (varargin_2->size[1] > 2147483646) {
    c_st.site = &ib_emlrtRSI;
    check_forloop_overflow_error(&c_st);
  }
  for (k = 0; k < b; k++) {
    b_st.site = &qb_emlrtRSI;
    b_b = varargout_1->size[0];
    c_st.site = &pb_emlrtRSI;
    if (varargout_1->size[0] > 2147483646) {
      d_st.site = &ib_emlrtRSI;
      check_forloop_overflow_error(&d_st);
    }
    for (b_k = 0; b_k < b_b; b_k++) {
      varargout_1_data[b_k + varargout_1->size[0] * k] = varargin_1_data[b_k];
    }
  }
  b = varargout_2->size[0] * varargout_2->size[1];
  varargout_2->size[0] = varargin_1->size[1];
  varargout_2->size[1] = varargin_2->size[1];
  emxEnsureCapacity_real_T(sp, varargout_2, b, &lc_emlrtRTEI);
  varargout_1_data = varargout_2->data;
  st.site = &ob_emlrtRSI;
  b = varargin_2->size[1];
  b_st.site = &pb_emlrtRSI;
  if (varargin_2->size[1] > 2147483646) {
    c_st.site = &ib_emlrtRSI;
    check_forloop_overflow_error(&c_st);
  }
  for (k = 0; k < b; k++) {
    b_st.site = &qb_emlrtRSI;
    b_b = varargout_2->size[0];
    c_st.site = &pb_emlrtRSI;
    if (varargout_2->size[0] > 2147483646) {
      d_st.site = &ib_emlrtRSI;
      check_forloop_overflow_error(&d_st);
    }
    for (b_k = 0; b_k < b_b; b_k++) {
      varargout_1_data[b_k + varargout_2->size[0] * k] = varargin_2_data[k];
    }
  }
}

/* End of code generation (ndgrid.c) */
