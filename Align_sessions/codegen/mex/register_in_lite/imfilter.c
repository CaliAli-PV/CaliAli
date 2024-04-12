/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * imfilter.c
 *
 * Code generation for function 'imfilter'
 *
 */

/* Include files */
#include "imfilter.h"
#include "all.h"
#include "combineVectorElements.h"
#include "diag.h"
#include "eml_int_forloop_overflow_check.h"
#include "indexShapeCheck.h"
#include "register_in_lite_data.h"
#include "register_in_lite_emxutil.h"
#include "register_in_lite_types.h"
#include "rt_nonfinite.h"
#include "svd.h"
#include "libmwimfilter.h"
#include "libmwippfilter.h"
#include "mwmathutil.h"
#include <emmintrin.h>

/* Variable Definitions */
static emlrtRSInfo od_emlrtRSI = {
    55,         /* lineNo */
    "imfilter", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo pd_emlrtRSI = {
    59,         /* lineNo */
    "imfilter", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo qd_emlrtRSI = {
    64,         /* lineNo */
    "imfilter", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo rd_emlrtRSI = {
    66,         /* lineNo */
    "imfilter", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo sd_emlrtRSI = {
    67,         /* lineNo */
    "imfilter", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo td_emlrtRSI = {
    68,         /* lineNo */
    "imfilter", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo ud_emlrtRSI = {
    84,         /* lineNo */
    "imfilter", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo vd_emlrtRSI = {
    88,         /* lineNo */
    "imfilter", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo wd_emlrtRSI = {
    106,        /* lineNo */
    "imfilter", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo xd_emlrtRSI = {
    110,        /* lineNo */
    "imfilter", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo yd_emlrtRSI = {
    685,           /* lineNo */
    "isSeparable", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo ae_emlrtRSI = {
    688,           /* lineNo */
    "isSeparable", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo be_emlrtRSI = {
    691,           /* lineNo */
    "isSeparable", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo ce_emlrtRSI = {
    692,           /* lineNo */
    "isSeparable", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo de_emlrtRSI = {
    693,           /* lineNo */
    "isSeparable", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo ye_emlrtRSI = {
    15,    /* lineNo */
    "sum", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\sum.m" /* pathName
                                                                        */
};

static emlrtRSInfo cf_emlrtRSI = {
    858,        /* lineNo */
    "padImage", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo df_emlrtRSI = {
    20,         /* lineNo */
    "padarray", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m" /* pathName
                                                                       */
};

static emlrtRSInfo ef_emlrtRSI = {
    77,         /* lineNo */
    "padarray", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m" /* pathName
                                                                       */
};

static emlrtRSInfo ff_emlrtRSI = {
    91,         /* lineNo */
    "padarray", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m" /* pathName
                                                                       */
};

static emlrtRSInfo gf_emlrtRSI = {
    93,                   /* lineNo */
    "validateattributes", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\lang\\validateattributes"
    ".m" /* pathName */
};

static emlrtRSInfo hf_emlrtRSI = {
    28,       /* lineNo */
    "repmat", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m" /* pathName
                                                                         */
};

static emlrtRSInfo if_emlrtRSI = {
    685,           /* lineNo */
    "ConstantPad", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m" /* pathName
                                                                       */
};

static emlrtRSInfo jf_emlrtRSI = {
    700,           /* lineNo */
    "ConstantPad", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m" /* pathName
                                                                       */
};

static emlrtRSInfo kf_emlrtRSI = {
    928,                 /* lineNo */
    "filterPartOrWhole", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo lf_emlrtRSI = {
    1002,           /* lineNo */
    "imfiltercore", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo mf_emlrtRSI = {
    1030,               /* lineNo */
    "imfiltercoreAlgo", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo nf_emlrtRSI = {
    1042,               /* lineNo */
    "imfiltercoreAlgo", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo of_emlrtRSI = {
    908,                 /* lineNo */
    "filterPartOrWhole", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRTEInfo p_emlrtRTEI = {
    64,                   /* lineNo */
    15,                   /* colNo */
    "assertValidSizeArg", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\assertValidSizeArg.m" /* pName */
};

static emlrtRTEInfo q_emlrtRTEI = {
    49,                   /* lineNo */
    19,                   /* colNo */
    "assertValidSizeArg", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\assertValidSizeArg.m" /* pName */
};

static emlrtRTEInfo r_emlrtRTEI = {
    13,                /* lineNo */
    37,                /* colNo */
    "validateinteger", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "valattr\\validateinteger.m" /* pName */
};

static emlrtRTEInfo s_emlrtRTEI = {
    14,                    /* lineNo */
    37,                    /* colNo */
    "validatenonnegative", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "valattr\\validatenonnegative.m" /* pName */
};

static emlrtRTEInfo t_emlrtRTEI = {
    14,               /* lineNo */
    37,               /* colNo */
    "validatenonnan", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\+"
    "valattr\\validatenonnan.m" /* pName */
};

static emlrtBCInfo hb_emlrtBCI = {
    -1,            /* iFirst */
    -1,            /* iLast */
    680,           /* lineNo */
    19,            /* colNo */
    "",            /* aName */
    "ConstantPad", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo ib_emlrtBCI = {
    -1,            /* iFirst */
    -1,            /* iLast */
    680,           /* lineNo */
    21,            /* colNo */
    "",            /* aName */
    "ConstantPad", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo jb_emlrtBCI = {
    -1,            /* iFirst */
    -1,            /* iLast */
    687,           /* lineNo */
    19,            /* colNo */
    "",            /* aName */
    "ConstantPad", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo kb_emlrtBCI = {
    -1,            /* iFirst */
    -1,            /* iLast */
    687,           /* lineNo */
    21,            /* colNo */
    "",            /* aName */
    "ConstantPad", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo lb_emlrtBCI = {
    -1,            /* iFirst */
    -1,            /* iLast */
    694,           /* lineNo */
    19,            /* colNo */
    "",            /* aName */
    "ConstantPad", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo mb_emlrtBCI = {
    -1,            /* iFirst */
    -1,            /* iLast */
    694,           /* lineNo */
    21,            /* colNo */
    "",            /* aName */
    "ConstantPad", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo nb_emlrtBCI = {
    -1,            /* iFirst */
    -1,            /* iLast */
    724,           /* lineNo */
    102,           /* colNo */
    "",            /* aName */
    "ConstantPad", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo ob_emlrtBCI = {
    -1,            /* iFirst */
    -1,            /* iLast */
    724,           /* lineNo */
    104,           /* colNo */
    "",            /* aName */
    "ConstantPad", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo pb_emlrtBCI = {
    -1,            /* iFirst */
    -1,            /* iLast */
    724,           /* lineNo */
    19,            /* colNo */
    "",            /* aName */
    "ConstantPad", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo qb_emlrtBCI = {
    -1,            /* iFirst */
    -1,            /* iLast */
    724,           /* lineNo */
    58,            /* colNo */
    "",            /* aName */
    "ConstantPad", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo rb_emlrtBCI = {
    -1,            /* iFirst */
    -1,            /* iLast */
    701,           /* lineNo */
    19,            /* colNo */
    "",            /* aName */
    "ConstantPad", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo sb_emlrtBCI = {
    -1,            /* iFirst */
    -1,            /* iLast */
    701,           /* lineNo */
    21,            /* colNo */
    "",            /* aName */
    "ConstantPad", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtDCInfo eb_emlrtDCI = {
    31,       /* lineNo */
    14,       /* colNo */
    "repmat", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m", /* pName
                                                                          */
    4 /* checkKind */
};

static emlrtDCInfo fb_emlrtDCI = {
    533,           /* lineNo */
    35,            /* colNo */
    "ConstantPad", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    1 /* checkKind */
};

static emlrtDCInfo gb_emlrtDCI = {
    533,           /* lineNo */
    35,            /* colNo */
    "ConstantPad", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    4 /* checkKind */
};

static emlrtBCInfo tb_emlrtBCI = {
    -1,         /* iFirst */
    -1,         /* iLast */
    68,         /* lineNo */
    33,         /* colNo */
    "",         /* aName */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo ub_emlrtBCI = {
    -1,         /* iFirst */
    -1,         /* iLast */
    68,         /* lineNo */
    20,         /* colNo */
    "",         /* aName */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo vb_emlrtBCI = {
    -1,         /* iFirst */
    -1,         /* iLast */
    67,         /* lineNo */
    32,         /* colNo */
    "",         /* aName */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo wb_emlrtBCI = {
    -1,         /* iFirst */
    -1,         /* iLast */
    67,         /* lineNo */
    20,         /* colNo */
    "",         /* aName */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo xb_emlrtBCI = {
    -1,                  /* iFirst */
    -1,                  /* iLast */
    908,                 /* lineNo */
    23,                  /* colNo */
    "",                  /* aName */
    "filterPartOrWhole", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo yb_emlrtBCI = {
    -1,                  /* iFirst */
    -1,                  /* iLast */
    905,                 /* lineNo */
    27,                  /* colNo */
    "",                  /* aName */
    "filterPartOrWhole", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtRTEInfo rd_emlrtRTEI = {
    533,        /* lineNo */
    28,         /* colNo */
    "padarray", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\padarray.m" /* pName
                                                                       */
};

static emlrtRTEInfo sd_emlrtRTEI = {
    858,        /* lineNo */
    5,          /* colNo */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pName
                                                                       */
};

static emlrtRTEInfo se_emlrtRTEI = {
    37,         /* lineNo */
    5,          /* colNo */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pName
                                                                       */
};

static emlrtRTEInfo te_emlrtRTEI = {
    14,         /* lineNo */
    5,          /* colNo */
    "isfinite", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elmat\\isfinite.m" /* pName
                                                                           */
};

static emlrtRTEInfo ue_emlrtRTEI = {
    899,        /* lineNo */
    1,          /* colNo */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pName
                                                                       */
};

static emlrtRTEInfo ve_emlrtRTEI = {
    1,          /* lineNo */
    14,         /* colNo */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pName
                                                                       */
};

static emlrtRTEInfo we_emlrtRTEI = {
    67,         /* lineNo */
    9,          /* colNo */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pName
                                                                       */
};

static emlrtRTEInfo xe_emlrtRTEI = {
    68,         /* lineNo */
    9,          /* colNo */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pName
                                                                       */
};

static emlrtRTEInfo ye_emlrtRTEI = {
    1024,       /* lineNo */
    26,         /* colNo */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pName
                                                                       */
};

static emlrtRTEInfo af_emlrtRTEI = {
    693,        /* lineNo */
    16,         /* colNo */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pName
                                                                       */
};

static emlrtRTEInfo bf_emlrtRTEI = {
    905,        /* lineNo */
    9,          /* colNo */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pName
                                                                       */
};

static emlrtRTEInfo cf_emlrtRTEI = {
    1002,       /* lineNo */
    28,         /* colNo */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pName
                                                                       */
};

static emlrtRTEInfo df_emlrtRTEI = {
    59,         /* lineNo */
    9,          /* colNo */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pName
                                                                       */
};

static emlrtRTEInfo ef_emlrtRTEI = {
    171,                   /* lineNo */
    38,                    /* colNo */
    "sumMatrixIncludeNaN", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumMat"
    "rixIncludeNaN.m" /* pName */
};

static emlrtRTEInfo ff_emlrtRTEI = {
    688,        /* lineNo */
    8,          /* colNo */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pName
                                                                       */
};

static emlrtRTEInfo gf_emlrtRTEI = {
    905,        /* lineNo */
    27,         /* colNo */
    "imfilter", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\images\\images\\eml\\imfilter.m" /* pName
                                                                       */
};

/* Function Declarations */
static void padImage(const emlrtStack *sp, const emxArray_real_T *a_tmp,
                     const real_T pad[2], emxArray_real_T *a);

/* Function Definitions */
static void padImage(const emlrtStack *sp, const emxArray_real_T *a_tmp,
                     const real_T pad[2], emxArray_real_T *a)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack st;
  const real_T *a_tmp_data;
  real_T *a_data;
  int32_T b_i;
  int32_T i;
  int32_T j;
  int32_T k;
  boolean_T exitg1;
  boolean_T p;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  a_tmp_data = a_tmp->data;
  st.site = &cf_emlrtRSI;
  b_st.site = &df_emlrtRSI;
  c_st.site = &gf_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 2)) {
    if (!muDoubleScalarIsNaN(pad[k])) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }
  if (!p) {
    emlrtErrorWithMessageIdR2018a(
        &c_st, &t_emlrtRTEI, "Coder:toolbox:ValidateattributesexpectedNonNaN",
        "MATLAB:padarray:expectedNonNaN", 3, 4, 24, "input number 2, PADSIZE,");
  }
  c_st.site = &gf_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 2)) {
    if (!(pad[k] < 0.0)) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }
  if (!p) {
    emlrtErrorWithMessageIdR2018a(
        &c_st, &s_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedNonnegative",
        "MATLAB:padarray:expectedNonnegative", 3, 4, 24,
        "input number 2, PADSIZE,");
  }
  c_st.site = &gf_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 2)) {
    if ((!muDoubleScalarIsInf(pad[k])) && (!muDoubleScalarIsNaN(pad[k])) &&
        (muDoubleScalarFloor(pad[k]) == pad[k])) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }
  if (!p) {
    emlrtErrorWithMessageIdR2018a(
        &c_st, &r_emlrtRTEI, "Coder:toolbox:ValidateattributesexpectedInteger",
        "MATLAB:padarray:expectedInteger", 3, 4, 24,
        "input number 2, PADSIZE,");
  }
  if ((a_tmp->size[0] == 0) || (a_tmp->size[1] == 0)) {
    real_T varargin_1[2];
    real_T d;
    real_T sizeB_idx_0;
    real_T sizeB_idx_1;
    int32_T exitg2;
    boolean_T guard1;
    sizeB_idx_0 = (real_T)a_tmp->size[0] + 2.0 * pad[0];
    sizeB_idx_1 = (real_T)a_tmp->size[1] + 2.0 * pad[1];
    b_st.site = &ef_emlrtRSI;
    varargin_1[0] = sizeB_idx_0;
    varargin_1[1] = sizeB_idx_1;
    c_st.site = &hf_emlrtRSI;
    k = 0;
    guard1 = false;
    do {
      exitg2 = 0;
      if (k < 2) {
        if ((varargin_1[k] != varargin_1[k]) ||
            muDoubleScalarIsInf(varargin_1[k])) {
          guard1 = true;
          exitg2 = 1;
        } else {
          k++;
          guard1 = false;
        }
      } else {
        k = 0;
        exitg2 = 2;
      }
    } while (exitg2 == 0);
    if (exitg2 != 1) {
      exitg1 = false;
      while ((!exitg1) && (k < 2)) {
        if (varargin_1[k] > 2.147483647E+9) {
          guard1 = true;
          exitg1 = true;
        } else {
          k++;
        }
      }
    }
    if (guard1) {
      emlrtErrorWithMessageIdR2018a(
          &c_st, &q_emlrtRTEI,
          "Coder:toolbox:eml_assert_valid_size_arg_invalidSizeVector",
          "Coder:toolbox:eml_assert_valid_size_arg_invalidSizeVector", 4, 12,
          MIN_int32_T, 12, MAX_int32_T);
    }
    if (sizeB_idx_0 <= 0.0) {
      d = 0.0;
    } else {
      d = sizeB_idx_0;
    }
    if (sizeB_idx_1 <= 0.0) {
      d = 0.0;
    } else {
      d *= sizeB_idx_1;
    }
    if (!(d <= 2.147483647E+9)) {
      emlrtErrorWithMessageIdR2018a(&c_st, &p_emlrtRTEI,
                                    "Coder:MATLAB:pmaxsize",
                                    "Coder:MATLAB:pmaxsize", 0);
    }
    if (!(sizeB_idx_0 >= 0.0)) {
      emlrtNonNegativeCheckR2012b(sizeB_idx_0, &eb_emlrtDCI, &b_st);
    }
    if (!(sizeB_idx_1 >= 0.0)) {
      emlrtNonNegativeCheckR2012b(sizeB_idx_1, &eb_emlrtDCI, &b_st);
    }
    i = a->size[0] * a->size[1];
    a->size[0] = (int32_T)sizeB_idx_0;
    a->size[1] = (int32_T)sizeB_idx_1;
    emxEnsureCapacity_real_T(&b_st, a, i, &sd_emlrtRTEI);
    a_data = a->data;
    k = (int32_T)sizeB_idx_0 * (int32_T)sizeB_idx_1;
    for (i = 0; i < k; i++) {
      a_data[i] = 0.0;
    }
  } else {
    real_T sizeB_idx_0;
    real_T sizeB_idx_1;
    int32_T b;
    int32_T i1;
    int32_T i2;
    int32_T i3;
    b_st.site = &ff_emlrtRSI;
    sizeB_idx_0 = (real_T)a_tmp->size[0] + 2.0 * pad[0];
    if (!(sizeB_idx_0 >= 0.0)) {
      emlrtNonNegativeCheckR2012b(sizeB_idx_0, &gb_emlrtDCI, &b_st);
    }
    if (sizeB_idx_0 != (int32_T)muDoubleScalarFloor(sizeB_idx_0)) {
      emlrtIntegerCheckR2012b(sizeB_idx_0, &fb_emlrtDCI, &b_st);
    }
    sizeB_idx_1 = (real_T)a_tmp->size[1] + 2.0 * pad[1];
    if (!(sizeB_idx_1 >= 0.0)) {
      emlrtNonNegativeCheckR2012b(sizeB_idx_1, &gb_emlrtDCI, &b_st);
    }
    if (sizeB_idx_1 != (int32_T)muDoubleScalarFloor(sizeB_idx_1)) {
      emlrtIntegerCheckR2012b(sizeB_idx_1, &fb_emlrtDCI, &b_st);
    }
    i = a->size[0] * a->size[1];
    a->size[0] = (int32_T)sizeB_idx_0;
    a->size[1] = (int32_T)sizeB_idx_1;
    emxEnsureCapacity_real_T(&b_st, a, i, &rd_emlrtRTEI);
    a_data = a->data;
    i = (int32_T)pad[1];
    for (j = 0; j < i; j++) {
      i1 = a->size[0];
      for (b_i = 0; b_i < i1; b_i++) {
        if (b_i + 1 > a->size[0]) {
          emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, a->size[0], &hb_emlrtBCI,
                                        &b_st);
        }
        if (((int32_T)((uint32_T)j + 1U) < 1) ||
            ((int32_T)((uint32_T)j + 1U) > a->size[1])) {
          emlrtDynamicBoundsCheckR2012b((int32_T)((uint32_T)j + 1U), 1,
                                        a->size[1], &ib_emlrtBCI, &b_st);
        }
        a_data[b_i + a->size[0] * j] = 0.0;
      }
    }
    k = (a_tmp->size[1] + (int32_T)pad[1]) + 1;
    b = a->size[1];
    c_st.site = &if_emlrtRSI;
    if ((k <= a->size[1]) && (a->size[1] > 2147483646)) {
      d_st.site = &ib_emlrtRSI;
      check_forloop_overflow_error(&d_st);
    }
    for (j = k; j <= b; j++) {
      i1 = a->size[0];
      for (b_i = 0; b_i < i1; b_i++) {
        if (b_i + 1 > a->size[0]) {
          emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, a->size[0], &jb_emlrtBCI,
                                        &b_st);
        }
        if ((j < 1) || (j > a->size[1])) {
          emlrtDynamicBoundsCheckR2012b(j, 1, a->size[1], &kb_emlrtBCI, &b_st);
        }
        a_data[b_i + a->size[0] * (j - 1)] = 0.0;
      }
    }
    i1 = a_tmp->size[1];
    i2 = (int32_T)pad[0];
    for (j = 0; j < i1; j++) {
      for (b_i = 0; b_i < i2; b_i++) {
        if (((int32_T)((uint32_T)b_i + 1U) < 1) ||
            ((int32_T)((uint32_T)b_i + 1U) > a->size[0])) {
          emlrtDynamicBoundsCheckR2012b((int32_T)((uint32_T)b_i + 1U), 1,
                                        a->size[0], &lb_emlrtBCI, &b_st);
        }
        i3 = (j + i) + 1;
        if ((i3 < 1) || (i3 > a->size[1])) {
          emlrtDynamicBoundsCheckR2012b(i3, 1, a->size[1], &mb_emlrtBCI, &b_st);
        }
        a_data[b_i + a->size[0] * (i3 - 1)] = 0.0;
      }
    }
    i1 = a_tmp->size[1];
    k = ((int32_T)pad[0] + a_tmp->size[0]) + 1;
    for (j = 0; j < i1; j++) {
      b = a->size[0];
      c_st.site = &jf_emlrtRSI;
      if ((k <= a->size[0]) && (a->size[0] > 2147483646)) {
        d_st.site = &ib_emlrtRSI;
        check_forloop_overflow_error(&d_st);
      }
      for (b_i = k; b_i <= b; b_i++) {
        if ((b_i < 1) || (b_i > a->size[0])) {
          emlrtDynamicBoundsCheckR2012b(b_i, 1, a->size[0], &rb_emlrtBCI,
                                        &b_st);
        }
        i3 = (j + i) + 1;
        if ((i3 < 1) || (i3 > a->size[1])) {
          emlrtDynamicBoundsCheckR2012b(i3, 1, a->size[1], &sb_emlrtBCI, &b_st);
        }
        a_data[(b_i + a->size[0] * (i3 - 1)) - 1] = 0.0;
      }
    }
    i1 = a_tmp->size[1];
    i3 = a_tmp->size[0];
    for (j = 0; j < i1; j++) {
      k = (j + i) + 1;
      for (b_i = 0; b_i < i3; b_i++) {
        if (b_i + 1 > a_tmp->size[0]) {
          emlrtDynamicBoundsCheckR2012b(b_i + 1, 1, a_tmp->size[0],
                                        &nb_emlrtBCI, &b_st);
        }
        if (j + 1 > a_tmp->size[1]) {
          emlrtDynamicBoundsCheckR2012b(j + 1, 1, a_tmp->size[1], &ob_emlrtBCI,
                                        &b_st);
        }
        b = (b_i + i2) + 1;
        if ((b < 1) || (b > a->size[0])) {
          emlrtDynamicBoundsCheckR2012b(b, 1, a->size[0], &pb_emlrtBCI, &b_st);
        }
        if ((k < 1) || (k > a->size[1])) {
          emlrtDynamicBoundsCheckR2012b(k, 1, a->size[1], &qb_emlrtBCI, &b_st);
        }
        a_data[(b + a->size[0] * (k - 1)) - 1] =
            a_tmp_data[b_i + a_tmp->size[0] * j];
      }
    }
  }
}

void imfilter(const emlrtStack *sp, emxArray_real_T *varargin_1,
              const emxArray_real_T *varargin_2)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  emlrtStack h_st;
  emlrtStack i_st;
  emlrtStack j_st;
  emlrtStack st;
  emxArray_boolean_T *b_conn;
  emxArray_boolean_T *c_conn;
  emxArray_boolean_T *conn;
  emxArray_int32_T *r;
  emxArray_int32_T *r1;
  emxArray_real_T *a;
  emxArray_real_T *a__2;
  emxArray_real_T *b_s;
  emxArray_real_T *hcol;
  emxArray_real_T *hrow;
  emxArray_real_T *s;
  emxArray_real_T *v;
  real_T outSizeT[2];
  real_T startT[2];
  const real_T *varargin_2_data;
  real_T *a_data;
  real_T *hcol_data;
  real_T *hrow_data;
  real_T *s_data;
  real_T *v_data;
  real_T *varargin_1_data;
  int32_T b_a;
  int32_T b_outSizeT_tmp;
  int32_T k;
  int32_T outSizeT_tmp;
  int32_T *r3;
  boolean_T *conn_data;
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
  f_st.prev = &e_st;
  f_st.tls = e_st.tls;
  g_st.prev = &f_st;
  g_st.tls = f_st.tls;
  h_st.prev = &g_st;
  h_st.tls = g_st.tls;
  i_st.prev = &h_st;
  i_st.tls = h_st.tls;
  j_st.prev = &i_st;
  j_st.tls = i_st.tls;
  varargin_2_data = varargin_2->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  outSizeT_tmp = varargin_1->size[0];
  outSizeT[0] = outSizeT_tmp;
  startT[0] = (real_T)varargin_2->size[0] -
              muDoubleScalarFloor(((real_T)varargin_2->size[0] + 1.0) / 2.0);
  b_outSizeT_tmp = varargin_1->size[1];
  outSizeT[1] = b_outSizeT_tmp;
  startT[1] = (real_T)varargin_2->size[1] -
              muDoubleScalarFloor(((real_T)varargin_2->size[1] + 1.0) / 2.0);
  emxInit_real_T(sp, &v, 2, &ve_emlrtRTEI);
  emxInit_real_T(sp, &a, 2, &df_emlrtRTEI);
  emxInit_real_T(sp, &hcol, 1, &we_emlrtRTEI);
  emxInit_real_T(sp, &hrow, 2, &xe_emlrtRTEI);
  emxInit_real_T(sp, &a__2, 2, &ve_emlrtRTEI);
  emxInit_real_T(sp, &s, 2, &ef_emlrtRTEI);
  emxInit_real_T(sp, &b_s, 1, &ff_emlrtRTEI);
  emxInit_boolean_T(sp, &conn, 2, &ue_emlrtRTEI);
  emxInit_boolean_T(sp, &b_conn, 2, &ue_emlrtRTEI);
  emxInit_int32_T(sp, &r, &gf_emlrtRTEI);
  emxInit_boolean_T(sp, &c_conn, 1, &ue_emlrtRTEI);
  emxInit_int32_T(sp, &r1, &gf_emlrtRTEI);
  if ((varargin_1->size[0] != 0) && (varargin_1->size[1] != 0)) {
    if ((varargin_2->size[0] == 0) || (varargin_2->size[1] == 0)) {
      k = varargin_1->size[0] * varargin_1->size[1];
      varargin_1->size[0] = outSizeT_tmp;
      emxEnsureCapacity_real_T(sp, varargin_1, k, &se_emlrtRTEI);
      k = varargin_1->size[0] * varargin_1->size[1];
      varargin_1->size[1] = b_outSizeT_tmp;
      emxEnsureCapacity_real_T(sp, varargin_1, k, &se_emlrtRTEI);
      varargin_1_data = varargin_1->data;
      for (k = 0; k < b_outSizeT_tmp; k++) {
        for (b_a = 0; b_a < outSizeT_tmp; b_a++) {
          varargin_1_data[b_a + varargin_1->size[0] * k] = 0.0;
        }
      }
    } else {
      real_T tol;
      int32_T idx;
      int32_T last;
      int32_T varargin_2_idx_0;
      boolean_T tooBig;
      st.site = &od_emlrtRSI;
      varargin_2_idx_0 = varargin_2->size[0] * varargin_2->size[1];
      if (varargin_2_idx_0 >= 49) {
        boolean_T b_varargin_2[2];
        b_varargin_2[0] = (varargin_2->size[0] != 1);
        b_varargin_2[1] = (varargin_2->size[1] != 1);
        if (all(b_varargin_2)) {
          k = c_conn->size[0];
          c_conn->size[0] = varargin_2_idx_0;
          emxEnsureCapacity_boolean_T(&st, c_conn, k, &te_emlrtRTEI);
          conn_data = c_conn->data;
          for (k = 0; k < varargin_2_idx_0; k++) {
            conn_data[k] = ((!muDoubleScalarIsInf(varargin_2_data[k])) &&
                            (!muDoubleScalarIsNaN(varargin_2_data[k])));
          }
          b_st.site = &yd_emlrtRSI;
          if (b_all(&b_st, c_conn)) {
            b_st.site = &ae_emlrtRSI;
            svd(&b_st, varargin_2, a, s, a__2);
            s_data = s->data;
            last = s->size[0];
            idx = s->size[1];
            for (k = 0; k < idx; k++) {
              for (b_a = 0; b_a < last; b_a++) {
                s_data[b_a + last * k] = s_data[b_a + s->size[0] * k];
              }
            }
            b_st.site = &be_emlrtRSI;
            diag(&b_st, s, b_s);
            s_data = b_s->data;
            b_st.site = &ce_emlrtRSI;
            c_st.site = &ab_emlrtRSI;
            d_st.site = &bb_emlrtRSI;
            e_st.site = &cb_emlrtRSI;
            if (b_s->size[0] < 1) {
              emlrtErrorWithMessageIdR2018a(
                  &e_st, &w_emlrtRTEI,
                  "Coder:toolbox:eml_min_or_max_varDimZero",
                  "Coder:toolbox:eml_min_or_max_varDimZero", 0);
            }
            f_st.site = &db_emlrtRSI;
            g_st.site = &eb_emlrtRSI;
            last = b_s->size[0];
            if (b_s->size[0] <= 2) {
              if (b_s->size[0] == 1) {
                tol = s_data[0];
              } else if ((s_data[0] < s_data[1]) ||
                         (muDoubleScalarIsNaN(s_data[0]) &&
                          (!muDoubleScalarIsNaN(s_data[1])))) {
                tol = s_data[1];
              } else {
                tol = s_data[0];
              }
            } else {
              h_st.site = &gb_emlrtRSI;
              if (!muDoubleScalarIsNaN(s_data[0])) {
                idx = 1;
              } else {
                boolean_T exitg1;
                idx = 0;
                i_st.site = &hb_emlrtRSI;
                if (b_s->size[0] > 2147483646) {
                  j_st.site = &ib_emlrtRSI;
                  check_forloop_overflow_error(&j_st);
                }
                k = 2;
                exitg1 = false;
                while ((!exitg1) && (k <= last)) {
                  if (!muDoubleScalarIsNaN(s_data[k - 1])) {
                    idx = k;
                    exitg1 = true;
                  } else {
                    k++;
                  }
                }
              }
              if (idx == 0) {
                tol = s_data[0];
              } else {
                h_st.site = &fb_emlrtRSI;
                tol = s_data[idx - 1];
                b_a = idx + 1;
                i_st.site = &jb_emlrtRSI;
                if ((idx + 1 <= b_s->size[0]) && (b_s->size[0] > 2147483646)) {
                  j_st.site = &ib_emlrtRSI;
                  check_forloop_overflow_error(&j_st);
                }
                for (k = b_a; k <= last; k++) {
                  real_T d;
                  d = s_data[k - 1];
                  if (tol < d) {
                    tol = d;
                  }
                }
              }
            }
            tol = (real_T)muIntScalarMax_sint32(varargin_2->size[0],
                                                varargin_2->size[1]) *
                  tol * 2.2204460492503131E-16;
            b_st.site = &de_emlrtRSI;
            c_st.site = &ye_emlrtRSI;
            k = c_conn->size[0];
            c_conn->size[0] = b_s->size[0];
            emxEnsureCapacity_boolean_T(&c_st, c_conn, k, &af_emlrtRTEI);
            conn_data = c_conn->data;
            b_a = b_s->size[0];
            for (k = 0; k < b_a; k++) {
              conn_data[k] = (s_data[k] > tol);
            }
            d_st.site = &bd_emlrtRSI;
            last = combineVectorElements(&d_st, c_conn);
            tooBig = (last == 1);
          } else {
            tooBig = false;
          }
        } else {
          tooBig = false;
        }
      } else {
        tooBig = false;
      }
      if (tooBig) {
        __m128d r2;
        real_T connDimsT[2];
        real_T out_size_row[2];
        real_T padSizeT[2];
        real_T start[2];
        st.site = &pd_emlrtRSI;
        padImage(&st, varargin_1, startT, a);
        a_data = a->data;
        st.site = &qd_emlrtRSI;
        svd(&st, varargin_2, a__2, s, v);
        v_data = v->data;
        s_data = s->data;
        varargin_1_data = a__2->data;
        last = s->size[0];
        idx = s->size[1];
        for (k = 0; k < idx; k++) {
          for (b_a = 0; b_a < last; b_a++) {
            s_data[b_a + last * k] = s_data[b_a + s->size[0] * k];
          }
        }
        st.site = &rd_emlrtRSI;
        diag(&st, s, b_s);
        s_data = b_s->data;
        if (a__2->size[1] < 1) {
          emlrtDynamicBoundsCheckR2012b(1, 1, a__2->size[1], &wb_emlrtBCI,
                                        (emlrtConstCTX)sp);
        }
        if (b_s->size[0] < 1) {
          emlrtDynamicBoundsCheckR2012b(1, 1, b_s->size[0], &vb_emlrtBCI,
                                        (emlrtConstCTX)sp);
        }
        tol = s_data[0];
        st.site = &sd_emlrtRSI;
        if (tol < 0.0) {
          emlrtErrorWithMessageIdR2018a(
              &st, &v_emlrtRTEI, "Coder:toolbox:ElFunDomainError",
              "Coder:toolbox:ElFunDomainError", 3, 4, 4, "sqrt");
        }
        tol = muDoubleScalarSqrt(tol);
        k = hcol->size[0];
        hcol->size[0] = a__2->size[0];
        emxEnsureCapacity_real_T(sp, hcol, k, &we_emlrtRTEI);
        hcol_data = hcol->data;
        b_a = a__2->size[0];
        last = (a__2->size[0] / 2) << 1;
        idx = last - 2;
        for (k = 0; k <= idx; k += 2) {
          r2 = _mm_loadu_pd(&varargin_1_data[k]);
          _mm_storeu_pd(&hcol_data[k], _mm_mul_pd(r2, _mm_set1_pd(tol)));
        }
        for (k = last; k < b_a; k++) {
          hcol_data[k] = varargin_1_data[k] * tol;
        }
        if (v->size[1] < 1) {
          emlrtDynamicBoundsCheckR2012b(1, 1, v->size[1], &ub_emlrtBCI,
                                        (emlrtConstCTX)sp);
        }
        if (b_s->size[0] < 1) {
          emlrtDynamicBoundsCheckR2012b(1, 1, b_s->size[0], &tb_emlrtBCI,
                                        (emlrtConstCTX)sp);
        }
        tol = s_data[0];
        st.site = &td_emlrtRSI;
        if (tol < 0.0) {
          emlrtErrorWithMessageIdR2018a(
              &st, &v_emlrtRTEI, "Coder:toolbox:ElFunDomainError",
              "Coder:toolbox:ElFunDomainError", 3, 4, 4, "sqrt");
        }
        tol = muDoubleScalarSqrt(tol);
        k = hrow->size[0] * hrow->size[1];
        hrow->size[0] = 1;
        hrow->size[1] = v->size[0];
        emxEnsureCapacity_real_T(sp, hrow, k, &xe_emlrtRTEI);
        hrow_data = hrow->data;
        b_a = v->size[0];
        last = (v->size[0] / 2) << 1;
        idx = last - 2;
        for (k = 0; k <= idx; k += 2) {
          r2 = _mm_loadu_pd(&v_data[k]);
          _mm_storeu_pd(&hrow_data[k], _mm_mul_pd(r2, _mm_set1_pd(tol)));
        }
        for (k = last; k < b_a; k++) {
          hrow_data[k] = v_data[k] * tol;
        }
        out_size_row[0] = a->size[0];
        out_size_row[1] = b_outSizeT_tmp;
        start[0] = 0.0;
        start[1] = startT[1];
        st.site = &ud_emlrtRSI;
        k = b_conn->size[0] * b_conn->size[1];
        b_conn->size[0] = 1;
        b_conn->size[1] = hrow->size[1];
        emxEnsureCapacity_boolean_T(&st, b_conn, k, &ue_emlrtRTEI);
        conn_data = b_conn->data;
        b_a = hrow->size[1];
        for (k = 0; k < b_a; k++) {
          conn_data[k] = (hrow_data[k] != 0.0);
        }
        idx = b_conn->size[1] - 1;
        last = 0;
        for (b_a = 0; b_a <= idx; b_a++) {
          if (conn_data[b_a]) {
            last++;
          }
        }
        k = r->size[0];
        r->size[0] = last;
        emxEnsureCapacity_int32_T(&st, r, k, &ve_emlrtRTEI);
        r3 = r->data;
        last = 0;
        for (b_a = 0; b_a <= idx; b_a++) {
          if (conn_data[b_a]) {
            r3[last] = b_a;
            last++;
          }
        }
        k = b_s->size[0];
        b_s->size[0] = r->size[0];
        emxEnsureCapacity_real_T(&st, b_s, k, &bf_emlrtRTEI);
        s_data = b_s->data;
        b_a = r->size[0];
        for (k = 0; k < b_a; k++) {
          if (r3[k] > idx) {
            emlrtDynamicBoundsCheckR2012b(r3[k], 0, idx, &yb_emlrtBCI, &st);
          }
          s_data[k] = hrow_data[r3[k]];
        }
        b_st.site = &kf_emlrtRSI;
        tooBig = true;
        if ((a->size[0] <= 65500) || (b_outSizeT_tmp <= 65500)) {
          tooBig = false;
        }
        if (((real_T)r->size[0] / (real_T)hrow->size[1] > 0.05) && (!tooBig)) {
          tooBig = true;
        } else {
          tooBig = false;
        }
        c_st.site = &lf_emlrtRSI;
        k = varargin_1->size[0] * varargin_1->size[1];
        varargin_1->size[0] = a->size[0];
        varargin_1->size[1] = b_outSizeT_tmp;
        emxEnsureCapacity_real_T(&c_st, varargin_1, k, &ye_emlrtRTEI);
        varargin_1_data = varargin_1->data;
        if (tooBig) {
          d_st.site = &mf_emlrtRSI;
          padSizeT[0] = a->size[0];
          connDimsT[0] = 1.0;
          padSizeT[1] = a->size[1];
          connDimsT[1] = hrow->size[1];
          ippfilter_real64(&a_data[0], &varargin_1_data[0], &out_size_row[0],
                           2.0, &padSizeT[0], &hrow_data[0], &connDimsT[0],
                           false);
        } else {
          d_st.site = &nf_emlrtRSI;
          padSizeT[0] = a->size[0];
          connDimsT[0] = 1.0;
          padSizeT[1] = a->size[1];
          connDimsT[1] = b_conn->size[1];
          imfilter_real64(&a_data[0], &varargin_1_data[0], 2.0,
                          &out_size_row[0], 2.0, &padSizeT[0], &s_data[0],
                          (real_T)r->size[0], &conn_data[0], 2.0, &connDimsT[0],
                          &start[0], 2.0, true, false);
        }
        start[0] = startT[0];
        start[1] = 0.0;
        st.site = &vd_emlrtRSI;
        k = c_conn->size[0];
        c_conn->size[0] = hcol->size[0];
        emxEnsureCapacity_boolean_T(&st, c_conn, k, &ue_emlrtRTEI);
        conn_data = c_conn->data;
        b_a = hcol->size[0];
        for (k = 0; k < b_a; k++) {
          conn_data[k] = (hcol_data[k] != 0.0);
        }
        idx = c_conn->size[0] - 1;
        last = 0;
        for (b_a = 0; b_a <= idx; b_a++) {
          if (conn_data[b_a]) {
            last++;
          }
        }
        k = r1->size[0];
        r1->size[0] = last;
        emxEnsureCapacity_int32_T(&st, r1, k, &ve_emlrtRTEI);
        r3 = r1->data;
        last = 0;
        for (b_a = 0; b_a <= idx; b_a++) {
          if (conn_data[b_a]) {
            r3[last] = b_a;
            last++;
          }
        }
        k = b_s->size[0];
        b_s->size[0] = r1->size[0];
        emxEnsureCapacity_real_T(&st, b_s, k, &bf_emlrtRTEI);
        s_data = b_s->data;
        b_a = r1->size[0];
        for (k = 0; k < b_a; k++) {
          if (r3[k] > idx) {
            emlrtDynamicBoundsCheckR2012b(r3[k], 0, idx, &yb_emlrtBCI, &st);
          }
          s_data[k] = hcol_data[r3[k]];
        }
        b_st.site = &kf_emlrtRSI;
        tooBig = true;
        if ((outSizeT_tmp <= 65500) || (b_outSizeT_tmp <= 65500)) {
          tooBig = false;
        }
        if (((real_T)r1->size[0] / (real_T)hcol->size[0] > 0.05) && (!tooBig)) {
          tooBig = true;
        } else {
          tooBig = false;
        }
        c_st.site = &lf_emlrtRSI;
        k = a->size[0] * a->size[1];
        a->size[0] = varargin_1->size[0];
        a->size[1] = varargin_1->size[1];
        emxEnsureCapacity_real_T(&c_st, a, k, &cf_emlrtRTEI);
        a_data = a->data;
        b_a = varargin_1->size[0] * varargin_1->size[1];
        for (k = 0; k < b_a; k++) {
          a_data[k] = varargin_1_data[k];
        }
        k = varargin_1->size[0] * varargin_1->size[1];
        varargin_1->size[0] = outSizeT_tmp;
        varargin_1->size[1] = b_outSizeT_tmp;
        emxEnsureCapacity_real_T(&c_st, varargin_1, k, &ye_emlrtRTEI);
        varargin_1_data = varargin_1->data;
        if (tooBig) {
          d_st.site = &mf_emlrtRSI;
          padSizeT[0] = a->size[0];
          padSizeT[1] = a->size[1];
          connDimsT[0] = hcol->size[0];
          connDimsT[1] = 1.0;
          ippfilter_real64(&a_data[0], &varargin_1_data[0], &outSizeT[0], 2.0,
                           &padSizeT[0], &hcol_data[0], &connDimsT[0], false);
        } else {
          d_st.site = &nf_emlrtRSI;
          padSizeT[0] = a->size[0];
          padSizeT[1] = a->size[1];
          connDimsT[0] = c_conn->size[0];
          connDimsT[1] = 1.0;
          imfilter_real64(&a_data[0], &varargin_1_data[0], 2.0, &outSizeT[0],
                          2.0, &padSizeT[0], &s_data[0], (real_T)r1->size[0],
                          &conn_data[0], 2.0, &connDimsT[0], &start[0], 2.0,
                          true, false);
        }
      } else {
        st.site = &wd_emlrtRSI;
        padImage(&st, varargin_1, startT, a);
        a_data = a->data;
        st.site = &xd_emlrtRSI;
        k = conn->size[0] * conn->size[1];
        conn->size[0] = varargin_2->size[0];
        conn->size[1] = varargin_2->size[1];
        emxEnsureCapacity_boolean_T(&st, conn, k, &ue_emlrtRTEI);
        conn_data = conn->data;
        for (k = 0; k < varargin_2_idx_0; k++) {
          conn_data[k] = (varargin_2_data[k] != 0.0);
        }
        tooBig = ((varargin_2->size[0] == 1) || (varargin_2->size[1] == 1));
        if (tooBig) {
          idx = varargin_2_idx_0 - 1;
          last = 0;
          for (b_a = 0; b_a <= idx; b_a++) {
            if (conn_data[b_a]) {
              last++;
            }
          }
          k = b_s->size[0];
          b_s->size[0] = last;
          emxEnsureCapacity_real_T(&st, b_s, k, &ve_emlrtRTEI);
          s_data = b_s->data;
          last = 0;
          for (b_a = 0; b_a <= idx; b_a++) {
            if (conn_data[b_a]) {
              if (b_a > varargin_2_idx_0 - 1) {
                emlrtDynamicBoundsCheckR2012b(b_a, 0, varargin_2_idx_0 - 1,
                                              &yb_emlrtBCI, &st);
              }
              s_data[last] = varargin_2_data[b_a];
              last++;
            }
          }
        } else {
          b_st.site = &of_emlrtRSI;
          b_indexShapeCheck(&b_st, varargin_2->size, conn->size);
          idx = varargin_2_idx_0 - 1;
          last = 0;
          for (b_a = 0; b_a <= idx; b_a++) {
            if (conn_data[b_a]) {
              last++;
            }
          }
          k = b_s->size[0];
          b_s->size[0] = last;
          emxEnsureCapacity_real_T(&st, b_s, k, &ve_emlrtRTEI);
          s_data = b_s->data;
          last = 0;
          for (b_a = 0; b_a <= idx; b_a++) {
            if (conn_data[b_a]) {
              if (b_a > varargin_2_idx_0 - 1) {
                emlrtDynamicBoundsCheckR2012b(b_a, 0, varargin_2_idx_0 - 1,
                                              &xb_emlrtBCI, &st);
              }
              s_data[last] = varargin_2_data[b_a];
              last++;
            }
          }
        }
        b_st.site = &kf_emlrtRSI;
        tooBig = true;
        if ((outSizeT_tmp <= 65500) || (b_outSizeT_tmp <= 65500)) {
          tooBig = false;
        }
        if (((real_T)b_s->size[0] / (real_T)varargin_2_idx_0 > 0.05) &&
            (!tooBig)) {
          tooBig = true;
        } else {
          tooBig = false;
        }
        c_st.site = &lf_emlrtRSI;
        k = varargin_1->size[0] * varargin_1->size[1];
        varargin_1->size[0] = outSizeT_tmp;
        varargin_1->size[1] = b_outSizeT_tmp;
        emxEnsureCapacity_real_T(&c_st, varargin_1, k, &ye_emlrtRTEI);
        varargin_1_data = varargin_1->data;
        if (tooBig) {
          real_T connDimsT[2];
          real_T padSizeT[2];
          d_st.site = &mf_emlrtRSI;
          padSizeT[0] = a->size[0];
          connDimsT[0] = varargin_2->size[0];
          padSizeT[1] = a->size[1];
          connDimsT[1] = varargin_2->size[1];
          ippfilter_real64(&a_data[0], &varargin_1_data[0], &outSizeT[0], 2.0,
                           &padSizeT[0], &varargin_2_data[0], &connDimsT[0],
                           false);
        } else {
          real_T connDimsT[2];
          real_T padSizeT[2];
          d_st.site = &nf_emlrtRSI;
          padSizeT[0] = a->size[0];
          connDimsT[0] = conn->size[0];
          padSizeT[1] = a->size[1];
          connDimsT[1] = conn->size[1];
          imfilter_real64(&a_data[0], &varargin_1_data[0], 2.0, &outSizeT[0],
                          2.0, &padSizeT[0], &s_data[0], (real_T)b_s->size[0],
                          &conn_data[0], 2.0, &connDimsT[0], &startT[0], 2.0,
                          true, false);
        }
      }
    }
  }
  emxFree_int32_T(sp, &r1);
  emxFree_boolean_T(sp, &c_conn);
  emxFree_int32_T(sp, &r);
  emxFree_boolean_T(sp, &b_conn);
  emxFree_boolean_T(sp, &conn);
  emxFree_real_T(sp, &b_s);
  emxFree_real_T(sp, &s);
  emxFree_real_T(sp, &a__2);
  emxFree_real_T(sp, &hrow);
  emxFree_real_T(sp, &hcol);
  emxFree_real_T(sp, &a);
  emxFree_real_T(sp, &v);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

/* End of code generation (imfilter.c) */
