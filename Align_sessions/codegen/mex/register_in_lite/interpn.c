/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * interpn.c
 *
 * Code generation for function 'interpn'
 *
 */

/* Include files */
#include "interpn.h"
#include "bsearch.h"
#include "eml_int_forloop_overflow_check.h"
#include "indexShapeCheck.h"
#include "register_in_lite_data.h"
#include "register_in_lite_emxutil.h"
#include "register_in_lite_types.h"
#include "rt_nonfinite.h"
#include "omp.h"

/* Variable Definitions */
static emlrtRSInfo rb_emlrtRSI = {
    104,       /* lineNo */
    "interpn", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interpn.m" /* pathName
                                                                            */
};

static emlrtRSInfo sb_emlrtRSI = {
    108,       /* lineNo */
    "interpn", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interpn.m" /* pathName
                                                                            */
};

static emlrtRSInfo tb_emlrtRSI = {
    111,       /* lineNo */
    "interpn", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interpn.m" /* pathName
                                                                            */
};

static emlrtRSInfo ub_emlrtRSI = {
    44,        /* lineNo */
    "isplaid", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\private\\isplai"
    "d.m" /* pathName */
};

static emlrtRSInfo vb_emlrtRSI = {
    47,        /* lineNo */
    "isplaid", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\private\\isplai"
    "d.m" /* pathName */
};

static emlrtRSInfo wb_emlrtRSI = {
    49,        /* lineNo */
    "isplaid", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\private\\isplai"
    "d.m" /* pathName */
};

static emlrtRSInfo xb_emlrtRSI = {
    22,           /* lineNo */
    "unmeshgrid", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\private\\unmesh"
    "grid.m" /* pathName */
};

static emlrtRSInfo yb_emlrtRSI = {
    156,               /* lineNo */
    "interpnDispatch", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interpn.m" /* pathName
                                                                            */
};

static emlrtRSInfo ac_emlrtRSI = {
    209,            /* lineNo */
    "interpnLocal", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interpn.m" /* pathName
                                                                            */
};

static emlrtRSInfo bc_emlrtRSI = {
    211,            /* lineNo */
    "interpnLocal", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interpn.m" /* pathName
                                                                            */
};

static emlrtRSInfo cc_emlrtRSI = {
    35,                     /* lineNo */
    "interpnLocalLoopBody", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\shared\\coder\\coder\\+coder\\+internal\\+"
    "interpolate\\interpnLocalLoopBody.m" /* pathName */
};

static emlrtRTEInfo c_emlrtRTEI = {
    100,       /* lineNo */
    21,        /* colNo */
    "interpn", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interpn.m" /* pName
                                                                            */
};

static emlrtRTEInfo d_emlrtRTEI = {
    104,       /* lineNo */
    35,        /* colNo */
    "interpn", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interpn.m" /* pName
                                                                            */
};

static emlrtRTEInfo e_emlrtRTEI = {
    28,           /* lineNo */
    15,           /* colNo */
    "unmeshgrid", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\private\\unmesh"
    "grid.m" /* pName */
};

static emlrtRTEInfo f_emlrtRTEI = {
    143,               /* lineNo */
    27,                /* colNo */
    "interpnDispatch", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interpn.m" /* pName
                                                                            */
};

static emlrtRTEInfo g_emlrtRTEI = {
    146,               /* lineNo */
    9,                 /* colNo */
    "interpnDispatch", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interpn.m" /* pName
                                                                            */
};

static emlrtRTEInfo mc_emlrtRTEI = {
    21,           /* lineNo */
    24,           /* colNo */
    "unmeshgrid", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\private\\unmesh"
    "grid.m" /* pName */
};

static emlrtRTEInfo nc_emlrtRTEI = {
    106,       /* lineNo */
    13,        /* colNo */
    "interpn", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interpn.m" /* pName
                                                                            */
};

static emlrtRTEInfo oc_emlrtRTEI = {
    178,       /* lineNo */
    21,        /* colNo */
    "interpn", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\polyfun\\interpn.m" /* pName
                                                                            */
};

/* Function Declarations */
static void interpnLocal(const emlrtStack *sp, const emxArray_real_T *V,
                         const emxArray_real_T *varargin_1,
                         const emxArray_real_T *varargin_2,
                         const emxArray_real_T *varargin_3,
                         const emxArray_real_T *varargin_4,
                         emxArray_real_T *Vq);

/* Function Definitions */
static void interpnLocal(const emlrtStack *sp, const emxArray_real_T *V,
                         const emxArray_real_T *varargin_1,
                         const emxArray_real_T *varargin_2,
                         const emxArray_real_T *varargin_3,
                         const emxArray_real_T *varargin_4, emxArray_real_T *Vq)
{
  jmp_buf emlrtJBEnviron;
  jmp_buf *volatile emlrtJBStack;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack st;
  real_T vbox[4];
  real_T xbox[4];
  real_T Xq[2];
  real_T xmax[2];
  real_T xmin[2];
  const real_T *V_data;
  const real_T *varargin_1_data;
  const real_T *varargin_2_data;
  const real_T *varargin_3_data;
  const real_T *varargin_4_data;
  real_T Xq_tmp;
  real_T b_d;
  real_T r;
  real_T *Vq_data;
  int32_T vbbidx[4];
  int32_T stride[2];
  int32_T b_k;
  int32_T d;
  int32_T interpnLocal_numThreads;
  int32_T k;
  int32_T m;
  int32_T n;
  int32_T voffset;
  boolean_T b;
  boolean_T emlrtHadParallelError = false;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  varargin_4_data = varargin_4->data;
  varargin_3_data = varargin_3->data;
  varargin_2_data = varargin_2->data;
  varargin_1_data = varargin_1->data;
  V_data = V->data;
  n = Vq->size[0] * Vq->size[1];
  Vq->size[0] = varargin_1->size[0];
  Vq->size[1] = varargin_1->size[1];
  emxEnsureCapacity_real_T(sp, Vq, n, &oc_emlrtRTEI);
  Vq_data = Vq->data;
  n = varargin_1->size[0] * varargin_1->size[1];
  stride[1] = V->size[0];
  vbbidx[2] = V->size[0] + 1;
  vbbidx[3] = V->size[0] + 2;
  xmin[0] = varargin_3_data[0];
  xmax[0] = varargin_3_data[varargin_3->size[1] - 1];
  xmin[1] = varargin_4_data[0];
  xmax[1] = varargin_4_data[varargin_4->size[1] - 1];
  st.site = &ac_emlrtRSI;
  if (n > 2147483646) {
    b_st.site = &ib_emlrtRSI;
    check_forloop_overflow_error(&b_st);
  }
  n--;
  emlrtEnterParallelRegion((emlrtCTX)sp, omp_in_parallel());
  emlrtPushJmpBuf((emlrtCTX)sp, &emlrtJBStack);
  interpnLocal_numThreads = emlrtAllocRegionTLSs(
      sp->tls, omp_in_parallel(), omp_get_max_threads(), omp_get_num_procs());
#pragma omp parallel num_threads(interpnLocal_numThreads) private(             \
    Xq, emlrtJBEnviron, e_st, r, Xq_tmp, b, b_k, voffset, xbox, vbox, d, m,    \
    b_d) firstprivate(c_st, d_st, emlrtHadParallelError)
  {
    if (setjmp(emlrtJBEnviron) == 0) {
      c_st.prev = sp;
      c_st.tls = emlrtAllocTLS((emlrtCTX)sp, omp_get_thread_num());
      c_st.site = NULL;
      emlrtSetJmpBuf(&c_st, &emlrtJBEnviron);
      d_st.prev = &c_st;
      d_st.tls = c_st.tls;
      e_st.prev = &d_st;
      e_st.tls = d_st.tls;
    } else {
      emlrtHadParallelError = true;
    }
#pragma omp for nowait
    for (k = 0; k <= n; k++) {
      if (emlrtHadParallelError) {
        continue;
      }
      if (setjmp(emlrtJBEnviron) == 0) {
        r = varargin_1_data[k];
        Xq[0] = r;
        Xq_tmp = varargin_2_data[k];
        Xq[1] = Xq_tmp;
        d_st.site = &bc_emlrtRSI;
        b = true;
        if ((!(r >= xmin[0])) || (!(r <= xmax[0]))) {
          b = false;
        }
        if ((!b) || (!(Xq_tmp >= xmin[1])) || (!(Xq_tmp <= xmax[1]))) {
          b = false;
        }
        if (!b) {
          Vq_data[k] = 0.0;
        } else {
          b_k = b_bsearch(varargin_3, r);
          voffset = b_k - 2;
          xbox[0] = varargin_3_data[b_k - 1];
          xbox[1] = varargin_3_data[b_k];
          b_k = b_bsearch(varargin_4, Xq_tmp);
          voffset += (b_k - 1) * stride[1];
          xbox[2] = varargin_4_data[b_k - 1];
          xbox[3] = varargin_4_data[b_k];
          e_st.site = &cc_emlrtRSI;
          indexShapeCheck(&e_st, V->size);
          vbox[0] = V_data[voffset + 1];
          vbox[1] = V_data[voffset + 2];
          vbox[2] = V_data[vbbidx[2] + voffset];
          vbox[3] = V_data[vbbidx[3] + voffset];
          for (d = 0; d < 2; d++) {
            m = (1 << (1 - d)) - 1;
            voffset = d << 1;
            r = xbox[voffset];
            Xq_tmp = Xq[d];
            if (Xq_tmp == r) {
              for (b_k = 0; b_k <= m; b_k++) {
                vbox[b_k] = vbox[((b_k + 1) << 1) - 2];
              }
            } else {
              b_d = xbox[voffset + 1];
              if (Xq_tmp == b_d) {
                for (b_k = 0; b_k <= m; b_k++) {
                  vbox[b_k] = vbox[((b_k + 1) << 1) - 1];
                }
              } else {
                r = (Xq_tmp - r) / (b_d - r);
                for (b_k = 0; b_k <= m; b_k++) {
                  voffset = ((b_k + 1) << 1) - 1;
                  vbox[b_k] = (1.0 - r) * vbox[voffset - 1] + r * vbox[voffset];
                }
              }
            }
          }
          Vq_data[k] = vbox[0];
        }
      } else {
        emlrtHadParallelError = true;
      }
    }
  }
  emlrtPopJmpBuf((emlrtCTX)sp, &emlrtJBStack);
  emlrtExitParallelRegion((emlrtCTX)sp, omp_in_parallel());
}

void interpn(const emlrtStack *sp, const emxArray_real_T *varargin_1,
             const emxArray_real_T *varargin_2,
             const emxArray_real_T *varargin_3,
             const emxArray_real_T *varargin_4,
             const emxArray_real_T *varargin_5, emxArray_real_T *Vq)
{
  cell_wrap_3 gridv[2];
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  const real_T *varargin_1_data;
  const real_T *varargin_2_data;
  int32_T element_offset;
  int32_T nx;
  uint32_T b_varargin_1[2];
  uint32_T sz[2];
  boolean_T b_p;
  boolean_T exitg1;
  boolean_T p;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  varargin_2_data = varargin_2->data;
  varargin_1_data = varargin_1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  if (varargin_1->size[0] != varargin_3->size[0]) {
    emlrtErrorWithMessageIdR2018a(
        sp, &c_emlrtRTEI, "MATLAB:mathcgeo_catalog:MixedGridCoordSizeErrId",
        "MATLAB:mathcgeo_catalog:MixedGridCoordSizeErrId", 0);
  }
  if (varargin_2->size[1] != varargin_3->size[1]) {
    emlrtErrorWithMessageIdR2018a(
        sp, &c_emlrtRTEI, "MATLAB:mathcgeo_catalog:MixedGridCoordSizeErrId",
        "MATLAB:mathcgeo_catalog:MixedGridCoordSizeErrId", 0);
  }
  st.site = &rb_emlrtRSI;
  p = false;
  nx = varargin_1->size[0] * varargin_1->size[1];
  sz[0] = (uint32_T)varargin_1->size[0];
  b_varargin_1[0] = (uint32_T)varargin_1->size[0];
  sz[1] = (uint32_T)varargin_1->size[1];
  b_varargin_1[1] = (uint32_T)varargin_1->size[1];
  b_p = true;
  element_offset = 0;
  exitg1 = false;
  while ((!exitg1) && (element_offset < 2)) {
    if ((int32_T)b_varargin_1[element_offset] != (int32_T)sz[element_offset]) {
      b_p = false;
      exitg1 = true;
    } else {
      element_offset++;
    }
  }
  if (b_p) {
    int32_T i;
    boolean_T guard1;
    guard1 = false;
    if (nx > 1) {
      int32_T exitg5;
      b_st.site = &ub_emlrtRSI;
      if (varargin_1->size[0] > 2147483646) {
        c_st.site = &ib_emlrtRSI;
        check_forloop_overflow_error(&c_st);
      }
      i = 0;
      do {
        exitg5 = 0;
        if (i <= varargin_1->size[0] - 1) {
          int32_T exitg4;
          b_st.site = &vb_emlrtRSI;
          if (varargin_1->size[1] > 2147483646) {
            c_st.site = &ib_emlrtRSI;
            check_forloop_overflow_error(&c_st);
          }
          element_offset = 0;
          do {
            exitg4 = 0;
            if (element_offset <= varargin_1->size[1] - 1) {
              if (!(varargin_1_data[i] ==
                    varargin_1_data[i +
                                    element_offset * varargin_1->size[0]])) {
                exitg4 = 1;
              } else {
                element_offset++;
              }
            } else {
              i++;
              exitg4 = 2;
            }
          } while (exitg4 == 0);
          if (exitg4 == 1) {
            exitg5 = 1;
          }
        } else {
          exitg5 = 2;
        }
      } while (exitg5 == 0);
      if (exitg5 != 1) {
        guard1 = true;
      }
    } else {
      guard1 = true;
    }
    if (guard1) {
      b_varargin_1[0] = (uint32_T)varargin_2->size[0];
      b_varargin_1[1] = (uint32_T)varargin_2->size[1];
      b_p = true;
      element_offset = 0;
      exitg1 = false;
      while ((!exitg1) && (element_offset < 2)) {
        if ((int32_T)b_varargin_1[element_offset] !=
            (int32_T)sz[element_offset]) {
          b_p = false;
          exitg1 = true;
        } else {
          element_offset++;
        }
      }
      if (b_p) {
        if (nx > 1) {
          b_st.site = &ub_emlrtRSI;
          if (varargin_1->size[1] > 2147483646) {
            c_st.site = &ib_emlrtRSI;
            check_forloop_overflow_error(&c_st);
          }
          i = 0;
          int32_T exitg3;
          do {
            exitg3 = 0;
            if (i <= varargin_1->size[1] - 1) {
              int32_T exitg2;
              element_offset = i * varargin_1->size[0];
              b_st.site = &wb_emlrtRSI;
              if (varargin_1->size[0] > 2147483646) {
                c_st.site = &ib_emlrtRSI;
                check_forloop_overflow_error(&c_st);
              }
              nx = 0;
              do {
                exitg2 = 0;
                if (nx <= varargin_1->size[0] - 1) {
                  if (!(varargin_2_data[element_offset] ==
                        varargin_2_data[element_offset + nx])) {
                    exitg2 = 1;
                  } else {
                    nx++;
                  }
                } else {
                  i++;
                  exitg2 = 2;
                }
              } while (exitg2 == 0);
              if (exitg2 == 1) {
                exitg3 = 1;
              }
            } else {
              p = true;
              exitg3 = 1;
            }
          } while (exitg3 == 0);
        } else {
          p = true;
        }
      }
    }
  }
  if (!p) {
    emlrtErrorWithMessageIdR2018a(sp, &d_emlrtRTEI,
                                  "MATLAB:mathcgeo_catalog:NotNdGridErrId",
                                  "MATLAB:mathcgeo_catalog:NotNdGridErrId", 0);
  }
  st.site = &sb_emlrtRSI;
  nx = varargin_1->size[0];
  emxInitMatrix_cell_wrap_3(&st, gridv, &nc_emlrtRTEI);
  element_offset = gridv[0].f1->size[0] * gridv[0].f1->size[1];
  gridv[0].f1->size[0] = 1;
  gridv[0].f1->size[1] = varargin_1->size[0];
  emxEnsureCapacity_real_T(&st, gridv[0].f1, element_offset, &mc_emlrtRTEI);
  b_st.site = &xb_emlrtRSI;
  if (varargin_1->size[0] > 2147483646) {
    c_st.site = &ib_emlrtRSI;
    check_forloop_overflow_error(&c_st);
  }
  for (element_offset = 0; element_offset < nx; element_offset++) {
    gridv[0].f1->data[element_offset] = varargin_1_data[element_offset];
  }
  nx = gridv[0].f1->size[1];
  if (nx >= 2) {
    element_offset = 0;
    exitg1 = false;
    while ((!exitg1) && (element_offset <= nx - 2)) {
      if (!(gridv[0].f1->data[element_offset] <
            gridv[0].f1->data[element_offset + 1])) {
        emlrtErrorWithMessageIdR2018a(&st, &e_emlrtRTEI,
                                      "Coder:toolbox:NonIncreasing",
                                      "Coder:toolbox:NonIncreasing", 0);
      } else {
        element_offset++;
      }
    }
  }
  st.site = &sb_emlrtRSI;
  nx = varargin_2->size[1];
  element_offset = gridv[1].f1->size[0] * gridv[1].f1->size[1];
  gridv[1].f1->size[0] = 1;
  gridv[1].f1->size[1] = varargin_2->size[1];
  emxEnsureCapacity_real_T(&st, gridv[1].f1, element_offset, &mc_emlrtRTEI);
  b_st.site = &xb_emlrtRSI;
  if (varargin_2->size[1] > 2147483646) {
    c_st.site = &ib_emlrtRSI;
    check_forloop_overflow_error(&c_st);
  }
  for (element_offset = 0; element_offset < nx; element_offset++) {
    gridv[1].f1->data[element_offset] =
        varargin_2_data[varargin_2->size[0] * element_offset];
  }
  nx = gridv[1].f1->size[1];
  if (nx >= 2) {
    element_offset = 0;
    exitg1 = false;
    while ((!exitg1) && (element_offset <= nx - 2)) {
      if (!(gridv[1].f1->data[element_offset] <
            gridv[1].f1->data[element_offset + 1])) {
        emlrtErrorWithMessageIdR2018a(&st, &e_emlrtRTEI,
                                      "Coder:toolbox:NonIncreasing",
                                      "Coder:toolbox:NonIncreasing", 0);
      } else {
        element_offset++;
      }
    }
  }
  st.site = &tb_emlrtRSI;
  if (varargin_3->size[0] < 2) {
    emlrtErrorWithMessageIdR2018a(&st, &f_emlrtRTEI,
                                  "Coder:toolbox:NotEnoughPoints",
                                  "Coder:toolbox:NotEnoughPoints", 0);
  }
  b_varargin_1[0] = (uint32_T)varargin_4->size[0];
  sz[0] = (uint32_T)varargin_4->size[0];
  b_varargin_1[1] = (uint32_T)varargin_4->size[1];
  sz[1] = (uint32_T)varargin_4->size[1];
  p = true;
  element_offset = 0;
  exitg1 = false;
  while ((!exitg1) && (element_offset < 2)) {
    if ((int32_T)b_varargin_1[element_offset] != (int32_T)sz[element_offset]) {
      p = false;
      exitg1 = true;
    } else {
      element_offset++;
    }
  }
  if (!p) {
    emlrtErrorWithMessageIdR2018a(
        &st, &g_emlrtRTEI, "MATLAB:mathcgeo_catalog:InputMixSizeErrId",
        "MATLAB:mathcgeo_catalog:InputMixSizeErrId", 0);
  }
  if (varargin_3->size[1] < 2) {
    emlrtErrorWithMessageIdR2018a(&st, &f_emlrtRTEI,
                                  "Coder:toolbox:NotEnoughPoints",
                                  "Coder:toolbox:NotEnoughPoints", 0);
  }
  b_varargin_1[0] = (uint32_T)varargin_5->size[0];
  sz[0] = (uint32_T)varargin_4->size[0];
  b_varargin_1[1] = (uint32_T)varargin_5->size[1];
  sz[1] = (uint32_T)varargin_4->size[1];
  p = true;
  element_offset = 0;
  exitg1 = false;
  while ((!exitg1) && (element_offset < 2)) {
    if ((int32_T)b_varargin_1[element_offset] != (int32_T)sz[element_offset]) {
      p = false;
      exitg1 = true;
    } else {
      element_offset++;
    }
  }
  if (!p) {
    emlrtErrorWithMessageIdR2018a(
        &st, &g_emlrtRTEI, "MATLAB:mathcgeo_catalog:InputMixSizeErrId",
        "MATLAB:mathcgeo_catalog:InputMixSizeErrId", 0);
  }
  b_st.site = &yb_emlrtRSI;
  interpnLocal(&b_st, varargin_3, varargin_4, varargin_5, gridv[0].f1,
               gridv[1].f1, Vq);
  emxFreeMatrix_cell_wrap_3(&st, gridv);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

/* End of code generation (interpn.c) */
