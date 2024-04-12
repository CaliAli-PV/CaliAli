/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_register_in_lite_api.c
 *
 * Code generation for function '_coder_register_in_lite_api'
 *
 */

/* Include files */
#include "_coder_register_in_lite_api.h"
#include "register_in_lite.h"
#include "register_in_lite_data.h"
#include "register_in_lite_emxutil.h"
#include "register_in_lite_types.h"
#include "rt_nonfinite.h"

/* Variable Definitions */
static emlrtRTEInfo td_emlrtRTEI = {
    1,                             /* lineNo */
    1,                             /* colNo */
    "_coder_register_in_lite_api", /* fName */
    ""                             /* pName */
};

/* Function Declarations */
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                               const emlrtMsgIdentifier *parentId,
                               emxArray_uint8_T *y);

static const mxArray *b_emlrt_marshallOut(void);

static void c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *opt,
                               const char_T *identifier, struct0_T *y);

static void d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                               const emlrtMsgIdentifier *parentId,
                               struct0_T *y);

static real_T e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                 const emlrtMsgIdentifier *parentId);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *F,
                             const char_T *identifier, emxArray_uint8_T *y);

static const mxArray *emlrt_marshallOut(const emxArray_real_T *u);

static void f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               emxArray_uint8_T *ret);

static real_T g_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId);

/* Function Definitions */
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                               const emlrtMsgIdentifier *parentId,
                               emxArray_uint8_T *y)
{
  f_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static const mxArray *b_emlrt_marshallOut(void)
{
  const mxArray *y;
  int32_T iv[2];
  y = NULL;
  iv[0] = 0;
  iv[1] = 0;
  emlrtAssign(&y, emlrtCreateCellArrayR2014a(2, &iv[0]));
  return y;
}

static void c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *opt,
                               const char_T *identifier, struct0_T *y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  d_emlrt_marshallIn(sp, emlrtAlias(opt), &thisId, y);
  emlrtDestroyArray(&opt);
}

static void d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                               const emlrtMsgIdentifier *parentId, struct0_T *y)
{
  static const int32_T dims = 0;
  static const char_T *fieldNames[9] = {
      "stop_criterium", "imagepad",        "niter",
      "sigma_fluid",    "sigma_diffusion", "sigma_i",
      "sigma_x",        "do_display",      "do_plotenergy"};
  emlrtMsgIdentifier thisId;
  thisId.fParent = parentId;
  thisId.bParentIsCell = false;
  emlrtCheckStructR2012b((emlrtConstCTX)sp, parentId, u, 9,
                         (const char_T **)&fieldNames[0], 0U,
                         (const void *)&dims);
  thisId.fIdentifier = "stop_criterium";
  y->stop_criterium =
      e_emlrt_marshallIn(sp,
                         emlrtAlias(emlrtGetFieldR2017b((emlrtConstCTX)sp, u, 0,
                                                        0, "stop_criterium")),
                         &thisId);
  thisId.fIdentifier = "imagepad";
  y->imagepad = e_emlrt_marshallIn(
      sp,
      emlrtAlias(emlrtGetFieldR2017b((emlrtConstCTX)sp, u, 0, 1, "imagepad")),
      &thisId);
  thisId.fIdentifier = "niter";
  y->niter = e_emlrt_marshallIn(
      sp, emlrtAlias(emlrtGetFieldR2017b((emlrtConstCTX)sp, u, 0, 2, "niter")),
      &thisId);
  thisId.fIdentifier = "sigma_fluid";
  y->sigma_fluid =
      e_emlrt_marshallIn(sp,
                         emlrtAlias(emlrtGetFieldR2017b((emlrtConstCTX)sp, u, 0,
                                                        3, "sigma_fluid")),
                         &thisId);
  thisId.fIdentifier = "sigma_diffusion";
  y->sigma_diffusion =
      e_emlrt_marshallIn(sp,
                         emlrtAlias(emlrtGetFieldR2017b((emlrtConstCTX)sp, u, 0,
                                                        4, "sigma_diffusion")),
                         &thisId);
  thisId.fIdentifier = "sigma_i";
  y->sigma_i = e_emlrt_marshallIn(
      sp,
      emlrtAlias(emlrtGetFieldR2017b((emlrtConstCTX)sp, u, 0, 5, "sigma_i")),
      &thisId);
  thisId.fIdentifier = "sigma_x";
  y->sigma_x = e_emlrt_marshallIn(
      sp,
      emlrtAlias(emlrtGetFieldR2017b((emlrtConstCTX)sp, u, 0, 6, "sigma_x")),
      &thisId);
  thisId.fIdentifier = "do_display";
  y->do_display = e_emlrt_marshallIn(
      sp,
      emlrtAlias(emlrtGetFieldR2017b((emlrtConstCTX)sp, u, 0, 7, "do_display")),
      &thisId);
  thisId.fIdentifier = "do_plotenergy";
  y->do_plotenergy =
      e_emlrt_marshallIn(sp,
                         emlrtAlias(emlrtGetFieldR2017b((emlrtConstCTX)sp, u, 0,
                                                        8, "do_plotenergy")),
                         &thisId);
  emlrtDestroyArray(&u);
}

static real_T e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                 const emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = g_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *F,
                             const char_T *identifier, emxArray_uint8_T *y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  b_emlrt_marshallIn(sp, emlrtAlias(F), &thisId, y);
  emlrtDestroyArray(&F);
}

static const mxArray *emlrt_marshallOut(const emxArray_real_T *u)
{
  static const int32_T iv[2] = {0, 0};
  const mxArray *m;
  const mxArray *y;
  const real_T *u_data;
  u_data = u->data;
  y = NULL;
  m = emlrtCreateNumericArray(2, (const void *)&iv[0], mxDOUBLE_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m, (void *)&u_data[0]);
  emlrtSetDimensions((mxArray *)m, &u->size[0], 2);
  emlrtAssign(&y, m);
  return y;
}

static void f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               emxArray_uint8_T *ret)
{
  static const int32_T dims[2] = {-1, -1};
  int32_T iv[2];
  int32_T i;
  boolean_T bv[2] = {true, true};
  emlrtCheckVsBuiltInR2012b((emlrtConstCTX)sp, msgId, src, "uint8", false, 2U,
                            (const void *)&dims[0], &bv[0], &iv[0]);
  ret->allocatedSize = iv[0] * iv[1];
  i = ret->size[0] * ret->size[1];
  ret->size[0] = iv[0];
  ret->size[1] = iv[1];
  emxEnsureCapacity_uint8_T(sp, ret, i, (emlrtRTEInfo *)NULL);
  ret->data = (uint8_T *)emlrtMxGetData(src);
  ret->canFreeData = false;
  emlrtDestroyArray(&src);
}

static real_T g_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims = 0;
  real_T ret;
  emlrtCheckBuiltInR2012b((emlrtConstCTX)sp, msgId, src, "double", false, 0U,
                          (const void *)&dims);
  ret = *(real_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

void register_in_lite_api(const mxArray *const prhs[3], int32_T nlhs,
                          const mxArray *plhs[7])
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  emxArray_real_T *Mp;
  emxArray_real_T *e;
  emxArray_real_T *sx;
  emxArray_real_T *sy;
  emxArray_real_T *vx;
  emxArray_real_T *vy;
  emxArray_uint8_T *F;
  emxArray_uint8_T *M;
  struct0_T opt;
  st.tls = emlrtRootTLSGlobal;
  emlrtHeapReferenceStackEnterFcnR2012b(&st);
  /* Marshall function inputs */
  emxInit_uint8_T(&st, &F, &td_emlrtRTEI);
  F->canFreeData = false;
  emlrt_marshallIn(&st, emlrtAlias(prhs[0]), "F", F);
  emxInit_uint8_T(&st, &M, &td_emlrtRTEI);
  M->canFreeData = false;
  emlrt_marshallIn(&st, emlrtAlias(prhs[1]), "M", M);
  c_emlrt_marshallIn(&st, emlrtAliasP(prhs[2]), "opt", &opt);
  /* Invoke the target function */
  emxInit_real_T(&st, &Mp, 2, &td_emlrtRTEI);
  emxInit_real_T(&st, &sx, 2, &td_emlrtRTEI);
  emxInit_real_T(&st, &sy, 2, &td_emlrtRTEI);
  emxInit_real_T(&st, &vx, 2, &td_emlrtRTEI);
  emxInit_real_T(&st, &vy, 2, &td_emlrtRTEI);
  emxInit_real_T(&st, &e, 2, &td_emlrtRTEI);
  register_in_lite(&st, F, M, &opt, Mp, sx, sy, vx, vy, e);
  emxFree_uint8_T(&st, &M);
  emxFree_uint8_T(&st, &F);
  /* Marshall function outputs */
  Mp->canFreeData = false;
  plhs[0] = emlrt_marshallOut(Mp);
  emxFree_real_T(&st, &Mp);
  if (nlhs > 1) {
    sx->canFreeData = false;
    plhs[1] = emlrt_marshallOut(sx);
  }
  emxFree_real_T(&st, &sx);
  if (nlhs > 2) {
    sy->canFreeData = false;
    plhs[2] = emlrt_marshallOut(sy);
  }
  emxFree_real_T(&st, &sy);
  if (nlhs > 3) {
    vx->canFreeData = false;
    plhs[3] = emlrt_marshallOut(vx);
  }
  emxFree_real_T(&st, &vx);
  if (nlhs > 4) {
    vy->canFreeData = false;
    plhs[4] = emlrt_marshallOut(vy);
  }
  emxFree_real_T(&st, &vy);
  if (nlhs > 5) {
    plhs[5] = b_emlrt_marshallOut();
  }
  if (nlhs > 6) {
    e->canFreeData = false;
    plhs[6] = emlrt_marshallOut(e);
  }
  emxFree_real_T(&st, &e);
  emlrtHeapReferenceStackLeaveFcnR2012b(&st);
}

/* End of code generation (_coder_register_in_lite_api.c) */
