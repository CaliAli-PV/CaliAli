/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * register_in_lite.c
 *
 * Code generation for function 'register_in_lite'
 *
 */

/* Include files */
#include "register_in_lite.h"
#include "div.h"
#include "eml_int_forloop_overflow_check.h"
#include "gradient.h"
#include "imfilter.h"
#include "interpn.h"
#include "ndgrid.h"
#include "register_in_lite_data.h"
#include "register_in_lite_emxutil.h"
#include "register_in_lite_types.h"
#include "rt_nonfinite.h"
#include "sum.h"
#include "unsafeSxfun.h"
#include "mwmathutil.h"
#include "omp.h"
#include <emmintrin.h>
#include <math.h>

/* Variable Definitions */
static emlrtRSInfo emlrtRSI = {
    16,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo b_emlrtRSI = {
    17,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo c_emlrtRSI = {
    18,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo d_emlrtRSI = {
    19,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo e_emlrtRSI = {
    27,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo f_emlrtRSI = {
    29,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo g_emlrtRSI = {
    30,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo h_emlrtRSI = {
    41,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo i_emlrtRSI = {
    42,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo j_emlrtRSI = {
    45,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo k_emlrtRSI = {
    47,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo l_emlrtRSI = {
    63,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo m_emlrtRSI = {
    65,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo n_emlrtRSI = {
    77,                                                    /* lineNo */
    "findupdate",                                          /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo o_emlrtRSI = {
    79,                                                    /* lineNo */
    "findupdate",                                          /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo p_emlrtRSI = {
    85,                                                    /* lineNo */
    "findupdate",                                          /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo q_emlrtRSI = {
    86,                                                    /* lineNo */
    "findupdate",                                          /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo r_emlrtRSI = {
    90,                                                    /* lineNo */
    "findupdate",                                          /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo s_emlrtRSI = {
    129,                                                   /* lineNo */
    "expfield",                                            /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo t_emlrtRSI = {
    130,                                                   /* lineNo */
    "expfield",                                            /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo u_emlrtRSI = {
    131,                                                   /* lineNo */
    "expfield",                                            /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo v_emlrtRSI = {
    135,                                                   /* lineNo */
    "expfield",                                            /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo w_emlrtRSI = {
    136,                                                   /* lineNo */
    "expfield",                                            /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo x_emlrtRSI = {
    139,                                                   /* lineNo */
    "expfield",                                            /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo y_emlrtRSI =
    {
        71,      /* lineNo */
        "power", /* fcnName */
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\power.m" /* pathName
                                                                          */
};

static emlrtRSInfo kb_emlrtRSI = {
    44,       /* lineNo */
    "mpower", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\matfun\\mpower.m" /* pathName
                                                                          */
};

static emlrtRSInfo lb_emlrtRSI = {
    144,                                                   /* lineNo */
    "compose",                                             /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo mb_emlrtRSI = {
    149,                                                   /* lineNo */
    "compose",                                             /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo nb_emlrtRSI = {
    150,                                                   /* lineNo */
    "compose",                                             /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo ic_emlrtRSI = {
    103,                                                   /* lineNo */
    "iminterpolate",                                       /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo jc_emlrtRSI = {
    108,                                                   /* lineNo */
    "iminterpolate",                                       /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo qc_emlrtRSI = {
    34,               /* lineNo */
    "rdivide_helper", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\rdivide_"
    "helper.m" /* pathName */
};

static emlrtRSInfo rc_emlrtRSI = {
    51,    /* lineNo */
    "div", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\div.m" /* pathName
                                                                          */
};

static emlrtRSInfo sc_emlrtRSI = {
    117,                                                   /* lineNo */
    "imgaussian",                                          /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo tc_emlrtRSI = {
    118,                                                   /* lineNo */
    "imgaussian",                                          /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo uc_emlrtRSI = {
    119,                                                   /* lineNo */
    "imgaussian",                                          /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo vc_emlrtRSI = {
    122,                                                   /* lineNo */
    "imgaussian",                                          /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo wc_emlrtRSI =
    {
        28,      /* lineNo */
        "colon", /* fcnName */
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\colon.m" /* pathName
                                                                          */
};

static emlrtRSInfo xc_emlrtRSI =
    {
        10,    /* lineNo */
        "exp", /* fcnName */
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\elfun\\exp.m" /* pathName
                                                                          */
};

static emlrtRSInfo yc_emlrtRSI = {
    33,                           /* lineNo */
    "applyScalarFunctionInPlace", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
    "internal\\applyScalarFunctionInPlace.m" /* pathName */
};

static emlrtRSInfo rf_emlrtRSI = {
    173,                                                   /* lineNo */
    "energy",                                              /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo sf_emlrtRSI = {
    174,                                                   /* lineNo */
    "energy",                                              /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo tf_emlrtRSI = {
    178,                                                   /* lineNo */
    "energy",                                              /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo uf_emlrtRSI = {
    181,                                                   /* lineNo */
    "energy",                                              /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo vf_emlrtRSI = {
    183,                                                   /* lineNo */
    "energy",                                              /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo wf_emlrtRSI = {
    186,                                                   /* lineNo */
    "energy",                                              /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo xf_emlrtRSI = {
    159,                                                   /* lineNo */
    "jacobian",                                            /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo yf_emlrtRSI = {
    160,                                                   /* lineNo */
    "jacobian",                                            /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRTEInfo emlrtRTEI = {
    25,                                                    /* lineNo */
    10,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo emlrtECI = {
    1,                                                     /* nDims */
    35,                                                    /* lineNo */
    10,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo b_emlrtECI = {
    2,                                                     /* nDims */
    35,                                                    /* lineNo */
    10,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo c_emlrtECI = {
    1,                                                     /* nDims */
    36,                                                    /* lineNo */
    10,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo d_emlrtECI = {
    2,                                                     /* nDims */
    36,                                                    /* lineNo */
    10,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtBCInfo emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    55,                                                     /* lineNo */
    54,                                                     /* colNo */
    "e",                                                    /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo emlrtDCI = {
    68,                                                     /* lineNo */
    9,                                                      /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo b_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    68,                                                     /* lineNo */
    9,                                                      /* colNo */
    "Mp",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo b_emlrtDCI = {
    68,                                                     /* lineNo */
    16,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo c_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    68,                                                     /* lineNo */
    16,                                                     /* colNo */
    "Mp",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo c_emlrtDCI = {
    68,                                                     /* lineNo */
    23,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo d_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    68,                                                     /* lineNo */
    23,                                                     /* colNo */
    "Mp",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo d_emlrtDCI = {
    68,                                                     /* lineNo */
    30,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo e_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    68,                                                     /* lineNo */
    30,                                                     /* colNo */
    "Mp",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo e_emlrtDCI = {
    69,                                                     /* lineNo */
    9,                                                      /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo f_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    69,                                                     /* lineNo */
    9,                                                      /* colNo */
    "vx",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo f_emlrtDCI = {
    69,                                                     /* lineNo */
    16,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo g_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    69,                                                     /* lineNo */
    16,                                                     /* colNo */
    "vx",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo g_emlrtDCI = {
    69,                                                     /* lineNo */
    23,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo h_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    69,                                                     /* lineNo */
    23,                                                     /* colNo */
    "vx",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo h_emlrtDCI = {
    69,                                                     /* lineNo */
    30,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo i_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    69,                                                     /* lineNo */
    30,                                                     /* colNo */
    "vx",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo i_emlrtDCI = {
    70,                                                     /* lineNo */
    9,                                                      /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo j_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    70,                                                     /* lineNo */
    9,                                                      /* colNo */
    "vy",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo j_emlrtDCI = {
    70,                                                     /* lineNo */
    16,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo k_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    70,                                                     /* lineNo */
    16,                                                     /* colNo */
    "vy",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo k_emlrtDCI = {
    70,                                                     /* lineNo */
    23,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo l_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    70,                                                     /* lineNo */
    23,                                                     /* colNo */
    "vy",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo l_emlrtDCI = {
    70,                                                     /* lineNo */
    30,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo m_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    70,                                                     /* lineNo */
    30,                                                     /* colNo */
    "vy",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo m_emlrtDCI = {
    71,                                                     /* lineNo */
    9,                                                      /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo n_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    71,                                                     /* lineNo */
    9,                                                      /* colNo */
    "sx",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo n_emlrtDCI = {
    71,                                                     /* lineNo */
    16,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo o_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    71,                                                     /* lineNo */
    16,                                                     /* colNo */
    "sx",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo o_emlrtDCI = {
    71,                                                     /* lineNo */
    23,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo p_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    71,                                                     /* lineNo */
    23,                                                     /* colNo */
    "sx",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo p_emlrtDCI = {
    71,                                                     /* lineNo */
    30,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo q_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    71,                                                     /* lineNo */
    30,                                                     /* colNo */
    "sx",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo q_emlrtDCI = {
    72,                                                     /* lineNo */
    9,                                                      /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo r_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    72,                                                     /* lineNo */
    9,                                                      /* colNo */
    "sy",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo r_emlrtDCI = {
    72,                                                     /* lineNo */
    16,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo s_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    72,                                                     /* lineNo */
    16,                                                     /* colNo */
    "sy",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo s_emlrtDCI = {
    72,                                                     /* lineNo */
    23,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo t_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    72,                                                     /* lineNo */
    23,                                                     /* colNo */
    "sy",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo t_emlrtDCI = {
    72,                                                     /* lineNo */
    30,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo u_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    72,                                                     /* lineNo */
    30,                                                     /* colNo */
    "sy",                                                   /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtECInfo e_emlrtECI = {
    1,                                                     /* nDims */
    174,                                                   /* lineNo */
    11,                                                    /* colNo */
    "energy",                                              /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo f_emlrtECI = {
    2,                                                     /* nDims */
    174,                                                   /* lineNo */
    11,                                                    /* colNo */
    "energy",                                              /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo g_emlrtECI = {
    1,                                                     /* nDims */
    167,                                                   /* lineNo */
    9,                                                     /* colNo */
    "jacobian",                                            /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo h_emlrtECI = {
    2,                                                     /* nDims */
    167,                                                   /* lineNo */
    9,                                                     /* colNo */
    "jacobian",                                            /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo i_emlrtECI = {
    1,                                                     /* nDims */
    168,                                                   /* lineNo */
    5,                                                     /* colNo */
    "jacobian",                                            /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo j_emlrtECI = {
    2,                                                     /* nDims */
    168,                                                   /* lineNo */
    5,                                                     /* colNo */
    "jacobian",                                            /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtDCInfo u_emlrtDCI = {
    22,                                                     /* lineNo */
    14,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtDCInfo v_emlrtDCI = {
    22,                                                     /* lineNo */
    14,                                                     /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    4                                                       /* checkKind */
};

static emlrtDCInfo w_emlrtDCI = {
    22,                                                     /* lineNo */
    1,                                                      /* colNo */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo v_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    47,                                                     /* lineNo */
    7,                                                      /* colNo */
    "e",                                                    /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtBCInfo w_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    48,                                                     /* lineNo */
    10,                                                     /* colNo */
    "e",                                                    /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtBCInfo x_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    55,                                                     /* lineNo */
    24,                                                     /* colNo */
    "e",                                                    /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtBCInfo y_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    55,                                                     /* lineNo */
    34,                                                     /* colNo */
    "e",                                                    /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtBCInfo ab_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    51,                                                     /* lineNo */
    20,                                                     /* colNo */
    "e",                                                    /* aName */
    "register_in_lite",                                     /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo x_emlrtDCI = {
    192,                                                    /* lineNo */
    4,                                                      /* colNo */
    "imagepad",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo bb_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    192,                                                    /* lineNo */
    4,                                                      /* colNo */
    "Ip",                                                   /* aName */
    "imagepad",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo y_emlrtDCI = {
    192,                                                    /* lineNo */
    11,                                                     /* colNo */
    "imagepad",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo cb_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    192,                                                    /* lineNo */
    11,                                                     /* colNo */
    "Ip",                                                   /* aName */
    "imagepad",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo ab_emlrtDCI = {
    192,                                                    /* lineNo */
    18,                                                     /* colNo */
    "imagepad",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo db_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    192,                                                    /* lineNo */
    18,                                                     /* colNo */
    "Ip",                                                   /* aName */
    "imagepad",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtDCInfo bb_emlrtDCI = {
    192,                                                    /* lineNo */
    25,                                                     /* colNo */
    "imagepad",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtBCInfo eb_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    192,                                                    /* lineNo */
    25,                                                     /* colNo */
    "Ip",                                                   /* aName */
    "imagepad",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtECInfo k_emlrtECI = {
    -1,                                                    /* nDims */
    192,                                                   /* lineNo */
    1,                                                     /* colNo */
    "imagepad",                                            /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtDCInfo cb_emlrtDCI = {
    190,                                                    /* lineNo */
    13,                                                     /* colNo */
    "imagepad",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    1                                                       /* checkKind */
};

static emlrtDCInfo db_emlrtDCI = {
    190,                                                    /* lineNo */
    13,                                                     /* colNo */
    "imagepad",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    4                                                       /* checkKind */
};

static emlrtRTEInfo b_emlrtRTEI = {
    13,                     /* lineNo */
    27,                     /* colNo */
    "assertCompatibleDims", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\shared\\coder\\coder\\lib\\+coder\\+"
    "internal\\assertCompatibleDims.m" /* pName */
};

static emlrtECInfo l_emlrtECI = {
    2,                                                     /* nDims */
    98,                                                    /* lineNo */
    30,                                                    /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo m_emlrtECI = {
    1,                                                     /* nDims */
    98,                                                    /* lineNo */
    30,                                                    /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo n_emlrtECI = {
    2,                                                     /* nDims */
    98,                                                    /* lineNo */
    4,                                                     /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo o_emlrtECI = {
    1,                                                     /* nDims */
    98,                                                    /* lineNo */
    4,                                                     /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo p_emlrtECI = {
    2,                                                     /* nDims */
    97,                                                    /* lineNo */
    25,                                                    /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo q_emlrtECI = {
    1,                                                     /* nDims */
    97,                                                    /* lineNo */
    25,                                                    /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo r_emlrtECI = {
    2,                                                     /* nDims */
    97,                                                    /* lineNo */
    4,                                                     /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo s_emlrtECI = {
    1,                                                     /* nDims */
    97,                                                    /* lineNo */
    4,                                                     /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo t_emlrtECI = {
    2,                                                     /* nDims */
    94,                                                    /* lineNo */
    6,                                                     /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo u_emlrtECI = {
    1,                                                     /* nDims */
    94,                                                    /* lineNo */
    6,                                                     /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo v_emlrtECI = {
    2,                                                     /* nDims */
    93,                                                    /* lineNo */
    6,                                                     /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo w_emlrtECI = {
    1,                                                     /* nDims */
    93,                                                    /* lineNo */
    6,                                                     /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo x_emlrtECI = {
    2,                                                     /* nDims */
    90,                                                    /* lineNo */
    18,                                                    /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo y_emlrtECI = {
    1,                                                     /* nDims */
    90,                                                    /* lineNo */
    18,                                                    /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo ab_emlrtECI = {
    2,                                                     /* nDims */
    86,                                                    /* lineNo */
    11,                                                    /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo bb_emlrtECI = {
    1,                                                     /* nDims */
    86,                                                    /* lineNo */
    11,                                                    /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo cb_emlrtECI = {
    2,                                                     /* nDims */
    82,                                                    /* lineNo */
    8,                                                     /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo db_emlrtECI = {
    1,                                                     /* nDims */
    82,                                                    /* lineNo */
    8,                                                     /* colNo */
    "findupdate",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtBCInfo fb_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    91,                                                     /* lineNo */
    7,                                                      /* colNo */
    "scale",                                                /* aName */
    "findupdate",                                           /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtBCInfo gb_emlrtBCI = {
    -1,                                                     /* iFirst */
    -1,                                                     /* iLast */
    92,                                                     /* lineNo */
    7,                                                      /* colNo */
    "scale",                                                /* aName */
    "findupdate",                                           /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m", /* pName */
    0                                                       /* checkKind */
};

static emlrtECInfo eb_emlrtECI = {
    2,                                                     /* nDims */
    153,                                                   /* lineNo */
    6,                                                     /* colNo */
    "compose",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo fb_emlrtECI = {
    1,                                                     /* nDims */
    153,                                                   /* lineNo */
    6,                                                     /* colNo */
    "compose",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo gb_emlrtECI = {
    2,                                                     /* nDims */
    152,                                                   /* lineNo */
    6,                                                     /* colNo */
    "compose",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo hb_emlrtECI = {
    1,                                                     /* nDims */
    152,                                                   /* lineNo */
    6,                                                     /* colNo */
    "compose",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo ib_emlrtECI = {
    2,                                                     /* nDims */
    146,                                                   /* lineNo */
    11,                                                    /* colNo */
    "compose",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo jb_emlrtECI = {
    1,                                                     /* nDims */
    146,                                                   /* lineNo */
    11,                                                    /* colNo */
    "compose",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo kb_emlrtECI = {
    2,                                                     /* nDims */
    145,                                                   /* lineNo */
    11,                                                    /* colNo */
    "compose",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo lb_emlrtECI = {
    1,                                                     /* nDims */
    145,                                                   /* lineNo */
    11,                                                    /* colNo */
    "compose",                                             /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo y_emlrtRTEI = {
    138,                                                   /* lineNo */
    7,                                                     /* colNo */
    "expfield",                                            /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo mb_emlrtECI = {
    2,                                                     /* nDims */
    129,                                                   /* lineNo */
    10,                                                    /* colNo */
    "expfield",                                            /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo nb_emlrtECI = {
    1,                                                     /* nDims */
    129,                                                   /* lineNo */
    10,                                                    /* colNo */
    "expfield",                                            /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo ob_emlrtECI = {
    1,                                                     /* nDims */
    104,                                                   /* lineNo */
    11,                                                    /* colNo */
    "iminterpolate",                                       /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo pb_emlrtECI = {
    2,                                                     /* nDims */
    104,                                                   /* lineNo */
    11,                                                    /* colNo */
    "iminterpolate",                                       /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo qb_emlrtECI = {
    1,                                                     /* nDims */
    105,                                                   /* lineNo */
    11,                                                    /* colNo */
    "iminterpolate",                                       /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo rb_emlrtECI = {
    2,                                                     /* nDims */
    105,                                                   /* lineNo */
    11,                                                    /* colNo */
    "iminterpolate",                                       /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo sb_emlrtECI = {
    1,                                                     /* nDims */
    118,                                                   /* lineNo */
    16,                                                    /* colNo */
    "imgaussian",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtECInfo tb_emlrtECI = {
    2,                                                     /* nDims */
    118,                                                   /* lineNo */
    16,                                                    /* colNo */
    "imgaussian",                                          /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo ab_emlrtRTEI = {
    16,                                                    /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo bb_emlrtRTEI = {
    17,                                                    /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo cb_emlrtRTEI = {
    20,                                                    /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo db_emlrtRTEI = {
    20,                                                    /* lineNo */
    14,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo eb_emlrtRTEI = {
    22,                                                    /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo fb_emlrtRTEI = {
    63,                                                    /* lineNo */
    2,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo gb_emlrtRTEI = {
    63,                                                    /* lineNo */
    5,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo hb_emlrtRTEI = {
    68,                                                    /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo ib_emlrtRTEI = {
    69,                                                    /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo jb_emlrtRTEI = {
    45,                                                    /* lineNo */
    6,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo kb_emlrtRTEI = {
    45,                                                    /* lineNo */
    9,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo lb_emlrtRTEI = {
    70,                                                    /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo mb_emlrtRTEI = {
    173,                                                   /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo nb_emlrtRTEI = {
    71,                                                    /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo pb_emlrtRTEI = {
    72,                                                    /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo qb_emlrtRTEI =
    {
        31,            /* lineNo */
        30,            /* colNo */
        "unsafeSxfun", /* fName */
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
        "internal\\unsafeSxfun.m" /* pName */
};

static emlrtRTEInfo rb_emlrtRTEI = {
    50,                                                    /* lineNo */
    9,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo sb_emlrtRTEI = {
    50,                                                    /* lineNo */
    22,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo tb_emlrtRTEI = {
    27,                                                    /* lineNo */
    6,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo ub_emlrtRTEI = {
    27,                                                    /* lineNo */
    9,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo vb_emlrtRTEI = {
    2,                                                     /* lineNo */
    38,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo wb_emlrtRTEI = {
    159,                                                   /* lineNo */
    7,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo xb_emlrtRTEI = {
    190,                                                   /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo yb_emlrtRTEI = {
    77,                                                    /* lineNo */
    2,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo ac_emlrtRTEI = {
    77,                                                    /* lineNo */
    5,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo bc_emlrtRTEI = {
    79,                                                    /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo cc_emlrtRTEI = {
    82,                                                    /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo dc_emlrtRTEI = {
    86,                                                    /* lineNo */
    11,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo ec_emlrtRTEI = {
    86,                                                    /* lineNo */
    19,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo fc_emlrtRTEI = {
    90,                                                    /* lineNo */
    27,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo gc_emlrtRTEI = {
    90,                                                    /* lineNo */
    18,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo hc_emlrtRTEI = {
    90,                                                    /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo ic_emlrtRTEI = {
    97,                                                    /* lineNo */
    8,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo jc_emlrtRTEI = {
    98,                                                    /* lineNo */
    8,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo kc_emlrtRTEI = {
    86,                                                    /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo ud_emlrtRTEI = {
    193,                                                   /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo vd_emlrtRTEI = {
    129,                                                   /* lineNo */
    10,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo wd_emlrtRTEI = {
    129,                                                   /* lineNo */
    18,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo xd_emlrtRTEI =
    {
        28,      /* lineNo */
        9,       /* colNo */
        "colon", /* fName */
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\lib\\matlab\\ops\\colon.m" /* pName
                                                                          */
};

static emlrtRTEInfo yd_emlrtRTEI = {
    145,                                                   /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo ae_emlrtRTEI = {
    146,                                                   /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo be_emlrtRTEI = {
    129,                                                   /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo ce_emlrtRTEI = {
    149,                                                   /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo de_emlrtRTEI = {
    150,                                                   /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo ee_emlrtRTEI = {
    144,                                                   /* lineNo */
    16,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo fe_emlrtRTEI = {
    144,                                                   /* lineNo */
    34,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo ge_emlrtRTEI = {
    104,                                                   /* lineNo */
    11,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo he_emlrtRTEI = {
    105,                                                   /* lineNo */
    11,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo ie_emlrtRTEI = {
    108,                                                   /* lineNo */
    17,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo je_emlrtRTEI = {
    101,                                                   /* lineNo */
    14,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo ke_emlrtRTEI = {
    103,                                                   /* lineNo */
    16,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo le_emlrtRTEI = {
    103,                                                   /* lineNo */
    33,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo me_emlrtRTEI = {
    118,                                                   /* lineNo */
    16,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo ne_emlrtRTEI = {
    118,                                                   /* lineNo */
    23,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo oe_emlrtRTEI = {
    118,                                                   /* lineNo */
    1,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo pe_emlrtRTEI = {
    112,                                                   /* lineNo */
    14,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo qe_emlrtRTEI = {
    117,                                                   /* lineNo */
    17,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo re_emlrtRTEI = {
    117,                                                   /* lineNo */
    32,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo hf_emlrtRTEI = {
    167,                                                   /* lineNo */
    9,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo if_emlrtRTEI = {
    168,                                                   /* lineNo */
    5,                                                     /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo kf_emlrtRTEI = {
    36,                                                    /* lineNo */
    10,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRTEInfo mf_emlrtRTEI = {
    118,                                                   /* lineNo */
    14,                                                    /* colNo */
    "register_in_lite",                                    /* fName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pName */
};

static emlrtRSInfo ag_emlrtRSI = {
    167,                                                   /* lineNo */
    "jacobian",                                            /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo bg_emlrtRSI = {
    98,                                                    /* lineNo */
    "findupdate",                                          /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo cg_emlrtRSI = {
    97,                                                    /* lineNo */
    "findupdate",                                          /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo dg_emlrtRSI = {
    94,                                                    /* lineNo */
    "findupdate",                                          /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo eg_emlrtRSI = {
    93,                                                    /* lineNo */
    "findupdate",                                          /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo fg_emlrtRSI = {
    168,                                                   /* lineNo */
    "jacobian",                                            /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo gg_emlrtRSI =
    {
        31,            /* lineNo */
        "unsafeSxfun", /* fcnName */
        "C:\\Program "
        "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+"
        "internal\\unsafeSxfun.m" /* pathName */
};

static emlrtRSInfo hg_emlrtRSI = {
    152,                                                   /* lineNo */
    "compose",                                             /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo ig_emlrtRSI = {
    153,                                                   /* lineNo */
    "compose",                                             /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo jg_emlrtRSI = {
    36,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo kg_emlrtRSI = {
    35,                                                    /* lineNo */
    "register_in_lite",                                    /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo lg_emlrtRSI = {
    52,    /* lineNo */
    "div", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2023a\\toolbox\\eml\\eml\\+coder\\+internal\\div.m" /* pathName
                                                                          */
};

static emlrtRSInfo mg_emlrtRSI = {
    145,                                                   /* lineNo */
    "compose",                                             /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo ng_emlrtRSI = {
    146,                                                   /* lineNo */
    "compose",                                             /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

static emlrtRSInfo og_emlrtRSI = {
    82,                                                    /* lineNo */
    "findupdate",                                          /* fcnName */
    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m" /* pathName */
};

/* Function Declarations */
static void b_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emlrtRSInfo in2,
                               const emxArray_real_T *in3,
                               const emxArray_real_T *in4,
                               const emxArray_real_T *in5,
                               const emxArray_real_T *in6);

static void b_imagepad(const emlrtStack *sp, emxArray_real_T *b_I,
                       real_T scale);

static void b_minus(const emlrtStack *sp, emxArray_real_T *in1,
                    const emxArray_real_T *in2, const emxArray_real_T *in3);

static void b_plus(const emlrtStack *sp, emxArray_real_T *in1,
                   const emxArray_real_T *in2);

static void c_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emxArray_real_T *in2, real_T in3);

static void c_plus(const emlrtStack *sp, emxArray_real_T *in1,
                   const emxArray_real_T *in2, const emxArray_real_T *in3);

static void expfield(const emlrtStack *sp, emxArray_real_T *vx,
                     emxArray_real_T *vy);

static void findupdate(const emlrtStack *sp, const emxArray_real_T *F,
                       const emxArray_real_T *M, const emxArray_real_T *vx,
                       const emxArray_real_T *vy, real_T sigma_i,
                       real_T sigma_x, emxArray_real_T *ux,
                       emxArray_real_T *uy);

static void imagepad(const emlrtStack *sp, const emxArray_uint8_T *b_I,
                     real_T scale, emxArray_real_T *c_I, real_T lim[4]);

static void imgaussian(const emlrtStack *sp, emxArray_real_T *b_I,
                       real_T sigma);

static void iminterpolate(const emlrtStack *sp, emxArray_real_T *b_I,
                          const emxArray_real_T *sx, const emxArray_real_T *sy);

static void minus(const emlrtStack *sp, emxArray_real_T *in1,
                  const emxArray_real_T *in2);

static void plus(const emlrtStack *sp, emxArray_real_T *in1,
                 const emxArray_real_T *in2);

static void times(const emlrtStack *sp, emxArray_real_T *in1,
                  const emxArray_real_T *in2);

/* Function Definitions */
static void b_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emlrtRSInfo in2,
                               const emxArray_real_T *in3,
                               const emxArray_real_T *in4,
                               const emxArray_real_T *in5,
                               const emxArray_real_T *in6)
{
  emlrtStack st;
  emxArray_real_T *b_in1;
  emxArray_real_T *b_in3;
  emxArray_real_T *b_in4;
  const real_T *in3_data;
  const real_T *in4_data;
  const real_T *in5_data;
  const real_T *in6_data;
  real_T *b_in3_data;
  real_T *in1_data;
  int32_T aux_0_1;
  int32_T aux_1_1;
  int32_T b_loop_ub;
  int32_T i;
  int32_T i1;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_0_1;
  int32_T stride_1_0;
  int32_T stride_1_1;
  st.prev = sp;
  st.tls = sp->tls;
  in6_data = in6->data;
  in5_data = in5->data;
  in4_data = in4->data;
  in3_data = in3->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  emxInit_real_T(sp, &b_in3, 2, &ge_emlrtRTEI);
  if (in5->size[0] == 1) {
    loop_ub = in3->size[0];
  } else {
    loop_ub = in5->size[0];
  }
  i = b_in3->size[0] * b_in3->size[1];
  b_in3->size[0] = loop_ub;
  if (in5->size[1] == 1) {
    b_loop_ub = in3->size[1];
  } else {
    b_loop_ub = in5->size[1];
  }
  b_in3->size[1] = b_loop_ub;
  emxEnsureCapacity_real_T(sp, b_in3, i, &ge_emlrtRTEI);
  b_in3_data = b_in3->data;
  stride_0_0 = (in3->size[0] != 1);
  stride_0_1 = (in3->size[1] != 1);
  stride_1_0 = (in5->size[0] != 1);
  stride_1_1 = (in5->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (i = 0; i < b_loop_ub; i++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      b_in3_data[i1 + b_in3->size[0] * i] =
          in3_data[i1 * stride_0_0 + in3->size[0] * aux_0_1] +
          in5_data[i1 * stride_1_0 + in5->size[0] * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  emxInit_real_T(sp, &b_in4, 2, &he_emlrtRTEI);
  if (in6->size[0] == 1) {
    loop_ub = in4->size[0];
  } else {
    loop_ub = in6->size[0];
  }
  i = b_in4->size[0] * b_in4->size[1];
  b_in4->size[0] = loop_ub;
  if (in6->size[1] == 1) {
    b_loop_ub = in4->size[1];
  } else {
    b_loop_ub = in6->size[1];
  }
  b_in4->size[1] = b_loop_ub;
  emxEnsureCapacity_real_T(sp, b_in4, i, &he_emlrtRTEI);
  b_in3_data = b_in4->data;
  stride_0_0 = (in4->size[0] != 1);
  stride_0_1 = (in4->size[1] != 1);
  stride_1_0 = (in6->size[0] != 1);
  stride_1_1 = (in6->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (i = 0; i < b_loop_ub; i++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      b_in3_data[i1 + b_in4->size[0] * i] =
          in4_data[i1 * stride_0_0 + in4->size[0] * aux_0_1] +
          in6_data[i1 * stride_1_0 + in6->size[0] * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  emxInit_real_T(sp, &b_in1, 2, &ie_emlrtRTEI);
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = in1->size[0];
  b_in1->size[1] = in1->size[1];
  emxEnsureCapacity_real_T(sp, b_in1, i, &ie_emlrtRTEI);
  b_in3_data = b_in1->data;
  loop_ub = in1->size[0] * in1->size[1] - 1;
  for (i = 0; i <= loop_ub; i++) {
    b_in3_data[i] = in1_data[i];
  }
  st.site = (emlrtRSInfo *)&in2;
  interpn(&st, in3, in4, b_in1, b_in3, b_in4, in1);
  emxFree_real_T(sp, &b_in1);
  emxFree_real_T(sp, &b_in4);
  emxFree_real_T(sp, &b_in3);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void b_imagepad(const emlrtStack *sp, emxArray_real_T *b_I, real_T scale)
{
  emxArray_real_T *Ip;
  real_T lim_idx_1;
  real_T lim_idx_3;
  real_T x_idx_0;
  real_T x_idx_1;
  real_T y_idx_0;
  real_T y_idx_1;
  real_T *I_data;
  real_T *Ip_data;
  int32_T iv[2];
  int32_T b_loop_ub;
  int32_T i;
  int32_T i1;
  int32_T i2;
  int32_T i3;
  int32_T loop_ub;
  I_data = b_I->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  /*  Pad image */
  y_idx_0 = muDoubleScalarCeil((real_T)b_I->size[0] * scale);
  y_idx_1 = muDoubleScalarCeil((real_T)b_I->size[1] * scale);
  if (!(y_idx_0 >= 0.0)) {
    emlrtNonNegativeCheckR2012b(y_idx_0, &db_emlrtDCI, (emlrtConstCTX)sp);
  }
  if (y_idx_0 != (int32_T)y_idx_0) {
    emlrtIntegerCheckR2012b(y_idx_0, &cb_emlrtDCI, (emlrtConstCTX)sp);
  }
  if (!(y_idx_1 >= 0.0)) {
    emlrtNonNegativeCheckR2012b(y_idx_1, &db_emlrtDCI, (emlrtConstCTX)sp);
  }
  if (y_idx_1 != (int32_T)y_idx_1) {
    emlrtIntegerCheckR2012b(y_idx_1, &cb_emlrtDCI, (emlrtConstCTX)sp);
  }
  emxInit_real_T(sp, &Ip, 2, &xb_emlrtRTEI);
  i = Ip->size[0] * Ip->size[1];
  Ip->size[0] = (int32_T)y_idx_0;
  Ip->size[1] = (int32_T)y_idx_1;
  emxEnsureCapacity_real_T(sp, Ip, i, &xb_emlrtRTEI);
  Ip_data = Ip->data;
  loop_ub = (int32_T)y_idx_0 * (int32_T)y_idx_1;
  for (i = 0; i < loop_ub; i++) {
    Ip_data[i] = 0.0;
  }
  i = b_I->size[0];
  x_idx_0 = muDoubleScalarFloor((real_T)i * (scale - 1.0) / 2.0);
  lim_idx_1 = x_idx_0 + (real_T)(uint32_T)i;
  i = b_I->size[1];
  x_idx_1 = muDoubleScalarFloor((real_T)i * (scale - 1.0) / 2.0);
  lim_idx_3 = x_idx_1 + (real_T)(uint32_T)i;
  /*  image limits */
  if (x_idx_0 + 1.0 > lim_idx_1) {
    i = 0;
    i1 = 0;
  } else {
    if (x_idx_0 + 1.0 != (int32_T)(x_idx_0 + 1.0)) {
      emlrtIntegerCheckR2012b(x_idx_0 + 1.0, &x_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)(x_idx_0 + 1.0) < 1) ||
        ((int32_T)(x_idx_0 + 1.0) > (int32_T)y_idx_0)) {
      emlrtDynamicBoundsCheckR2012b((int32_T)(x_idx_0 + 1.0), 1,
                                    (int32_T)y_idx_0, &bb_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
    i = (int32_T)(x_idx_0 + 1.0) - 1;
    if (lim_idx_1 != (int32_T)lim_idx_1) {
      emlrtIntegerCheckR2012b(lim_idx_1, &y_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim_idx_1 < 1) || ((int32_T)lim_idx_1 > (int32_T)y_idx_0)) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim_idx_1, 1, (int32_T)y_idx_0,
                                    &cb_emlrtBCI, (emlrtConstCTX)sp);
    }
    i1 = (int32_T)lim_idx_1;
  }
  if (x_idx_1 + 1.0 > lim_idx_3) {
    i2 = 0;
    i3 = 0;
  } else {
    if (x_idx_1 + 1.0 != (int32_T)(x_idx_1 + 1.0)) {
      emlrtIntegerCheckR2012b(x_idx_1 + 1.0, &ab_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)(x_idx_1 + 1.0) < 1) ||
        ((int32_T)(x_idx_1 + 1.0) > (int32_T)y_idx_1)) {
      emlrtDynamicBoundsCheckR2012b((int32_T)(x_idx_1 + 1.0), 1,
                                    (int32_T)y_idx_1, &db_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
    i2 = (int32_T)(x_idx_1 + 1.0) - 1;
    if (lim_idx_3 != (int32_T)lim_idx_3) {
      emlrtIntegerCheckR2012b(lim_idx_3, &bb_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim_idx_3 < 1) || ((int32_T)lim_idx_3 > (int32_T)y_idx_1)) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim_idx_3, 1, (int32_T)y_idx_1,
                                    &eb_emlrtBCI, (emlrtConstCTX)sp);
    }
    i3 = (int32_T)lim_idx_3;
  }
  iv[0] = i1 - i;
  iv[1] = i3 - i2;
  emlrtSubAssignSizeCheckR2012b(&iv[0], 2, &b_I->size[0], 2, &k_emlrtECI,
                                (emlrtCTX)sp);
  loop_ub = b_I->size[1];
  for (i1 = 0; i1 < loop_ub; i1++) {
    b_loop_ub = b_I->size[0];
    for (i3 = 0; i3 < b_loop_ub; i3++) {
      Ip_data[(i + i3) + Ip->size[0] * (i2 + i1)] =
          I_data[i3 + b_I->size[0] * i1];
    }
  }
  /*  padded image */
  i = b_I->size[0] * b_I->size[1];
  b_I->size[0] = Ip->size[0];
  b_I->size[1] = Ip->size[1];
  emxEnsureCapacity_real_T(sp, b_I, i, &ud_emlrtRTEI);
  I_data = b_I->data;
  loop_ub = Ip->size[1];
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = Ip->size[0];
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      I_data[i1 + b_I->size[0] * i] = Ip_data[i1 + Ip->size[0] * i];
    }
  }
  emxFree_real_T(sp, &Ip);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void b_minus(const emlrtStack *sp, emxArray_real_T *in1,
                    const emxArray_real_T *in2, const emxArray_real_T *in3)
{
  const real_T *in2_data;
  const real_T *in3_data;
  real_T *in1_data;
  int32_T aux_0_1;
  int32_T aux_1_1;
  int32_T b_loop_ub;
  int32_T i;
  int32_T i1;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_0_1;
  int32_T stride_1_0;
  int32_T stride_1_1;
  in3_data = in3->data;
  in2_data = in2->data;
  if (in3->size[0] == 1) {
    loop_ub = in2->size[0];
  } else {
    loop_ub = in3->size[0];
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = loop_ub;
  emxEnsureCapacity_real_T(sp, in1, i, &cc_emlrtRTEI);
  if (in3->size[1] == 1) {
    b_loop_ub = in2->size[1];
  } else {
    b_loop_ub = in3->size[1];
  }
  i = in1->size[0] * in1->size[1];
  in1->size[1] = b_loop_ub;
  emxEnsureCapacity_real_T(sp, in1, i, &cc_emlrtRTEI);
  in1_data = in1->data;
  stride_0_0 = (in2->size[0] != 1);
  stride_0_1 = (in2->size[1] != 1);
  stride_1_0 = (in3->size[0] != 1);
  stride_1_1 = (in3->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (i = 0; i < b_loop_ub; i++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      in1_data[i1 + in1->size[0] * i] =
          in2_data[i1 * stride_0_0 + in2->size[0] * aux_0_1] -
          in3_data[i1 * stride_1_0 + in3->size[0] * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
}

static void b_plus(const emlrtStack *sp, emxArray_real_T *in1,
                   const emxArray_real_T *in2)
{
  emxArray_real_T *b_in2;
  const real_T *in2_data;
  real_T *b_in2_data;
  real_T *in1_data;
  int32_T aux_0_1;
  int32_T aux_1_1;
  int32_T b_loop_ub;
  int32_T i;
  int32_T i1;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_0_1;
  int32_T stride_1_0;
  int32_T stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  emxInit_real_T(sp, &b_in2, 2, &gc_emlrtRTEI);
  if (in1->size[0] == 1) {
    loop_ub = in2->size[0];
  } else {
    loop_ub = in1->size[0];
  }
  i = b_in2->size[0] * b_in2->size[1];
  b_in2->size[0] = loop_ub;
  if (in1->size[1] == 1) {
    b_loop_ub = in2->size[1];
  } else {
    b_loop_ub = in1->size[1];
  }
  b_in2->size[1] = b_loop_ub;
  emxEnsureCapacity_real_T(sp, b_in2, i, &gc_emlrtRTEI);
  b_in2_data = b_in2->data;
  stride_0_0 = (in2->size[0] != 1);
  stride_0_1 = (in2->size[1] != 1);
  stride_1_0 = (in1->size[0] != 1);
  stride_1_1 = (in1->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (i = 0; i < b_loop_ub; i++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      b_in2_data[i1 + b_in2->size[0] * i] =
          in2_data[i1 * stride_0_0 + in2->size[0] * aux_0_1] +
          in1_data[i1 * stride_1_0 + in1->size[0] * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = b_in2->size[0];
  in1->size[1] = b_in2->size[1];
  emxEnsureCapacity_real_T(sp, in1, i, &gc_emlrtRTEI);
  in1_data = in1->data;
  loop_ub = b_in2->size[1];
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = b_in2->size[0];
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      in1_data[i1 + in1->size[0] * i] = b_in2_data[i1 + b_in2->size[0] * i];
    }
  }
  emxFree_real_T(sp, &b_in2);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void c_binary_expand_op(const emlrtStack *sp, emxArray_real_T *in1,
                               const emxArray_real_T *in2, real_T in3)
{
  emxArray_real_T *b_in1;
  const real_T *in2_data;
  real_T d;
  real_T *b_in1_data;
  real_T *in1_data;
  int32_T aux_0_1;
  int32_T aux_1_1;
  int32_T b_loop_ub;
  int32_T i;
  int32_T i1;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_0_1;
  int32_T stride_1_0;
  int32_T stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  d = 2.0 * in3;
  emxInit_real_T(sp, &b_in1, 2, &mf_emlrtRTEI);
  if (in2->size[0] == 1) {
    loop_ub = in1->size[0];
  } else {
    loop_ub = in2->size[0];
  }
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = loop_ub;
  if (in2->size[1] == 1) {
    b_loop_ub = in1->size[1];
  } else {
    b_loop_ub = in2->size[1];
  }
  b_in1->size[1] = b_loop_ub;
  emxEnsureCapacity_real_T(sp, b_in1, i, &mf_emlrtRTEI);
  b_in1_data = b_in1->data;
  stride_0_0 = (in1->size[0] != 1);
  stride_0_1 = (in1->size[1] != 1);
  stride_1_0 = (in2->size[0] != 1);
  stride_1_1 = (in2->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (i = 0; i < b_loop_ub; i++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      b_in1_data[i1 + b_in1->size[0] * i] =
          -(in1_data[i1 * stride_0_0 + in1->size[0] * aux_0_1] +
            in2_data[i1 * stride_1_0 + in2->size[0] * aux_1_1]) /
          d;
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = b_in1->size[0];
  in1->size[1] = b_in1->size[1];
  emxEnsureCapacity_real_T(sp, in1, i, &mf_emlrtRTEI);
  in1_data = in1->data;
  loop_ub = b_in1->size[1];
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = b_in1->size[0];
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      in1_data[i1 + in1->size[0] * i] = b_in1_data[i1 + b_in1->size[0] * i];
    }
  }
  emxFree_real_T(sp, &b_in1);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void c_plus(const emlrtStack *sp, emxArray_real_T *in1,
                   const emxArray_real_T *in2, const emxArray_real_T *in3)
{
  const real_T *in2_data;
  const real_T *in3_data;
  real_T *in1_data;
  int32_T aux_0_1;
  int32_T aux_1_1;
  int32_T b_loop_ub;
  int32_T i;
  int32_T i1;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_0_1;
  int32_T stride_1_0;
  int32_T stride_1_1;
  in3_data = in3->data;
  in2_data = in2->data;
  if (in3->size[0] == 1) {
    loop_ub = in2->size[0];
  } else {
    loop_ub = in3->size[0];
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = loop_ub;
  emxEnsureCapacity_real_T(sp, in1, i, &ae_emlrtRTEI);
  if (in3->size[1] == 1) {
    b_loop_ub = in2->size[1];
  } else {
    b_loop_ub = in3->size[1];
  }
  i = in1->size[0] * in1->size[1];
  in1->size[1] = b_loop_ub;
  emxEnsureCapacity_real_T(sp, in1, i, &ae_emlrtRTEI);
  in1_data = in1->data;
  stride_0_0 = (in2->size[0] != 1);
  stride_0_1 = (in2->size[1] != 1);
  stride_1_0 = (in3->size[0] != 1);
  stride_1_1 = (in3->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (i = 0; i < b_loop_ub; i++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      in1_data[i1 + in1->size[0] * i] =
          in2_data[i1 * stride_0_0 + in2->size[0] * aux_0_1] +
          in3_data[i1 * stride_1_0 + in3->size[0] * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
}

static void expfield(const emlrtStack *sp, emxArray_real_T *vx,
                     emxArray_real_T *vy)
{
  __m128d r;
  __m128d r1;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  emlrtStack h_st;
  emlrtStack i_st;
  emlrtStack st;
  emxArray_real_T *b_y;
  emxArray_real_T *bxp;
  emxArray_real_T *byp;
  emxArray_real_T *normv2;
  emxArray_real_T *x;
  emxArray_real_T *x_prime;
  emxArray_real_T *y;
  emxArray_real_T *y_prime;
  real_T m;
  real_T n;
  real_T *normv2_data;
  real_T *vx_data;
  real_T *vy_data;
  real_T *x_prime_data;
  real_T *y_prime_data;
  int32_T b_i;
  int32_T eint;
  int32_T i;
  int32_T i1;
  int32_T idx;
  int32_T loop_ub_tmp;
  int32_T scalarLB;
  int32_T vectorUB;
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
  vy_data = vy->data;
  vx_data = vx->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  /*  Exponentiate vector field */
  /*   Changed: Dec 6th, 2011 */
  /*  */
  /*  Find n, scaling parameter */
  st.site = &s_emlrtRSI;
  b_st.site = &y_emlrtRSI;
  emxInit_real_T(&b_st, &normv2, 2, &be_emlrtRTEI);
  i = normv2->size[0] * normv2->size[1];
  normv2->size[0] = vx->size[0];
  normv2->size[1] = vx->size[1];
  emxEnsureCapacity_real_T(&b_st, normv2, i, &vd_emlrtRTEI);
  normv2_data = normv2->data;
  idx = vx->size[0] * vx->size[1];
  for (i = 0; i < idx; i++) {
    n = vx_data[i];
    normv2_data[i] = n * n;
  }
  st.site = &s_emlrtRSI;
  b_st.site = &y_emlrtRSI;
  emxInit_real_T(&b_st, &x, 2, &vd_emlrtRTEI);
  i = x->size[0] * x->size[1];
  x->size[0] = vy->size[0];
  x->size[1] = vy->size[1];
  emxEnsureCapacity_real_T(&b_st, x, i, &wd_emlrtRTEI);
  y_prime_data = x->data;
  loop_ub_tmp = vy->size[0] * vy->size[1];
  for (i = 0; i < loop_ub_tmp; i++) {
    n = vy_data[i];
    y_prime_data[i] = n * n;
  }
  if ((normv2->size[0] != x->size[0]) &&
      ((normv2->size[0] != 1) && (x->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(normv2->size[0], x->size[0], &nb_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((normv2->size[1] != x->size[1]) &&
      ((normv2->size[1] != 1) && (x->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(normv2->size[1], x->size[1], &mb_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((normv2->size[0] == x->size[0]) && (normv2->size[1] == x->size[1])) {
    scalarLB = (idx / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&normv2_data[i]);
      r1 = _mm_loadu_pd(&y_prime_data[i]);
      _mm_storeu_pd(&normv2_data[i], _mm_add_pd(r, r1));
    }
    for (i = scalarLB; i < idx; i++) {
      normv2_data[i] += y_prime_data[i];
    }
  } else {
    st.site = &s_emlrtRSI;
    plus(&st, normv2, x);
    normv2_data = normv2->data;
  }
  st.site = &t_emlrtRSI;
  b_st.site = &ab_emlrtRSI;
  c_st.site = &bb_emlrtRSI;
  d_st.site = &cb_emlrtRSI;
  loop_ub_tmp = normv2->size[0] * normv2->size[1];
  if (loop_ub_tmp < 1) {
    emlrtErrorWithMessageIdR2018a(&d_st, &w_emlrtRTEI,
                                  "Coder:toolbox:eml_min_or_max_varDimZero",
                                  "Coder:toolbox:eml_min_or_max_varDimZero", 0);
  }
  e_st.site = &db_emlrtRSI;
  f_st.site = &eb_emlrtRSI;
  if (loop_ub_tmp <= 2) {
    if (loop_ub_tmp == 1) {
      m = normv2_data[0];
    } else {
      m = normv2_data[1];
      if ((!(normv2_data[0] < m)) &&
          ((!muDoubleScalarIsNaN(normv2_data[0])) || muDoubleScalarIsNaN(m))) {
        m = normv2_data[0];
      }
    }
  } else {
    g_st.site = &gb_emlrtRSI;
    if (!muDoubleScalarIsNaN(normv2_data[0])) {
      idx = 1;
    } else {
      boolean_T exitg1;
      idx = 0;
      h_st.site = &hb_emlrtRSI;
      if (loop_ub_tmp > 2147483646) {
        i_st.site = &ib_emlrtRSI;
        check_forloop_overflow_error(&i_st);
      }
      vectorUB = 2;
      exitg1 = false;
      while ((!exitg1) && (vectorUB <= loop_ub_tmp)) {
        if (!muDoubleScalarIsNaN(normv2_data[vectorUB - 1])) {
          idx = vectorUB;
          exitg1 = true;
        } else {
          vectorUB++;
        }
      }
    }
    if (idx == 0) {
      m = normv2_data[0];
    } else {
      g_st.site = &fb_emlrtRSI;
      m = normv2_data[idx - 1];
      scalarLB = idx + 1;
      h_st.site = &jb_emlrtRSI;
      if ((idx + 1 <= loop_ub_tmp) && (loop_ub_tmp > 2147483646)) {
        i_st.site = &ib_emlrtRSI;
        check_forloop_overflow_error(&i_st);
      }
      for (vectorUB = scalarLB; vectorUB <= loop_ub_tmp; vectorUB++) {
        n = normv2_data[vectorUB - 1];
        if (m < n) {
          m = n;
        }
      }
    }
  }
  st.site = &t_emlrtRSI;
  if (m < 0.0) {
    emlrtErrorWithMessageIdR2018a(
        &st, &v_emlrtRTEI, "Coder:toolbox:ElFunDomainError",
        "Coder:toolbox:ElFunDomainError", 3, 4, 4, "sqrt");
  }
  m = muDoubleScalarSqrt(m);
  st.site = &u_emlrtRSI;
  n = m / 0.5;
  if (n == 0.0) {
    n = rtMinusInf;
  } else if ((!muDoubleScalarIsInf(n)) && (!muDoubleScalarIsNaN(n))) {
    n = frexp(n, &eint);
    if (n == 0.5) {
      n = (real_T)eint - 1.0;
    } else if ((eint == 1) && (n < 0.75)) {
      n = muDoubleScalarLog(2.0 * n) / 0.69314718055994529;
    } else {
      n = muDoubleScalarLog(n) / 0.69314718055994529 + (real_T)eint;
    }
  }
  /*  n big enough so max(v * 2^-n) < 0.5 pixel) */
  n = muDoubleScalarMax(muDoubleScalarCeil(n), 0.0);
  /*  avoid null values */
  /*  Scale it (so it's close to 0) */
  st.site = &v_emlrtRSI;
  b_st.site = &kb_emlrtRSI;
  c_st.site = &y_emlrtRSI;
  m = muDoubleScalarPower(2.0, -n);
  loop_ub_tmp = vx->size[1];
  for (i = 0; i < loop_ub_tmp; i++) {
    idx = vx->size[0];
    scalarLB = (idx / 2) << 1;
    vectorUB = scalarLB - 2;
    for (eint = 0; eint <= vectorUB; eint += 2) {
      r = _mm_loadu_pd(&vx_data[eint + vx->size[0] * i]);
      _mm_storeu_pd(&vx_data[eint + vx->size[0] * i],
                    _mm_mul_pd(r, _mm_set1_pd(m)));
    }
    for (eint = scalarLB; eint < idx; eint++) {
      vx_data[eint + vx->size[0] * i] *= m;
    }
  }
  st.site = &w_emlrtRSI;
  b_st.site = &kb_emlrtRSI;
  c_st.site = &y_emlrtRSI;
  loop_ub_tmp = vy->size[1];
  for (i = 0; i < loop_ub_tmp; i++) {
    idx = vy->size[0];
    scalarLB = (idx / 2) << 1;
    vectorUB = scalarLB - 2;
    for (eint = 0; eint <= vectorUB; eint += 2) {
      r = _mm_loadu_pd(&vy_data[eint + vy->size[0] * i]);
      _mm_storeu_pd(&vy_data[eint + vy->size[0] * i],
                    _mm_mul_pd(r, _mm_set1_pd(m)));
    }
    for (eint = scalarLB; eint < idx; eint++) {
      vy_data[eint + vy->size[0] * i] *= m;
    }
  }
  /*  square it n times */
  i = (int32_T)n;
  emlrtForLoopVectorCheckR2021a(1.0, 1.0, n, mxDOUBLE_CLASS, (int32_T)n,
                                &y_emlrtRTEI, (emlrtConstCTX)sp);
  emxInit_real_T(sp, &x_prime, 2, &yd_emlrtRTEI);
  emxInit_real_T(sp, &y_prime, 2, &ae_emlrtRTEI);
  emxInit_real_T(sp, &bxp, 2, &ce_emlrtRTEI);
  emxInit_real_T(sp, &byp, 2, &de_emlrtRTEI);
  emxInit_real_T(sp, &y, 2, &ee_emlrtRTEI);
  emxInit_real_T(sp, &b_y, 2, &fe_emlrtRTEI);
  for (b_i = 0; b_i < i; b_i++) {
    st.site = &x_emlrtRSI;
    /*  Compose two vector fields */
    eint = vx->size[0];
    if (eint - 1 < 0) {
      y->size[0] = 1;
      y->size[1] = 0;
    } else {
      i1 = y->size[0] * y->size[1];
      y->size[0] = 1;
      y->size[1] = eint;
      emxEnsureCapacity_real_T(&st, y, i1, &xd_emlrtRTEI);
      y_prime_data = y->data;
      loop_ub_tmp = eint - 1;
      for (eint = 0; eint <= loop_ub_tmp; eint++) {
        y_prime_data[eint] = eint;
      }
    }
    eint = vx->size[1];
    if (eint - 1 < 0) {
      b_y->size[0] = 1;
      b_y->size[1] = 0;
    } else {
      i1 = b_y->size[0] * b_y->size[1];
      b_y->size[0] = 1;
      b_y->size[1] = eint;
      emxEnsureCapacity_real_T(&st, b_y, i1, &xd_emlrtRTEI);
      y_prime_data = b_y->data;
      loop_ub_tmp = eint - 1;
      for (eint = 0; eint <= loop_ub_tmp; eint++) {
        y_prime_data[eint] = eint;
      }
    }
    b_st.site = &lb_emlrtRSI;
    ndgrid(&b_st, y, b_y, x, normv2);
    normv2_data = normv2->data;
    y_prime_data = x->data;
    /*  coordinate image */
    eint = vx->size[0];
    if ((x->size[0] != eint) && ((x->size[0] != 1) && (eint != 1))) {
      emlrtDimSizeImpxCheckR2021b(x->size[0], eint, &lb_emlrtECI, &st);
    }
    i1 = vx->size[1];
    if ((x->size[1] != i1) && ((x->size[1] != 1) && (i1 != 1))) {
      emlrtDimSizeImpxCheckR2021b(x->size[1], i1, &kb_emlrtECI, &st);
    }
    if ((x->size[0] == eint) && (x->size[1] == i1)) {
      eint = x_prime->size[0] * x_prime->size[1];
      x_prime->size[0] = x->size[0];
      x_prime->size[1] = x->size[1];
      emxEnsureCapacity_real_T(&st, x_prime, eint, &yd_emlrtRTEI);
      x_prime_data = x_prime->data;
      loop_ub_tmp = x->size[0] * x->size[1];
      scalarLB = (loop_ub_tmp / 2) << 1;
      vectorUB = scalarLB - 2;
      for (eint = 0; eint <= vectorUB; eint += 2) {
        r = _mm_loadu_pd(&y_prime_data[eint]);
        r1 = _mm_loadu_pd(&vx_data[eint]);
        _mm_storeu_pd(&x_prime_data[eint], _mm_add_pd(r, r1));
      }
      for (eint = scalarLB; eint < loop_ub_tmp; eint++) {
        x_prime_data[eint] = y_prime_data[eint] + vx_data[eint];
      }
    } else {
      b_st.site = &mg_emlrtRSI;
      c_plus(&b_st, x_prime, x, vx);
    }
    /*  updated x values */
    eint = vy->size[0];
    if ((normv2->size[0] != eint) && ((normv2->size[0] != 1) && (eint != 1))) {
      emlrtDimSizeImpxCheckR2021b(normv2->size[0], eint, &jb_emlrtECI, &st);
    }
    i1 = vy->size[1];
    if ((normv2->size[1] != i1) && ((normv2->size[1] != 1) && (i1 != 1))) {
      emlrtDimSizeImpxCheckR2021b(normv2->size[1], i1, &ib_emlrtECI, &st);
    }
    if ((normv2->size[0] == eint) && (normv2->size[1] == i1)) {
      eint = y_prime->size[0] * y_prime->size[1];
      y_prime->size[0] = normv2->size[0];
      y_prime->size[1] = normv2->size[1];
      emxEnsureCapacity_real_T(&st, y_prime, eint, &ae_emlrtRTEI);
      y_prime_data = y_prime->data;
      loop_ub_tmp = normv2->size[0] * normv2->size[1];
      scalarLB = (loop_ub_tmp / 2) << 1;
      vectorUB = scalarLB - 2;
      for (eint = 0; eint <= vectorUB; eint += 2) {
        r = _mm_loadu_pd(&normv2_data[eint]);
        r1 = _mm_loadu_pd(&vy_data[eint]);
        _mm_storeu_pd(&y_prime_data[eint], _mm_add_pd(r, r1));
      }
      for (eint = scalarLB; eint < loop_ub_tmp; eint++) {
        y_prime_data[eint] = normv2_data[eint] + vy_data[eint];
      }
    } else {
      b_st.site = &ng_emlrtRSI;
      c_plus(&b_st, y_prime, normv2, vy);
    }
    /*  updated y values */
    /*  Interpolate vector field b at position brought by vector field a */
    b_st.site = &mb_emlrtRSI;
    interpn(&b_st, x, normv2, vx, x_prime, y_prime, bxp);
    y_prime_data = bxp->data;
    /*  interpolated bx values at x+a(x) */
    b_st.site = &nb_emlrtRSI;
    interpn(&b_st, x, normv2, vy, x_prime, y_prime, byp);
    x_prime_data = byp->data;
    /*  interpolated bx values at x+a(x) */
    /*  Compose */
    eint = vx->size[0];
    if ((eint != bxp->size[0]) && ((eint != 1) && (bxp->size[0] != 1))) {
      emlrtDimSizeImpxCheckR2021b(eint, bxp->size[0], &hb_emlrtECI, &st);
    }
    loop_ub_tmp = vx->size[1];
    if ((loop_ub_tmp != bxp->size[1]) &&
        ((loop_ub_tmp != 1) && (bxp->size[1] != 1))) {
      emlrtDimSizeImpxCheckR2021b(loop_ub_tmp, bxp->size[1], &gb_emlrtECI, &st);
    }
    if ((eint == bxp->size[0]) && (loop_ub_tmp == bxp->size[1])) {
      for (eint = 0; eint < loop_ub_tmp; eint++) {
        idx = vx->size[0];
        scalarLB = (idx / 2) << 1;
        vectorUB = scalarLB - 2;
        for (i1 = 0; i1 <= vectorUB; i1 += 2) {
          r = _mm_loadu_pd(&vx_data[i1 + vx->size[0] * eint]);
          r1 = _mm_loadu_pd(&y_prime_data[i1 + bxp->size[0] * eint]);
          _mm_storeu_pd(&vx_data[i1 + vx->size[0] * eint], _mm_add_pd(r, r1));
        }
        for (i1 = scalarLB; i1 < idx; i1++) {
          vx_data[i1 + vx->size[0] * eint] +=
              y_prime_data[i1 + bxp->size[0] * eint];
        }
      }
    } else {
      b_st.site = &hg_emlrtRSI;
      plus(&b_st, vx, bxp);
      vx_data = vx->data;
    }
    eint = vy->size[0];
    if ((eint != byp->size[0]) && ((eint != 1) && (byp->size[0] != 1))) {
      emlrtDimSizeImpxCheckR2021b(eint, byp->size[0], &fb_emlrtECI, &st);
    }
    loop_ub_tmp = vy->size[1];
    if ((loop_ub_tmp != byp->size[1]) &&
        ((loop_ub_tmp != 1) && (byp->size[1] != 1))) {
      emlrtDimSizeImpxCheckR2021b(loop_ub_tmp, byp->size[1], &eb_emlrtECI, &st);
    }
    if ((eint == byp->size[0]) && (loop_ub_tmp == byp->size[1])) {
      for (eint = 0; eint < loop_ub_tmp; eint++) {
        idx = vy->size[0];
        scalarLB = (idx / 2) << 1;
        vectorUB = scalarLB - 2;
        for (i1 = 0; i1 <= vectorUB; i1 += 2) {
          r = _mm_loadu_pd(&vy_data[i1 + vy->size[0] * eint]);
          r1 = _mm_loadu_pd(&x_prime_data[i1 + byp->size[0] * eint]);
          _mm_storeu_pd(&vy_data[i1 + vy->size[0] * eint], _mm_add_pd(r, r1));
        }
        for (i1 = scalarLB; i1 < idx; i1++) {
          vy_data[i1 + vy->size[0] * eint] +=
              x_prime_data[i1 + byp->size[0] * eint];
        }
      }
    } else {
      b_st.site = &ig_emlrtRSI;
      plus(&b_st, vy, byp);
      vy_data = vy->data;
    }
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b((emlrtConstCTX)sp);
    }
  }
  emxFree_real_T(sp, &b_y);
  emxFree_real_T(sp, &y);
  emxFree_real_T(sp, &x);
  emxFree_real_T(sp, &byp);
  emxFree_real_T(sp, &bxp);
  emxFree_real_T(sp, &y_prime);
  emxFree_real_T(sp, &x_prime);
  emxFree_real_T(sp, &normv2);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void findupdate(const emlrtStack *sp, const emxArray_real_T *F,
                       const emxArray_real_T *M, const emxArray_real_T *vx,
                       const emxArray_real_T *vy, real_T sigma_i,
                       real_T sigma_x, emxArray_real_T *ux, emxArray_real_T *uy)
{
  __m128d r;
  __m128d r1;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  emxArray_real_T *M_prime;
  emxArray_real_T *diff;
  emxArray_real_T *normg2;
  emxArray_real_T *scale;
  const real_T *F_data;
  const real_T *M_data;
  const real_T *vx_data;
  const real_T *vy_data;
  real_T b;
  real_T c;
  real_T varargin_1;
  real_T *M_prime_data;
  real_T *diff_data;
  real_T *normg2_data;
  real_T *scale_data;
  real_T *ux_data;
  real_T *uy_data;
  int32_T b_loop_ub_tmp;
  int32_T c_loop_ub_tmp;
  int32_T i;
  int32_T loop_ub;
  int32_T loop_ub_tmp;
  int32_T scalarLB;
  int32_T vectorUB;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  vy_data = vy->data;
  vx_data = vx->data;
  M_data = M->data;
  F_data = F->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  /*  Find update between two images */
  /*  Get Transformation */
  emxInit_real_T(sp, &scale, 2, &hc_emlrtRTEI);
  i = scale->size[0] * scale->size[1];
  scale->size[0] = vx->size[0];
  scale->size[1] = vx->size[1];
  emxEnsureCapacity_real_T(sp, scale, i, &yb_emlrtRTEI);
  scale_data = scale->data;
  loop_ub = vx->size[0] * vx->size[1];
  for (i = 0; i < loop_ub; i++) {
    scale_data[i] = vx_data[i];
  }
  emxInit_real_T(sp, &diff, 2, &cc_emlrtRTEI);
  i = diff->size[0] * diff->size[1];
  diff->size[0] = vy->size[0];
  diff->size[1] = vy->size[1];
  emxEnsureCapacity_real_T(sp, diff, i, &ac_emlrtRTEI);
  diff_data = diff->data;
  loop_ub = vy->size[0] * vy->size[1];
  for (i = 0; i < loop_ub; i++) {
    diff_data[i] = vy_data[i];
  }
  st.site = &n_emlrtRSI;
  expfield(&st, scale, diff);
  /*  Interpolate updated image */
  emxInit_real_T(sp, &M_prime, 2, &bc_emlrtRTEI);
  i = M_prime->size[0] * M_prime->size[1];
  M_prime->size[0] = M->size[0];
  M_prime->size[1] = M->size[1];
  emxEnsureCapacity_real_T(sp, M_prime, i, &bc_emlrtRTEI);
  M_prime_data = M_prime->data;
  loop_ub = M->size[0] * M->size[1];
  for (i = 0; i < loop_ub; i++) {
    M_prime_data[i] = M_data[i];
  }
  st.site = &o_emlrtRSI;
  iminterpolate(&st, M_prime, scale, diff);
  M_prime_data = M_prime->data;
  /*  intensities at updated points */
  /*  image difference */
  if ((F->size[0] != M_prime->size[0]) &&
      ((F->size[0] != 1) && (M_prime->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(F->size[0], M_prime->size[0], &db_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((F->size[1] != M_prime->size[1]) &&
      ((F->size[1] != 1) && (M_prime->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(F->size[1], M_prime->size[1], &cb_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((F->size[0] == M_prime->size[0]) && (F->size[1] == M_prime->size[1])) {
    i = diff->size[0] * diff->size[1];
    diff->size[0] = F->size[0];
    diff->size[1] = F->size[1];
    emxEnsureCapacity_real_T(sp, diff, i, &cc_emlrtRTEI);
    diff_data = diff->data;
    loop_ub = F->size[0] * F->size[1];
    scalarLB = (loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&M_prime_data[i]);
      _mm_storeu_pd(&diff_data[i], _mm_sub_pd(_mm_loadu_pd(&F_data[i]), r));
    }
    for (i = scalarLB; i < loop_ub; i++) {
      diff_data[i] = F_data[i] - M_prime_data[i];
    }
  } else {
    st.site = &og_emlrtRSI;
    b_minus(&st, diff, F, M_prime);
    diff_data = diff->data;
  }
  /*  moving image gradient */
  st.site = &p_emlrtRSI;
  gradient(&st, M_prime, uy, ux);
  ux_data = ux->data;
  uy_data = uy->data;
  /*  image gradient */
  st.site = &q_emlrtRSI;
  b_st.site = &y_emlrtRSI;
  emxInit_real_T(&b_st, &normg2, 2, &kc_emlrtRTEI);
  i = normg2->size[0] * normg2->size[1];
  normg2->size[0] = ux->size[0];
  normg2->size[1] = ux->size[1];
  emxEnsureCapacity_real_T(&b_st, normg2, i, &dc_emlrtRTEI);
  normg2_data = normg2->data;
  loop_ub_tmp = ux->size[0] * ux->size[1];
  for (i = 0; i < loop_ub_tmp; i++) {
    varargin_1 = ux_data[i];
    normg2_data[i] = varargin_1 * varargin_1;
  }
  st.site = &q_emlrtRSI;
  b_st.site = &y_emlrtRSI;
  i = scale->size[0] * scale->size[1];
  scale->size[0] = uy->size[0];
  scale->size[1] = uy->size[1];
  emxEnsureCapacity_real_T(&b_st, scale, i, &ec_emlrtRTEI);
  scale_data = scale->data;
  b_loop_ub_tmp = uy->size[0] * uy->size[1];
  for (i = 0; i < b_loop_ub_tmp; i++) {
    varargin_1 = uy_data[i];
    scale_data[i] = varargin_1 * varargin_1;
  }
  if ((normg2->size[0] != scale->size[0]) &&
      ((normg2->size[0] != 1) && (scale->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(normg2->size[0], scale->size[0], &bb_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((normg2->size[1] != scale->size[1]) &&
      ((normg2->size[1] != 1) && (scale->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(normg2->size[1], scale->size[1], &ab_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((normg2->size[0] == scale->size[0]) &&
      (normg2->size[1] == scale->size[1])) {
    scalarLB = (loop_ub_tmp / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&normg2_data[i]);
      r1 = _mm_loadu_pd(&scale_data[i]);
      _mm_storeu_pd(&normg2_data[i], _mm_add_pd(r, r1));
    }
    for (i = scalarLB; i < loop_ub_tmp; i++) {
      normg2_data[i] += scale_data[i];
    }
  } else {
    st.site = &q_emlrtRSI;
    plus(&st, normg2, scale);
    normg2_data = normg2->data;
  }
  /*  squared norm of gradient */
  /*  area of moving image */
  /*  update is Idiff / (||J||^2+(Idiff^2)/sigma_x^2) J, with Idiff =
   * F(x)-M(x+s), and J = Grad(M(x+s)); */
  st.site = &r_emlrtRSI;
  b_st.site = &kb_emlrtRSI;
  b = sigma_i * sigma_i;
  st.site = &r_emlrtRSI;
  b_st.site = &y_emlrtRSI;
  st.site = &r_emlrtRSI;
  b_st.site = &kb_emlrtRSI;
  c = sigma_x * sigma_x;
  i = scale->size[0] * scale->size[1];
  scale->size[0] = diff->size[0];
  scale->size[1] = diff->size[1];
  emxEnsureCapacity_real_T(sp, scale, i, &fc_emlrtRTEI);
  scale_data = scale->data;
  c_loop_ub_tmp = diff->size[0] * diff->size[1];
  for (i = 0; i < c_loop_ub_tmp; i++) {
    varargin_1 = diff_data[i];
    scale_data[i] = varargin_1 * varargin_1 * b / c;
  }
  if ((normg2->size[0] != scale->size[0]) &&
      ((normg2->size[0] != 1) && (scale->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(normg2->size[0], scale->size[0], &y_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((normg2->size[1] != scale->size[1]) &&
      ((normg2->size[1] != 1) && (scale->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(normg2->size[1], scale->size[1], &x_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  st.site = &r_emlrtRSI;
  if ((normg2->size[0] == scale->size[0]) &&
      (normg2->size[1] == scale->size[1])) {
    loop_ub = normg2->size[0] * normg2->size[1];
    i = scale->size[0] * scale->size[1];
    scale->size[0] = normg2->size[0];
    scale->size[1] = normg2->size[1];
    emxEnsureCapacity_real_T(&st, scale, i, &gc_emlrtRTEI);
    scale_data = scale->data;
    scalarLB = (loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&normg2_data[i]);
      r1 = _mm_loadu_pd(&scale_data[i]);
      _mm_storeu_pd(&scale_data[i], _mm_add_pd(r, r1));
    }
    for (i = scalarLB; i < loop_ub; i++) {
      scale_data[i] += normg2_data[i];
    }
  } else {
    b_st.site = &r_emlrtRSI;
    b_plus(&b_st, scale, normg2);
  }
  b_st.site = &qc_emlrtRSI;
  c_st.site = &rc_emlrtRSI;
  if (((diff->size[0] != 1) && (scale->size[0] != 1) &&
       (diff->size[0] != scale->size[0])) ||
      ((diff->size[1] != 1) && (scale->size[1] != 1) &&
       (diff->size[1] != scale->size[1]))) {
    emlrtErrorWithMessageIdR2018a(&c_st, &b_emlrtRTEI,
                                  "MATLAB:sizeDimensionsMustMatch",
                                  "MATLAB:sizeDimensionsMustMatch", 0);
  }
  if ((diff->size[0] == scale->size[0]) && (diff->size[1] == scale->size[1])) {
    i = scale->size[0] * scale->size[1];
    scale->size[0] = diff->size[0];
    scale->size[1] = diff->size[1];
    emxEnsureCapacity_real_T(&b_st, scale, i, &hc_emlrtRTEI);
    scale_data = scale->data;
    scalarLB = (c_loop_ub_tmp / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&diff_data[i]);
      r1 = _mm_loadu_pd(&scale_data[i]);
      _mm_storeu_pd(&scale_data[i], _mm_div_pd(r, r1));
    }
    for (i = scalarLB; i < c_loop_ub_tmp; i++) {
      scale_data[i] = diff_data[i] / scale_data[i];
    }
  } else {
    c_st.site = &lg_emlrtRSI;
    rdivide(&c_st, scale, diff);
    scale_data = scale->data;
  }
  loop_ub = normg2->size[0] * normg2->size[1] - 1;
  for (scalarLB = 0; scalarLB <= loop_ub; scalarLB++) {
    if (normg2_data[scalarLB] == 0.0) {
      i = scale->size[0] * scale->size[1] - 1;
      if (scalarLB > i) {
        emlrtDynamicBoundsCheckR2012b(scalarLB, 0, i, &fb_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      scale_data[scalarLB] = 0.0;
    }
  }
  emxFree_real_T(sp, &normg2);
  loop_ub = diff->size[0] * diff->size[1] - 1;
  for (scalarLB = 0; scalarLB <= loop_ub; scalarLB++) {
    if (diff_data[scalarLB] == 0.0) {
      i = scale->size[0] * scale->size[1] - 1;
      if (scalarLB > i) {
        emlrtDynamicBoundsCheckR2012b(scalarLB, 0, i, &gb_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      scale_data[scalarLB] = 0.0;
    }
  }
  emxFree_real_T(sp, &diff);
  if ((ux->size[0] != scale->size[0]) &&
      ((ux->size[0] != 1) && (scale->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(ux->size[0], scale->size[0], &w_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((ux->size[1] != scale->size[1]) &&
      ((ux->size[1] != 1) && (scale->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(ux->size[1], scale->size[1], &v_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((ux->size[0] == scale->size[0]) && (ux->size[1] == scale->size[1])) {
    scalarLB = (loop_ub_tmp / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&ux_data[i]);
      r1 = _mm_loadu_pd(&scale_data[i]);
      _mm_storeu_pd(&ux_data[i], _mm_mul_pd(r, r1));
    }
    for (i = scalarLB; i < loop_ub_tmp; i++) {
      ux_data[i] *= scale_data[i];
    }
  } else {
    st.site = &eg_emlrtRSI;
    times(&st, ux, scale);
    ux_data = ux->data;
  }
  if ((uy->size[0] != scale->size[0]) &&
      ((uy->size[0] != 1) && (scale->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(uy->size[0], scale->size[0], &u_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((uy->size[1] != scale->size[1]) &&
      ((uy->size[1] != 1) && (scale->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(uy->size[1], scale->size[1], &t_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((uy->size[0] == scale->size[0]) && (uy->size[1] == scale->size[1])) {
    scalarLB = (b_loop_ub_tmp / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&uy_data[i]);
      r1 = _mm_loadu_pd(&scale_data[i]);
      _mm_storeu_pd(&uy_data[i], _mm_mul_pd(r, r1));
    }
    for (i = scalarLB; i < b_loop_ub_tmp; i++) {
      uy_data[i] *= scale_data[i];
    }
  } else {
    st.site = &dg_emlrtRSI;
    times(&st, uy, scale);
    uy_data = uy->data;
  }
  /*  Zero non overlapping areas */
  i = scale->size[0] * scale->size[1];
  scale->size[0] = F->size[0];
  scale->size[1] = F->size[1];
  emxEnsureCapacity_real_T(sp, scale, i, &ic_emlrtRTEI);
  scale_data = scale->data;
  loop_ub_tmp = F->size[0] * F->size[1];
  for (i = 0; i < loop_ub_tmp; i++) {
    scale_data[i] = (F_data[i] == 0.0);
  }
  if ((ux->size[0] != scale->size[0]) &&
      ((ux->size[0] != 1) && (scale->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(ux->size[0], scale->size[0], &s_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((ux->size[1] != scale->size[1]) &&
      ((ux->size[1] != 1) && (scale->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(ux->size[1], scale->size[1], &r_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((ux->size[0] == scale->size[0]) && (ux->size[1] == scale->size[1])) {
    loop_ub = ux->size[0] * ux->size[1];
    scalarLB = (loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&ux_data[i]);
      r1 = _mm_loadu_pd(&scale_data[i]);
      _mm_storeu_pd(&ux_data[i], _mm_mul_pd(r, r1));
    }
    for (i = scalarLB; i < loop_ub; i++) {
      ux_data[i] *= scale_data[i];
    }
  } else {
    st.site = &cg_emlrtRSI;
    times(&st, ux, scale);
    ux_data = ux->data;
  }
  if ((uy->size[0] != scale->size[0]) &&
      ((uy->size[0] != 1) && (scale->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(uy->size[0], scale->size[0], &q_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((uy->size[1] != scale->size[1]) &&
      ((uy->size[1] != 1) && (scale->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(uy->size[1], scale->size[1], &p_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((uy->size[0] == scale->size[0]) && (uy->size[1] == scale->size[1])) {
    loop_ub = uy->size[0] * uy->size[1];
    scalarLB = (loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&uy_data[i]);
      r1 = _mm_loadu_pd(&scale_data[i]);
      _mm_storeu_pd(&uy_data[i], _mm_mul_pd(r, r1));
    }
    for (i = scalarLB; i < loop_ub; i++) {
      uy_data[i] *= scale_data[i];
    }
  } else {
    st.site = &cg_emlrtRSI;
    times(&st, uy, scale);
    uy_data = uy->data;
  }
  i = scale->size[0] * scale->size[1];
  scale->size[0] = M_prime->size[0];
  scale->size[1] = M_prime->size[1];
  emxEnsureCapacity_real_T(sp, scale, i, &jc_emlrtRTEI);
  scale_data = scale->data;
  loop_ub_tmp = M_prime->size[0] * M_prime->size[1];
  for (i = 0; i < loop_ub_tmp; i++) {
    scale_data[i] = (M_prime_data[i] == 0.0);
  }
  if ((ux->size[0] != scale->size[0]) &&
      ((ux->size[0] != 1) && (scale->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(ux->size[0], scale->size[0], &o_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((ux->size[1] != scale->size[1]) &&
      ((ux->size[1] != 1) && (scale->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(ux->size[1], scale->size[1], &n_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((ux->size[0] == scale->size[0]) && (ux->size[1] == scale->size[1])) {
    loop_ub = ux->size[0] * ux->size[1];
    scalarLB = (loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&ux_data[i]);
      r1 = _mm_loadu_pd(&scale_data[i]);
      _mm_storeu_pd(&ux_data[i], _mm_mul_pd(r, r1));
    }
    for (i = scalarLB; i < loop_ub; i++) {
      ux_data[i] *= scale_data[i];
    }
  } else {
    st.site = &bg_emlrtRSI;
    times(&st, ux, scale);
  }
  emxFree_real_T(sp, &scale);
  for (i = 0; i < loop_ub_tmp; i++) {
    M_prime_data[i] = (M_prime_data[i] == 0.0);
  }
  if ((uy->size[0] != M_prime->size[0]) &&
      ((uy->size[0] != 1) && (M_prime->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(uy->size[0], M_prime->size[0], &m_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((uy->size[1] != M_prime->size[1]) &&
      ((uy->size[1] != 1) && (M_prime->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(uy->size[1], M_prime->size[1], &l_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((uy->size[0] == M_prime->size[0]) && (uy->size[1] == M_prime->size[1])) {
    loop_ub = uy->size[0] * uy->size[1];
    scalarLB = (loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&uy_data[i]);
      r1 = _mm_loadu_pd(&M_prime_data[i]);
      _mm_storeu_pd(&uy_data[i], _mm_mul_pd(r, r1));
    }
    for (i = scalarLB; i < loop_ub; i++) {
      uy_data[i] *= M_prime_data[i];
    }
  } else {
    st.site = &bg_emlrtRSI;
    times(&st, uy, M_prime);
  }
  emxFree_real_T(sp, &M_prime);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void imagepad(const emlrtStack *sp, const emxArray_uint8_T *b_I,
                     real_T scale, emxArray_real_T *c_I, real_T lim[4])
{
  real_T x_idx_0;
  real_T x_idx_1;
  real_T y_idx_0;
  real_T y_idx_1;
  real_T *b_I_data;
  int32_T iv[2];
  int32_T i;
  int32_T i1;
  int32_T i2;
  int32_T i3;
  int32_T loop_ub;
  const uint8_T *I_data;
  I_data = b_I->data;
  /*  Pad image */
  y_idx_0 = muDoubleScalarCeil((real_T)b_I->size[0] * scale);
  y_idx_1 = muDoubleScalarCeil((real_T)b_I->size[1] * scale);
  if (!(y_idx_0 >= 0.0)) {
    emlrtNonNegativeCheckR2012b(y_idx_0, &db_emlrtDCI, (emlrtConstCTX)sp);
  }
  if (y_idx_0 != (int32_T)y_idx_0) {
    emlrtIntegerCheckR2012b(y_idx_0, &cb_emlrtDCI, (emlrtConstCTX)sp);
  }
  if (!(y_idx_1 >= 0.0)) {
    emlrtNonNegativeCheckR2012b(y_idx_1, &db_emlrtDCI, (emlrtConstCTX)sp);
  }
  if (y_idx_1 != (int32_T)y_idx_1) {
    emlrtIntegerCheckR2012b(y_idx_1, &cb_emlrtDCI, (emlrtConstCTX)sp);
  }
  i = c_I->size[0] * c_I->size[1];
  c_I->size[0] = (int32_T)y_idx_0;
  c_I->size[1] = (int32_T)y_idx_1;
  emxEnsureCapacity_real_T(sp, c_I, i, &xb_emlrtRTEI);
  b_I_data = c_I->data;
  loop_ub = (int32_T)y_idx_0 * (int32_T)y_idx_1;
  for (i = 0; i < loop_ub; i++) {
    b_I_data[i] = 0.0;
  }
  x_idx_0 = muDoubleScalarFloor((real_T)b_I->size[0] * (scale - 1.0) / 2.0);
  lim[0] = x_idx_0 + 1.0;
  lim[1] = x_idx_0 + (real_T)b_I->size[0];
  x_idx_1 = muDoubleScalarFloor((real_T)b_I->size[1] * (scale - 1.0) / 2.0);
  lim[2] = x_idx_1 + 1.0;
  lim[3] = x_idx_1 + (real_T)b_I->size[1];
  /*  image limits */
  if (x_idx_0 + 1.0 > lim[1]) {
    i = 0;
    i1 = 0;
  } else {
    if (x_idx_0 + 1.0 != (int32_T)(x_idx_0 + 1.0)) {
      emlrtIntegerCheckR2012b(x_idx_0 + 1.0, &x_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)(x_idx_0 + 1.0) < 1) ||
        ((int32_T)(x_idx_0 + 1.0) > (int32_T)y_idx_0)) {
      emlrtDynamicBoundsCheckR2012b((int32_T)(x_idx_0 + 1.0), 1,
                                    (int32_T)y_idx_0, &bb_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
    i = (int32_T)(x_idx_0 + 1.0) - 1;
    if (lim[1] != (int32_T)lim[1]) {
      emlrtIntegerCheckR2012b(lim[1], &y_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[1] < 1) || ((int32_T)lim[1] > (int32_T)y_idx_0)) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[1], 1, (int32_T)y_idx_0,
                                    &cb_emlrtBCI, (emlrtConstCTX)sp);
    }
    i1 = (int32_T)lim[1];
  }
  if (x_idx_1 + 1.0 > lim[3]) {
    i2 = 0;
    i3 = 0;
  } else {
    if (x_idx_1 + 1.0 != (int32_T)(x_idx_1 + 1.0)) {
      emlrtIntegerCheckR2012b(x_idx_1 + 1.0, &ab_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)(x_idx_1 + 1.0) < 1) ||
        ((int32_T)(x_idx_1 + 1.0) > (int32_T)y_idx_1)) {
      emlrtDynamicBoundsCheckR2012b((int32_T)(x_idx_1 + 1.0), 1,
                                    (int32_T)y_idx_1, &db_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
    i2 = (int32_T)(x_idx_1 + 1.0) - 1;
    if (lim[3] != (int32_T)lim[3]) {
      emlrtIntegerCheckR2012b(lim[3], &bb_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[3] < 1) || ((int32_T)lim[3] > (int32_T)y_idx_1)) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[3], 1, (int32_T)y_idx_1,
                                    &eb_emlrtBCI, (emlrtConstCTX)sp);
    }
    i3 = (int32_T)lim[3];
  }
  iv[0] = i1 - i;
  iv[1] = i3 - i2;
  emlrtSubAssignSizeCheckR2012b(&iv[0], 2, &b_I->size[0], 2, &k_emlrtECI,
                                (emlrtCTX)sp);
  loop_ub = b_I->size[1];
  for (i1 = 0; i1 < loop_ub; i1++) {
    int32_T b_loop_ub;
    b_loop_ub = b_I->size[0];
    for (i3 = 0; i3 < b_loop_ub; i3++) {
      b_I_data[(i + i3) + c_I->size[0] * (i2 + i1)] =
          I_data[i3 + b_I->size[0] * i1];
    }
  }
  /*  padded image */
}

static void imgaussian(const emlrtStack *sp, emxArray_real_T *b_I, real_T sigma)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack st;
  emxArray_real_T b_h;
  emxArray_real_T *b_y;
  emxArray_real_T *c_y;
  emxArray_real_T *h;
  emxArray_real_T *x;
  emxArray_real_T *y;
  real_T *h_data;
  real_T *x_data;
  real_T *y_data;
  int32_T c_h;
  int32_T i;
  int32_T loop_ub;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  /*  Apply gaussian filter to image */
  if (!(sigma == 0.0)) {
    __m128d r;
    real_T radius;
    int32_T loop_ub_tmp;
    int32_T vectorUB;
    boolean_T b;
    /*  no smoothing */
    /*  Create Gaussian kernel */
    radius = muDoubleScalarCeil(3.0 * sigma);
    emxInit_real_T(sp, &y, 2, &qe_emlrtRTEI);
    st.site = &sc_emlrtRSI;
    b_st.site = &wc_emlrtRSI;
    b = muDoubleScalarIsNaN(-radius);
    if (b || muDoubleScalarIsNaN(radius)) {
      i = y->size[0] * y->size[1];
      y->size[0] = 1;
      y->size[1] = 1;
      emxEnsureCapacity_real_T(&b_st, y, i, &xd_emlrtRTEI);
      y_data = y->data;
      y_data[0] = rtNaN;
    } else if (radius < -radius) {
      y->size[0] = 1;
      y->size[1] = 0;
    } else if ((muDoubleScalarIsInf(-radius) || muDoubleScalarIsInf(radius)) &&
               (-radius == radius)) {
      i = y->size[0] * y->size[1];
      y->size[0] = 1;
      y->size[1] = 1;
      emxEnsureCapacity_real_T(&b_st, y, i, &xd_emlrtRTEI);
      y_data = y->data;
      y_data[0] = rtNaN;
    } else {
      i = y->size[0] * y->size[1];
      y->size[0] = 1;
      loop_ub = (int32_T)(radius - (-radius));
      y->size[1] = loop_ub + 1;
      emxEnsureCapacity_real_T(&b_st, y, i, &xd_emlrtRTEI);
      y_data = y->data;
      for (i = 0; i <= loop_ub; i++) {
        y_data[i] = -radius + (real_T)i;
      }
    }
    emxInit_real_T(sp, &b_y, 2, &re_emlrtRTEI);
    st.site = &sc_emlrtRSI;
    b_st.site = &wc_emlrtRSI;
    if (b || muDoubleScalarIsNaN(radius)) {
      i = b_y->size[0] * b_y->size[1];
      b_y->size[0] = 1;
      b_y->size[1] = 1;
      emxEnsureCapacity_real_T(&b_st, b_y, i, &xd_emlrtRTEI);
      y_data = b_y->data;
      y_data[0] = rtNaN;
    } else if (radius < -radius) {
      b_y->size[0] = 1;
      b_y->size[1] = 0;
    } else if ((muDoubleScalarIsInf(-radius) || muDoubleScalarIsInf(radius)) &&
               (-radius == radius)) {
      i = b_y->size[0] * b_y->size[1];
      b_y->size[0] = 1;
      b_y->size[1] = 1;
      emxEnsureCapacity_real_T(&b_st, b_y, i, &xd_emlrtRTEI);
      y_data = b_y->data;
      y_data[0] = rtNaN;
    } else {
      i = b_y->size[0] * b_y->size[1];
      b_y->size[0] = 1;
      loop_ub = (int32_T)(radius - (-radius));
      b_y->size[1] = loop_ub + 1;
      emxEnsureCapacity_real_T(&b_st, b_y, i, &xd_emlrtRTEI);
      y_data = b_y->data;
      for (i = 0; i <= loop_ub; i++) {
        y_data[i] = -radius + (real_T)i;
      }
    }
    emxInit_real_T(sp, &x, 2, &me_emlrtRTEI);
    emxInit_real_T(sp, &c_y, 2, &pe_emlrtRTEI);
    st.site = &sc_emlrtRSI;
    ndgrid(&st, y, b_y, x, c_y);
    y_data = c_y->data;
    x_data = x->data;
    emxFree_real_T(sp, &b_y);
    emxFree_real_T(sp, &y);
    /*  kernel coordinates */
    st.site = &tc_emlrtRSI;
    b_st.site = &y_emlrtRSI;
    emxInit_real_T(&b_st, &h, 2, &oe_emlrtRTEI);
    i = h->size[0] * h->size[1];
    h->size[0] = x->size[0];
    h->size[1] = x->size[1];
    emxEnsureCapacity_real_T(&b_st, h, i, &me_emlrtRTEI);
    h_data = h->data;
    loop_ub_tmp = x->size[0] * x->size[1];
    for (i = 0; i < loop_ub_tmp; i++) {
      radius = x_data[i];
      h_data[i] = radius * radius;
    }
    st.site = &tc_emlrtRSI;
    b_st.site = &y_emlrtRSI;
    i = x->size[0] * x->size[1];
    x->size[0] = c_y->size[0];
    x->size[1] = c_y->size[1];
    emxEnsureCapacity_real_T(&b_st, x, i, &ne_emlrtRTEI);
    x_data = x->data;
    loop_ub = c_y->size[0] * c_y->size[1];
    for (i = 0; i < loop_ub; i++) {
      radius = y_data[i];
      x_data[i] = radius * radius;
    }
    emxFree_real_T(&b_st, &c_y);
    if ((h->size[0] != x->size[0]) &&
        ((h->size[0] != 1) && (x->size[0] != 1))) {
      emlrtDimSizeImpxCheckR2021b(h->size[0], x->size[0], &sb_emlrtECI,
                                  (emlrtConstCTX)sp);
    }
    if ((h->size[1] != x->size[1]) &&
        ((h->size[1] != 1) && (x->size[1] != 1))) {
      emlrtDimSizeImpxCheckR2021b(h->size[1], x->size[1], &tb_emlrtECI,
                                  (emlrtConstCTX)sp);
    }
    st.site = &tc_emlrtRSI;
    b_st.site = &kb_emlrtRSI;
    c_st.site = &y_emlrtRSI;
    radius = sigma * sigma;
    st.site = &tc_emlrtRSI;
    if ((h->size[0] == x->size[0]) && (h->size[1] == x->size[1])) {
      radius *= 2.0;
      loop_ub = (loop_ub_tmp / 2) << 1;
      vectorUB = loop_ub - 2;
      for (i = 0; i <= vectorUB; i += 2) {
        __m128d r1;
        r = _mm_loadu_pd(&h_data[i]);
        r1 = _mm_loadu_pd(&x_data[i]);
        _mm_storeu_pd(&h_data[i], _mm_div_pd(_mm_mul_pd(_mm_add_pd(r, r1),
                                                        _mm_set1_pd(-1.0)),
                                             _mm_set1_pd(radius)));
      }
      for (i = loop_ub; i < loop_ub_tmp; i++) {
        h_data[i] = -(h_data[i] + x_data[i]) / radius;
      }
    } else {
      b_st.site = &tc_emlrtRSI;
      c_binary_expand_op(&b_st, h, x, radius);
      h_data = h->data;
    }
    emxFree_real_T(&st, &x);
    b_st.site = &xc_emlrtRSI;
    loop_ub_tmp = h->size[0] * h->size[1];
    c_st.site = &yc_emlrtRSI;
    if (loop_ub_tmp > 2147483646) {
      d_st.site = &ib_emlrtRSI;
      check_forloop_overflow_error(&d_st);
    }
    for (loop_ub = 0; loop_ub < loop_ub_tmp; loop_ub++) {
      h_data[loop_ub] = muDoubleScalarExp(h_data[loop_ub]);
    }
    b_h = *h;
    c_h = loop_ub_tmp;
    b_h.size = &c_h;
    b_h.numDimensions = 1;
    st.site = &uc_emlrtRSI;
    radius = sum(&st, &b_h);
    loop_ub = (loop_ub_tmp / 2) << 1;
    vectorUB = loop_ub - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&h_data[i]);
      _mm_storeu_pd(&h_data[i], _mm_div_pd(r, _mm_set1_pd(radius)));
    }
    for (i = loop_ub; i < loop_ub_tmp; i++) {
      h_data[i] /= radius;
    }
    /*  Filter image */
    st.site = &vc_emlrtRSI;
    imfilter(&st, b_I, h);
    emxFree_real_T(sp, &h);
  }
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void iminterpolate(const emlrtStack *sp, emxArray_real_T *b_I,
                          const emxArray_real_T *sx, const emxArray_real_T *sy)
{
  emlrtStack st;
  emxArray_real_T *b_x;
  emxArray_real_T *b_y;
  emxArray_real_T *c_I;
  emxArray_real_T *c_y;
  emxArray_real_T *d_y;
  emxArray_real_T *x;
  emxArray_real_T *y;
  const real_T *sx_data;
  const real_T *sy_data;
  real_T d;
  real_T *I_data;
  real_T *b_x_data;
  real_T *x_data;
  real_T *y_data;
  int32_T i;
  int32_T loop_ub;
  st.prev = sp;
  st.tls = sp->tls;
  sy_data = sy->data;
  sx_data = sx->data;
  I_data = b_I->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  /*  Interpolate image */
  /*  Find update points on moving image */
  emxInit_real_T(sp, &y, 2, &ke_emlrtRTEI);
  if (b_I->size[0] - 1 < 0) {
    y->size[0] = 1;
    y->size[1] = 0;
  } else {
    d = (real_T)b_I->size[0] - 1.0;
    i = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = (int32_T)d + 1;
    emxEnsureCapacity_real_T(sp, y, i, &xd_emlrtRTEI);
    y_data = y->data;
    loop_ub = (int32_T)d;
    for (i = 0; i <= loop_ub; i++) {
      y_data[i] = i;
    }
  }
  emxInit_real_T(sp, &b_y, 2, &le_emlrtRTEI);
  if (b_I->size[1] - 1 < 0) {
    b_y->size[0] = 1;
    b_y->size[1] = 0;
  } else {
    d = (real_T)b_I->size[1] - 1.0;
    i = b_y->size[0] * b_y->size[1];
    b_y->size[0] = 1;
    b_y->size[1] = (int32_T)d + 1;
    emxEnsureCapacity_real_T(sp, b_y, i, &xd_emlrtRTEI);
    y_data = b_y->data;
    loop_ub = (int32_T)d;
    for (i = 0; i <= loop_ub; i++) {
      y_data[i] = i;
    }
  }
  emxInit_real_T(sp, &x, 2, &je_emlrtRTEI);
  emxInit_real_T(sp, &c_y, 2, &je_emlrtRTEI);
  st.site = &ic_emlrtRSI;
  ndgrid(&st, y, b_y, x, c_y);
  y_data = c_y->data;
  x_data = x->data;
  emxFree_real_T(sp, &b_y);
  emxFree_real_T(sp, &y);
  /*  coordinate image */
  if ((x->size[0] != sx->size[0]) &&
      ((x->size[0] != 1) && (sx->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(x->size[0], sx->size[0], &ob_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((x->size[1] != sx->size[1]) &&
      ((x->size[1] != 1) && (sx->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(x->size[1], sx->size[1], &pb_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  /*  updated x values (1st dim, rows) */
  if ((c_y->size[0] != sy->size[0]) &&
      ((c_y->size[0] != 1) && (sy->size[0] != 1))) {
    emlrtDimSizeImpxCheckR2021b(c_y->size[0], sy->size[0], &qb_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  if ((c_y->size[1] != sy->size[1]) &&
      ((c_y->size[1] != 1) && (sy->size[1] != 1))) {
    emlrtDimSizeImpxCheckR2021b(c_y->size[1], sy->size[1], &rb_emlrtECI,
                                (emlrtConstCTX)sp);
  }
  /*  updated y values (2nd dim, cols) */
  /*  Interpolate updated image */
  if ((x->size[0] == sx->size[0]) && (x->size[1] == sx->size[1]) &&
      (c_y->size[0] == sy->size[0]) && (c_y->size[1] == sy->size[1])) {
    __m128d r;
    int32_T scalarLB;
    int32_T vectorUB;
    emxInit_real_T(sp, &b_x, 2, &ge_emlrtRTEI);
    i = b_x->size[0] * b_x->size[1];
    b_x->size[0] = x->size[0];
    b_x->size[1] = x->size[1];
    emxEnsureCapacity_real_T(sp, b_x, i, &ge_emlrtRTEI);
    b_x_data = b_x->data;
    loop_ub = x->size[0] * x->size[1];
    scalarLB = (loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&x_data[i]);
      _mm_storeu_pd(&b_x_data[i], _mm_add_pd(r, _mm_loadu_pd(&sx_data[i])));
    }
    for (i = scalarLB; i < loop_ub; i++) {
      b_x_data[i] = x_data[i] + sx_data[i];
    }
    emxInit_real_T(sp, &d_y, 2, &he_emlrtRTEI);
    i = d_y->size[0] * d_y->size[1];
    d_y->size[0] = c_y->size[0];
    d_y->size[1] = c_y->size[1];
    emxEnsureCapacity_real_T(sp, d_y, i, &he_emlrtRTEI);
    x_data = d_y->data;
    loop_ub = c_y->size[0] * c_y->size[1];
    scalarLB = (loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r = _mm_loadu_pd(&y_data[i]);
      _mm_storeu_pd(&x_data[i], _mm_add_pd(r, _mm_loadu_pd(&sy_data[i])));
    }
    for (i = scalarLB; i < loop_ub; i++) {
      x_data[i] = y_data[i] + sy_data[i];
    }
    emxInit_real_T(sp, &c_I, 2, &ie_emlrtRTEI);
    i = c_I->size[0] * c_I->size[1];
    c_I->size[0] = b_I->size[0];
    c_I->size[1] = b_I->size[1];
    emxEnsureCapacity_real_T(sp, c_I, i, &ie_emlrtRTEI);
    x_data = c_I->data;
    loop_ub = b_I->size[0] * b_I->size[1] - 1;
    for (i = 0; i <= loop_ub; i++) {
      x_data[i] = I_data[i];
    }
    st.site = &jc_emlrtRSI;
    interpn(&st, x, c_y, c_I, b_x, d_y, b_I);
    emxFree_real_T(sp, &c_I);
    emxFree_real_T(sp, &d_y);
    emxFree_real_T(sp, &b_x);
  } else {
    st.site = &jc_emlrtRSI;
    b_binary_expand_op(&st, b_I, jc_emlrtRSI, x, c_y, sx, sy);
  }
  emxFree_real_T(sp, &c_y);
  emxFree_real_T(sp, &x);
  /*  moving image intensities at updated points */
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void minus(const emlrtStack *sp, emxArray_real_T *in1,
                  const emxArray_real_T *in2)
{
  emxArray_real_T *b_in1;
  const real_T *in2_data;
  real_T *b_in1_data;
  real_T *in1_data;
  int32_T aux_0_1;
  int32_T aux_1_1;
  int32_T b_loop_ub;
  int32_T i;
  int32_T i1;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_0_1;
  int32_T stride_1_0;
  int32_T stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  emxInit_real_T(sp, &b_in1, 2, &hf_emlrtRTEI);
  if (in2->size[0] == 1) {
    loop_ub = in1->size[0];
  } else {
    loop_ub = in2->size[0];
  }
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = loop_ub;
  if (in2->size[1] == 1) {
    b_loop_ub = in1->size[1];
  } else {
    b_loop_ub = in2->size[1];
  }
  b_in1->size[1] = b_loop_ub;
  emxEnsureCapacity_real_T(sp, b_in1, i, &hf_emlrtRTEI);
  b_in1_data = b_in1->data;
  stride_0_0 = (in1->size[0] != 1);
  stride_0_1 = (in1->size[1] != 1);
  stride_1_0 = (in2->size[0] != 1);
  stride_1_1 = (in2->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (i = 0; i < b_loop_ub; i++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      b_in1_data[i1 + b_in1->size[0] * i] =
          in1_data[i1 * stride_0_0 + in1->size[0] * aux_0_1] -
          in2_data[i1 * stride_1_0 + in2->size[0] * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = b_in1->size[0];
  in1->size[1] = b_in1->size[1];
  emxEnsureCapacity_real_T(sp, in1, i, &hf_emlrtRTEI);
  in1_data = in1->data;
  loop_ub = b_in1->size[1];
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = b_in1->size[0];
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      in1_data[i1 + in1->size[0] * i] = b_in1_data[i1 + b_in1->size[0] * i];
    }
  }
  emxFree_real_T(sp, &b_in1);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void plus(const emlrtStack *sp, emxArray_real_T *in1,
                 const emxArray_real_T *in2)
{
  emxArray_real_T *b_in1;
  const real_T *in2_data;
  real_T *b_in1_data;
  real_T *in1_data;
  int32_T aux_0_1;
  int32_T aux_1_1;
  int32_T b_loop_ub;
  int32_T i;
  int32_T i1;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_0_1;
  int32_T stride_1_0;
  int32_T stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  emxInit_real_T(sp, &b_in1, 2, &kf_emlrtRTEI);
  if (in2->size[0] == 1) {
    loop_ub = in1->size[0];
  } else {
    loop_ub = in2->size[0];
  }
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = loop_ub;
  if (in2->size[1] == 1) {
    b_loop_ub = in1->size[1];
  } else {
    b_loop_ub = in2->size[1];
  }
  b_in1->size[1] = b_loop_ub;
  emxEnsureCapacity_real_T(sp, b_in1, i, &kf_emlrtRTEI);
  b_in1_data = b_in1->data;
  stride_0_0 = (in1->size[0] != 1);
  stride_0_1 = (in1->size[1] != 1);
  stride_1_0 = (in2->size[0] != 1);
  stride_1_1 = (in2->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (i = 0; i < b_loop_ub; i++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      b_in1_data[i1 + b_in1->size[0] * i] =
          in1_data[i1 * stride_0_0 + in1->size[0] * aux_0_1] +
          in2_data[i1 * stride_1_0 + in2->size[0] * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = b_in1->size[0];
  in1->size[1] = b_in1->size[1];
  emxEnsureCapacity_real_T(sp, in1, i, &kf_emlrtRTEI);
  in1_data = in1->data;
  loop_ub = b_in1->size[1];
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = b_in1->size[0];
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      in1_data[i1 + in1->size[0] * i] = b_in1_data[i1 + b_in1->size[0] * i];
    }
  }
  emxFree_real_T(sp, &b_in1);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

static void times(const emlrtStack *sp, emxArray_real_T *in1,
                  const emxArray_real_T *in2)
{
  emxArray_real_T *b_in1;
  const real_T *in2_data;
  real_T *b_in1_data;
  real_T *in1_data;
  int32_T aux_0_1;
  int32_T aux_1_1;
  int32_T b_loop_ub;
  int32_T i;
  int32_T i1;
  int32_T loop_ub;
  int32_T stride_0_0;
  int32_T stride_0_1;
  int32_T stride_1_0;
  int32_T stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  emxInit_real_T(sp, &b_in1, 2, &if_emlrtRTEI);
  if (in2->size[0] == 1) {
    loop_ub = in1->size[0];
  } else {
    loop_ub = in2->size[0];
  }
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = loop_ub;
  if (in2->size[1] == 1) {
    b_loop_ub = in1->size[1];
  } else {
    b_loop_ub = in2->size[1];
  }
  b_in1->size[1] = b_loop_ub;
  emxEnsureCapacity_real_T(sp, b_in1, i, &if_emlrtRTEI);
  b_in1_data = b_in1->data;
  stride_0_0 = (in1->size[0] != 1);
  stride_0_1 = (in1->size[1] != 1);
  stride_1_0 = (in2->size[0] != 1);
  stride_1_1 = (in2->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  for (i = 0; i < b_loop_ub; i++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      b_in1_data[i1 + b_in1->size[0] * i] =
          in1_data[i1 * stride_0_0 + in1->size[0] * aux_0_1] *
          in2_data[i1 * stride_1_0 + in2->size[0] * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = b_in1->size[0];
  in1->size[1] = b_in1->size[1];
  emxEnsureCapacity_real_T(sp, in1, i, &if_emlrtRTEI);
  in1_data = in1->data;
  loop_ub = b_in1->size[1];
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = b_in1->size[0];
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      in1_data[i1 + in1->size[0] * i] = b_in1_data[i1 + b_in1->size[0] * i];
    }
  }
  emxFree_real_T(sp, &b_in1);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

emlrtCTX emlrtGetRootTLSGlobal(void)
{
  return emlrtRootTLSGlobal;
}

void emlrtLockerFunction(EmlrtLockeeFunction aLockee, emlrtConstCTX aTLS,
                         void *aData)
{
  omp_set_lock(&emlrtLockGlobal);
  emlrtCallLockeeFunction(aLockee, aTLS, aData);
  omp_unset_lock(&emlrtLockGlobal);
}

void register_in_lite(const emlrtStack *sp, const emxArray_uint8_T *F,
                      const emxArray_uint8_T *M, const struct0_T *opt,
                      emxArray_real_T *Mp, emxArray_real_T *sx,
                      emxArray_real_T *sy, emxArray_real_T *vx,
                      emxArray_real_T *vy, emxArray_real_T *e)
{
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack st;
  emxArray_real_T b_diff2;
  emxArray_real_T *b_F;
  emxArray_real_T *diff2;
  emxArray_real_T *gx_x;
  emxArray_real_T *gx_y;
  emxArray_real_T *r;
  emxArray_real_T *ux;
  emxArray_real_T *uy;
  emxArray_real_T *vx_min;
  emxArray_real_T *vy_min;
  real_T lim[4];
  real_T e_min;
  real_T e_reg;
  real_T *F_data;
  real_T *Mp_data;
  real_T *e_data;
  real_T *gx_x_data;
  real_T *sy_data;
  real_T *ux_data;
  real_T *uy_data;
  real_T *vx_data;
  real_T *vx_min_data;
  real_T *vy_data;
  real_T *vy_min_data;
  int32_T b_loop_ub;
  int32_T b_loop_ub_tmp;
  int32_T c_diff2;
  int32_T i;
  int32_T i1;
  int32_T iter;
  int32_T loop_ub;
  int32_T loop_ub_tmp;
  int32_T scalarLB;
  int32_T vectorUB;
  boolean_T exitg1;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtConstCTX)sp);
  /*  Register two images */
  /*  regularize update      field */
  /*  regularize deformation field */
  /*  weight on similarity term */
  /*  (maximal step) */
  /*  padded image */
  i = vx->size[0] * vx->size[1];
  vx->size[0] = M->size[0];
  vx->size[1] = M->size[1];
  emxEnsureCapacity_real_T(sp, vx, i, &ab_emlrtRTEI);
  vx_data = vx->data;
  loop_ub_tmp = M->size[0] * M->size[1];
  for (i = 0; i < loop_ub_tmp; i++) {
    vx_data[i] = 0.0;
  }
  st.site = &emlrtRSI;
  b_imagepad(&st, vx, opt->imagepad);
  vx_data = vx->data;
  i = vy->size[0] * vy->size[1];
  vy->size[0] = M->size[0];
  vy->size[1] = M->size[1];
  emxEnsureCapacity_real_T(sp, vy, i, &bb_emlrtRTEI);
  vy_data = vy->data;
  for (i = 0; i < loop_ub_tmp; i++) {
    vy_data[i] = 0.0;
  }
  st.site = &b_emlrtRSI;
  b_imagepad(&st, vy, opt->imagepad);
  vy_data = vy->data;
  emxInit_real_T(sp, &b_F, 2, &vb_emlrtRTEI);
  st.site = &c_emlrtRSI;
  imagepad(&st, F, opt->imagepad, b_F, lim);
  F_data = b_F->data;
  st.site = &d_emlrtRSI;
  imagepad(&st, M, opt->imagepad, Mp, lim);
  Mp_data = Mp->data;
  emxInit_real_T(sp, &vx_min, 2, &cb_emlrtRTEI);
  i = vx_min->size[0] * vx_min->size[1];
  vx_min->size[0] = vx->size[0];
  vx_min->size[1] = vx->size[1];
  emxEnsureCapacity_real_T(sp, vx_min, i, &cb_emlrtRTEI);
  vx_min_data = vx_min->data;
  loop_ub = vx->size[0] * vx->size[1];
  for (i = 0; i < loop_ub; i++) {
    vx_min_data[i] = vx_data[i];
  }
  emxInit_real_T(sp, &vy_min, 2, &db_emlrtRTEI);
  i = vy_min->size[0] * vy_min->size[1];
  vy_min->size[0] = vy->size[0];
  vy_min->size[1] = vy->size[1];
  emxEnsureCapacity_real_T(sp, vy_min, i, &db_emlrtRTEI);
  vy_min_data = vy_min->data;
  loop_ub = vy->size[0] * vy->size[1];
  for (i = 0; i < loop_ub; i++) {
    vy_min_data[i] = vy_data[i];
  }
  /*  update best fields */
  /*  T is the deformation from M to F */
  i = e->size[0] * e->size[1];
  e->size[0] = 1;
  emxEnsureCapacity_real_T(sp, e, i, &eb_emlrtRTEI);
  if (!(opt->niter >= 0.0)) {
    emlrtNonNegativeCheckR2012b(opt->niter, &v_emlrtDCI, (emlrtConstCTX)sp);
  }
  e_reg = (int32_T)muDoubleScalarFloor(opt->niter);
  if (opt->niter != e_reg) {
    emlrtIntegerCheckR2012b(opt->niter, &u_emlrtDCI, (emlrtConstCTX)sp);
  }
  i = e->size[0] * e->size[1];
  loop_ub = (int32_T)opt->niter;
  e->size[1] = (int32_T)opt->niter;
  emxEnsureCapacity_real_T(sp, e, i, &eb_emlrtRTEI);
  e_data = e->data;
  if (opt->niter != e_reg) {
    emlrtIntegerCheckR2012b(opt->niter, &w_emlrtDCI, (emlrtConstCTX)sp);
  }
  for (i = 0; i < loop_ub; i++) {
    e_data[i] = 0.0;
  }
  e_min = 1.0E+100;
  /*  Minimal energy */
  /*  Iterate update fields */
  emlrtForLoopVectorCheckR2021a(1.0, 1.0, opt->niter, mxDOUBLE_CLASS,
                                (int32_T)opt->niter, &emlrtRTEI,
                                (emlrtConstCTX)sp);
  iter = 1;
  emxInit_real_T(sp, &ux, 2, &tb_emlrtRTEI);
  emxInit_real_T(sp, &uy, 2, &ub_emlrtRTEI);
  emxInit_real_T(sp, &diff2, 2, &ob_emlrtRTEI);
  emxInit_real_T(sp, &gx_x, 2, &wb_emlrtRTEI);
  emxInit_real_T(sp, &gx_y, 2, &vb_emlrtRTEI);
  emxInit_real_T(sp, &r, 1, &qb_emlrtRTEI);
  exitg1 = false;
  while ((!exitg1) && (iter - 1 <= loop_ub - 1)) {
    __m128d r1;
    __m128d r2;
    real_T area;
    real_T e_sim;
    boolean_T guard1;
    /*  Find update */
    st.site = &e_emlrtRSI;
    findupdate(&st, b_F, Mp, vx, vy, opt->sigma_i, opt->sigma_x, ux, uy);
    /*  Regularize update */
    st.site = &f_emlrtRSI;
    imgaussian(&st, ux, opt->sigma_fluid);
    ux_data = ux->data;
    st.site = &g_emlrtRSI;
    imgaussian(&st, uy, opt->sigma_fluid);
    uy_data = uy->data;
    /*  Compute step (e.g., max half a pixel) */
    /*  Update velocities (demons) - additive */
    b_loop_ub = ux->size[0] * ux->size[1];
    scalarLB = (b_loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r1 = _mm_loadu_pd(&ux_data[i]);
      _mm_storeu_pd(&ux_data[i], _mm_mul_pd(_mm_set1_pd(opt->sigma_x), r1));
    }
    for (i = scalarLB; i < b_loop_ub; i++) {
      ux_data[i] *= opt->sigma_x;
    }
    if ((vx->size[0] != ux->size[0]) &&
        ((vx->size[0] != 1) && (ux->size[0] != 1))) {
      emlrtDimSizeImpxCheckR2021b(vx->size[0], ux->size[0], &emlrtECI,
                                  (emlrtConstCTX)sp);
    }
    if ((vx->size[1] != ux->size[1]) &&
        ((vx->size[1] != 1) && (ux->size[1] != 1))) {
      emlrtDimSizeImpxCheckR2021b(vx->size[1], ux->size[1], &b_emlrtECI,
                                  (emlrtConstCTX)sp);
    }
    if ((vx->size[0] == ux->size[0]) && (vx->size[1] == ux->size[1])) {
      b_loop_ub = vx->size[0] * vx->size[1];
      scalarLB = (b_loop_ub / 2) << 1;
      vectorUB = scalarLB - 2;
      for (i = 0; i <= vectorUB; i += 2) {
        r1 = _mm_loadu_pd(&vx_data[i]);
        r2 = _mm_loadu_pd(&ux_data[i]);
        _mm_storeu_pd(&vx_data[i], _mm_add_pd(r1, r2));
      }
      for (i = scalarLB; i < b_loop_ub; i++) {
        vx_data[i] += ux_data[i];
      }
    } else {
      st.site = &kg_emlrtRSI;
      plus(&st, vx, ux);
    }
    b_loop_ub = uy->size[0] * uy->size[1];
    scalarLB = (b_loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r1 = _mm_loadu_pd(&uy_data[i]);
      _mm_storeu_pd(&uy_data[i], _mm_mul_pd(_mm_set1_pd(opt->sigma_x), r1));
    }
    for (i = scalarLB; i < b_loop_ub; i++) {
      uy_data[i] *= opt->sigma_x;
    }
    if ((vy->size[0] != uy->size[0]) &&
        ((vy->size[0] != 1) && (uy->size[0] != 1))) {
      emlrtDimSizeImpxCheckR2021b(vy->size[0], uy->size[0], &c_emlrtECI,
                                  (emlrtConstCTX)sp);
    }
    if ((vy->size[1] != uy->size[1]) &&
        ((vy->size[1] != 1) && (uy->size[1] != 1))) {
      emlrtDimSizeImpxCheckR2021b(vy->size[1], uy->size[1], &d_emlrtECI,
                                  (emlrtConstCTX)sp);
    }
    if ((vy->size[0] == uy->size[0]) && (vy->size[1] == uy->size[1])) {
      b_loop_ub = vy->size[0] * vy->size[1];
      scalarLB = (b_loop_ub / 2) << 1;
      vectorUB = scalarLB - 2;
      for (i = 0; i <= vectorUB; i += 2) {
        r1 = _mm_loadu_pd(&vy_data[i]);
        r2 = _mm_loadu_pd(&uy_data[i]);
        _mm_storeu_pd(&vy_data[i], _mm_add_pd(r1, r2));
      }
      for (i = scalarLB; i < b_loop_ub; i++) {
        vy_data[i] += uy_data[i];
      }
    } else {
      st.site = &jg_emlrtRSI;
      plus(&st, vy, uy);
    }
    /*  Update velocities (demons) - composition */
    /* [vx,vy] = compose(vx,vy,step*ux,step*uy); */
    /*  Regularize velocities */
    st.site = &h_emlrtRSI;
    imgaussian(&st, vx, opt->sigma_diffusion);
    vx_data = vx->data;
    st.site = &i_emlrtRSI;
    imgaussian(&st, vy, opt->sigma_diffusion);
    vy_data = vy->data;
    /*  Get Transformation */
    i = sx->size[0] * sx->size[1];
    sx->size[0] = vx->size[0];
    sx->size[1] = vx->size[1];
    emxEnsureCapacity_real_T(sp, sx, i, &jb_emlrtRTEI);
    uy_data = sx->data;
    loop_ub_tmp = vx->size[0] * vx->size[1];
    for (i = 0; i < loop_ub_tmp; i++) {
      uy_data[i] = vx_data[i];
    }
    i = sy->size[0] * sy->size[1];
    sy->size[0] = vy->size[0];
    sy->size[1] = vy->size[1];
    emxEnsureCapacity_real_T(sp, sy, i, &kb_emlrtRTEI);
    sy_data = sy->data;
    b_loop_ub_tmp = vy->size[0] * vy->size[1];
    for (i = 0; i < b_loop_ub_tmp; i++) {
      sy_data[i] = vy_data[i];
    }
    st.site = &j_emlrtRSI;
    expfield(&st, sx, sy);
    /*  deformation field */
    /*  Compute energy */
    st.site = &k_emlrtRSI;
    /*  Get energy */
    /*  Intensity difference */
    i = ux->size[0] * ux->size[1];
    ux->size[0] = Mp->size[0];
    ux->size[1] = Mp->size[1];
    emxEnsureCapacity_real_T(&st, ux, i, &mb_emlrtRTEI);
    ux_data = ux->data;
    b_loop_ub = Mp->size[0] * Mp->size[1];
    for (i = 0; i < b_loop_ub; i++) {
      ux_data[i] = Mp_data[i];
    }
    b_st.site = &rf_emlrtRSI;
    iminterpolate(&b_st, ux, sx, sy);
    ux_data = ux->data;
    if ((b_F->size[0] != ux->size[0]) &&
        ((b_F->size[0] != 1) && (ux->size[0] != 1))) {
      emlrtDimSizeImpxCheckR2021b(b_F->size[0], ux->size[0], &e_emlrtECI, &st);
    }
    if ((b_F->size[1] != ux->size[1]) &&
        ((b_F->size[1] != 1) && (ux->size[1] != 1))) {
      emlrtDimSizeImpxCheckR2021b(b_F->size[1], ux->size[1], &f_emlrtECI, &st);
    }
    b_st.site = &sf_emlrtRSI;
    c_st.site = &y_emlrtRSI;
    if ((b_F->size[0] == ux->size[0]) && (b_F->size[1] == ux->size[1])) {
      i = diff2->size[0] * diff2->size[1];
      diff2->size[0] = b_F->size[0];
      diff2->size[1] = b_F->size[1];
      emxEnsureCapacity_real_T(&c_st, diff2, i, &ob_emlrtRTEI);
      uy_data = diff2->data;
      b_loop_ub = b_F->size[0] * b_F->size[1];
      for (i = 0; i < b_loop_ub; i++) {
        e_reg = F_data[i] - ux_data[i];
        uy_data[i] = e_reg * e_reg;
      }
    } else {
      d_st.site = &gg_emlrtRSI;
      binary_expand_op(&d_st, diff2, b_F, ux);
    }
    area = (real_T)Mp->size[0] * (real_T)Mp->size[1];
    /*  Transformation Gradient */
    b_st.site = &tf_emlrtRSI;
    /*  Jacobian */
    /*  Gradients */
    c_st.site = &xf_emlrtRSI;
    gradient(&c_st, sx, gx_y, gx_x);
    gx_x_data = gx_x->data;
    sy_data = gx_y->data;
    c_st.site = &yf_emlrtRSI;
    gradient(&c_st, sy, uy, ux);
    ux_data = ux->data;
    uy_data = uy->data;
    /*  Add identity */
    b_loop_ub = gx_x->size[0] * gx_x->size[1];
    scalarLB = (b_loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r1 = _mm_loadu_pd(&gx_x_data[i]);
      _mm_storeu_pd(&gx_x_data[i], _mm_add_pd(r1, _mm_set1_pd(1.0)));
    }
    for (i = scalarLB; i < b_loop_ub; i++) {
      gx_x_data[i]++;
    }
    /*  zero displacement should yield a transformation T = Identity (points
     * keep their positions) */
    b_loop_ub = uy->size[0] * uy->size[1];
    scalarLB = (b_loop_ub / 2) << 1;
    vectorUB = scalarLB - 2;
    for (i = 0; i <= vectorUB; i += 2) {
      r1 = _mm_loadu_pd(&uy_data[i]);
      _mm_storeu_pd(&uy_data[i], _mm_add_pd(r1, _mm_set1_pd(1.0)));
    }
    for (i = scalarLB; i < b_loop_ub; i++) {
      uy_data[i]++;
    }
    /*  adding identity matrix here */
    /*  Determinant */
    if ((gx_x->size[0] != uy->size[0]) &&
        ((gx_x->size[0] != 1) && (uy->size[0] != 1))) {
      emlrtDimSizeImpxCheckR2021b(gx_x->size[0], uy->size[0], &g_emlrtECI,
                                  &b_st);
    }
    if ((gx_x->size[1] != uy->size[1]) &&
        ((gx_x->size[1] != 1) && (uy->size[1] != 1))) {
      emlrtDimSizeImpxCheckR2021b(gx_x->size[1], uy->size[1], &h_emlrtECI,
                                  &b_st);
    }
    if ((ux->size[0] != gx_y->size[0]) &&
        ((ux->size[0] != 1) && (gx_y->size[0] != 1))) {
      emlrtDimSizeImpxCheckR2021b(ux->size[0], gx_y->size[0], &i_emlrtECI,
                                  &b_st);
    }
    if ((ux->size[1] != gx_y->size[1]) &&
        ((ux->size[1] != 1) && (gx_y->size[1] != 1))) {
      emlrtDimSizeImpxCheckR2021b(ux->size[1], gx_y->size[1], &j_emlrtECI,
                                  &b_st);
    }
    if ((gx_x->size[0] == uy->size[0]) && (gx_x->size[1] == uy->size[1])) {
      b_loop_ub = gx_x->size[0] * gx_x->size[1];
      scalarLB = (b_loop_ub / 2) << 1;
      vectorUB = scalarLB - 2;
      for (i = 0; i <= vectorUB; i += 2) {
        r1 = _mm_loadu_pd(&gx_x_data[i]);
        r2 = _mm_loadu_pd(&uy_data[i]);
        _mm_storeu_pd(&gx_x_data[i], _mm_mul_pd(r1, r2));
      }
      for (i = scalarLB; i < b_loop_ub; i++) {
        gx_x_data[i] *= uy_data[i];
      }
    } else {
      c_st.site = &ag_emlrtRSI;
      times(&c_st, gx_x, uy);
      gx_x_data = gx_x->data;
    }
    if ((ux->size[0] == gx_y->size[0]) && (ux->size[1] == gx_y->size[1])) {
      b_loop_ub = ux->size[0] * ux->size[1];
      scalarLB = (b_loop_ub / 2) << 1;
      vectorUB = scalarLB - 2;
      for (i = 0; i <= vectorUB; i += 2) {
        r1 = _mm_loadu_pd(&ux_data[i]);
        r2 = _mm_loadu_pd(&sy_data[i]);
        _mm_storeu_pd(&ux_data[i], _mm_mul_pd(r1, r2));
      }
      for (i = scalarLB; i < b_loop_ub; i++) {
        ux_data[i] *= sy_data[i];
      }
    } else {
      c_st.site = &fg_emlrtRSI;
      times(&c_st, ux, gx_y);
      ux_data = ux->data;
    }
    if ((gx_x->size[0] != ux->size[0]) &&
        ((gx_x->size[0] != 1) && (ux->size[0] != 1))) {
      emlrtDimSizeImpxCheckR2021b(gx_x->size[0], ux->size[0], &g_emlrtECI,
                                  &b_st);
    }
    if ((gx_x->size[1] != ux->size[1]) &&
        ((gx_x->size[1] != 1) && (ux->size[1] != 1))) {
      emlrtDimSizeImpxCheckR2021b(gx_x->size[1], ux->size[1], &h_emlrtECI,
                                  &b_st);
    }
    if ((gx_x->size[0] == ux->size[0]) && (gx_x->size[1] == ux->size[1])) {
      b_loop_ub = gx_x->size[0] * gx_x->size[1];
      scalarLB = (b_loop_ub / 2) << 1;
      vectorUB = scalarLB - 2;
      for (i = 0; i <= vectorUB; i += 2) {
        r1 = _mm_loadu_pd(&gx_x_data[i]);
        r2 = _mm_loadu_pd(&ux_data[i]);
        _mm_storeu_pd(&gx_x_data[i], _mm_sub_pd(r1, r2));
      }
      for (i = scalarLB; i < b_loop_ub; i++) {
        gx_x_data[i] -= ux_data[i];
      }
    } else {
      c_st.site = &ag_emlrtRSI;
      minus(&c_st, gx_x, ux);
      gx_x_data = gx_x->data;
    }
    /*  Three energy components */
    scalarLB = diff2->size[0] * diff2->size[1];
    b_diff2 = *diff2;
    c_diff2 = scalarLB;
    b_diff2.size = &c_diff2;
    b_diff2.numDimensions = 1;
    b_st.site = &uf_emlrtRSI;
    e_sim = sum(&b_st, &b_diff2) / area;
    /* e_dist = sum((cx(:)-sx(:)).^2 + (cy(:)-sy(:)).^2) / area; */
    b_st.site = &vf_emlrtRSI;
    c_st.site = &y_emlrtRSI;
    scalarLB = gx_x->size[0] * gx_x->size[1];
    i = r->size[0];
    r->size[0] = scalarLB;
    emxEnsureCapacity_real_T(&st, r, i, &qb_emlrtRTEI);
    uy_data = r->data;
    for (i = 0; i < scalarLB; i++) {
      e_reg = gx_x_data[i];
      uy_data[i] = e_reg * e_reg;
    }
    b_st.site = &vf_emlrtRSI;
    e_reg = sum(&b_st, r) / area;
    /*  Total energy */
    b_st.site = &wf_emlrtRSI;
    c_st.site = &kb_emlrtRSI;
    b_st.site = &wf_emlrtRSI;
    c_st.site = &kb_emlrtRSI;
    if ((iter < 1) || (iter > e->size[1])) {
      emlrtDynamicBoundsCheckR2012b(iter, 1, e->size[1], &v_emlrtBCI, &st);
    }
    e_data[iter - 1] = e_sim + opt->sigma_i * opt->sigma_i /
                                   (opt->sigma_x * opt->sigma_x) * e_reg;
    if (iter > e->size[1]) {
      emlrtDynamicBoundsCheckR2012b(iter, 1, e->size[1], &w_emlrtBCI,
                                    (emlrtConstCTX)sp);
    }
    e_reg = e_data[iter - 1];
    if (e_reg < e_min) {
      /*  update best fields */
      i = vx_min->size[0] * vx_min->size[1];
      vx_min->size[0] = vx->size[0];
      vx_min->size[1] = vx->size[1];
      emxEnsureCapacity_real_T(sp, vx_min, i, &rb_emlrtRTEI);
      vx_min_data = vx_min->data;
      for (i = 0; i < loop_ub_tmp; i++) {
        vx_min_data[i] = vx_data[i];
      }
      i = vy_min->size[0] * vy_min->size[1];
      vy_min->size[0] = vy->size[0];
      vy_min->size[1] = vy->size[1];
      emxEnsureCapacity_real_T(sp, vy_min, i, &sb_emlrtRTEI);
      vy_min_data = vy_min->data;
      for (i = 0; i < b_loop_ub_tmp; i++) {
        vy_min_data[i] = vy_data[i];
      }
      /*  update best fields */
      if (iter > e->size[1]) {
        emlrtDynamicBoundsCheckR2012b(iter, 1, e->size[1], &ab_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      e_min = e_data[iter - 1];
    }
    /*  Stop criterium */
    guard1 = false;
    if (iter > 1) {
      if (e->size[1] < 1) {
        emlrtDynamicBoundsCheckR2012b(1, 1, e->size[1], &emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      if (iter > e->size[1]) {
        emlrtDynamicBoundsCheckR2012b(iter, 1, e->size[1], &x_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      i = (int32_T)muDoubleScalarMax(1.0, (((real_T)iter - 1.0) + 1.0) - 5.0);
      if (i > e->size[1]) {
        emlrtDynamicBoundsCheckR2012b(i, 1, e->size[1], &y_emlrtBCI,
                                      (emlrtConstCTX)sp);
      }
      if (muDoubleScalarAbs(e_reg - e_data[i - 1]) <
          e_data[0] * opt->stop_criterium) {
        exitg1 = true;
      } else {
        guard1 = true;
      }
    } else {
      guard1 = true;
    }
    if (guard1) {
      iter++;
      if (*emlrtBreakCheckR2012bFlagVar != 0) {
        emlrtBreakCheckR2012b((emlrtConstCTX)sp);
      }
    }
  }
  emxFree_real_T(sp, &r);
  emxFree_real_T(sp, &gx_y);
  emxFree_real_T(sp, &gx_x);
  emxFree_real_T(sp, &diff2);
  emxFree_real_T(sp, &b_F);
  emxFree_real_T(sp, &uy);
  emxFree_real_T(sp, &ux);
  /*  Get Best Transformation */
  /*      sx = sx_min;  sy = sy_min; */
  i = sx->size[0] * sx->size[1];
  sx->size[0] = vx_min->size[0];
  sx->size[1] = vx_min->size[1];
  emxEnsureCapacity_real_T(sp, sx, i, &fb_emlrtRTEI);
  uy_data = sx->data;
  loop_ub = vx_min->size[0] * vx_min->size[1];
  for (i = 0; i < loop_ub; i++) {
    uy_data[i] = vx_min_data[i];
  }
  i = sy->size[0] * sy->size[1];
  sy->size[0] = vy_min->size[0];
  sy->size[1] = vy_min->size[1];
  emxEnsureCapacity_real_T(sp, sy, i, &gb_emlrtRTEI);
  sy_data = sy->data;
  loop_ub = vy_min->size[0] * vy_min->size[1];
  for (i = 0; i < loop_ub; i++) {
    sy_data[i] = vy_min_data[i];
  }
  st.site = &l_emlrtRSI;
  expfield(&st, sx, sy);
  sy_data = sy->data;
  uy_data = sx->data;
  /*  Transform moving image */
  st.site = &m_emlrtRSI;
  iminterpolate(&st, Mp, sx, sy);
  Mp_data = Mp->data;
  /*  Unpad image */
  if (lim[0] > lim[1]) {
    i = -1;
    iter = -1;
  } else {
    if (lim[0] != (int32_T)muDoubleScalarFloor(lim[0])) {
      emlrtIntegerCheckR2012b(lim[0], &emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[0] < 1) || ((int32_T)lim[0] > Mp->size[0])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[0], 1, Mp->size[0],
                                    &b_emlrtBCI, (emlrtConstCTX)sp);
    }
    i = (int32_T)lim[0] - 2;
    if (lim[1] != (int32_T)muDoubleScalarFloor(lim[1])) {
      emlrtIntegerCheckR2012b(lim[1], &b_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[1] < 1) || ((int32_T)lim[1] > Mp->size[0])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[1], 1, Mp->size[0],
                                    &c_emlrtBCI, (emlrtConstCTX)sp);
    }
    iter = (int32_T)lim[1] - 1;
  }
  if (lim[2] > lim[3]) {
    scalarLB = 0;
    i1 = 0;
  } else {
    if (lim[2] != (int32_T)muDoubleScalarFloor(lim[2])) {
      emlrtIntegerCheckR2012b(lim[2], &c_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[2] < 1) || ((int32_T)lim[2] > Mp->size[1])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[2], 1, Mp->size[1],
                                    &d_emlrtBCI, (emlrtConstCTX)sp);
    }
    scalarLB = (int32_T)lim[2] - 1;
    if (lim[3] != (int32_T)muDoubleScalarFloor(lim[3])) {
      emlrtIntegerCheckR2012b(lim[3], &d_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[3] < 1) || ((int32_T)lim[3] > Mp->size[1])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[3], 1, Mp->size[1],
                                    &e_emlrtBCI, (emlrtConstCTX)sp);
    }
    i1 = (int32_T)lim[3];
  }
  loop_ub_tmp = i1 - scalarLB;
  for (i1 = 0; i1 < loop_ub_tmp; i1++) {
    b_loop_ub_tmp = iter - i;
    for (vectorUB = 0; vectorUB < b_loop_ub_tmp; vectorUB++) {
      Mp_data[vectorUB + b_loop_ub_tmp * i1] =
          Mp_data[((i + vectorUB) + Mp->size[0] * (scalarLB + i1)) + 1];
    }
  }
  scalarLB = Mp->size[0] * Mp->size[1];
  Mp->size[0] = iter - i;
  Mp->size[1] = loop_ub_tmp;
  emxEnsureCapacity_real_T(sp, Mp, scalarLB, &hb_emlrtRTEI);
  if (lim[0] > lim[1]) {
    i = 0;
    iter = 0;
  } else {
    if (lim[0] != (int32_T)muDoubleScalarFloor(lim[0])) {
      emlrtIntegerCheckR2012b(lim[0], &e_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[0] < 1) || ((int32_T)lim[0] > vx_min->size[0])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[0], 1, vx_min->size[0],
                                    &f_emlrtBCI, (emlrtConstCTX)sp);
    }
    i = (int32_T)lim[0] - 1;
    if (lim[1] != (int32_T)muDoubleScalarFloor(lim[1])) {
      emlrtIntegerCheckR2012b(lim[1], &f_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[1] < 1) || ((int32_T)lim[1] > vx_min->size[0])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[1], 1, vx_min->size[0],
                                    &g_emlrtBCI, (emlrtConstCTX)sp);
    }
    iter = (int32_T)lim[1];
  }
  if (lim[2] > lim[3]) {
    scalarLB = 0;
    i1 = 0;
  } else {
    if (lim[2] != (int32_T)muDoubleScalarFloor(lim[2])) {
      emlrtIntegerCheckR2012b(lim[2], &g_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[2] < 1) || ((int32_T)lim[2] > vx_min->size[1])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[2], 1, vx_min->size[1],
                                    &h_emlrtBCI, (emlrtConstCTX)sp);
    }
    scalarLB = (int32_T)lim[2] - 1;
    if (lim[3] != (int32_T)muDoubleScalarFloor(lim[3])) {
      emlrtIntegerCheckR2012b(lim[3], &h_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[3] < 1) || ((int32_T)lim[3] > vx_min->size[1])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[3], 1, vx_min->size[1],
                                    &i_emlrtBCI, (emlrtConstCTX)sp);
    }
    i1 = (int32_T)lim[3];
  }
  loop_ub = iter - i;
  iter = vx->size[0] * vx->size[1];
  vx->size[0] = loop_ub;
  b_loop_ub = i1 - scalarLB;
  vx->size[1] = b_loop_ub;
  emxEnsureCapacity_real_T(sp, vx, iter, &ib_emlrtRTEI);
  vx_data = vx->data;
  for (iter = 0; iter < b_loop_ub; iter++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      vx_data[i1 + vx->size[0] * iter] =
          vx_min_data[(i + i1) + vx_min->size[0] * (scalarLB + iter)];
    }
  }
  emxFree_real_T(sp, &vx_min);
  if (lim[0] > lim[1]) {
    i = 0;
    iter = 0;
  } else {
    if (lim[0] != (int32_T)muDoubleScalarFloor(lim[0])) {
      emlrtIntegerCheckR2012b(lim[0], &i_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[0] < 1) || ((int32_T)lim[0] > vy_min->size[0])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[0], 1, vy_min->size[0],
                                    &j_emlrtBCI, (emlrtConstCTX)sp);
    }
    i = (int32_T)lim[0] - 1;
    if (lim[1] != (int32_T)muDoubleScalarFloor(lim[1])) {
      emlrtIntegerCheckR2012b(lim[1], &j_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[1] < 1) || ((int32_T)lim[1] > vy_min->size[0])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[1], 1, vy_min->size[0],
                                    &k_emlrtBCI, (emlrtConstCTX)sp);
    }
    iter = (int32_T)lim[1];
  }
  if (lim[2] > lim[3]) {
    scalarLB = 0;
    i1 = 0;
  } else {
    if (lim[2] != (int32_T)muDoubleScalarFloor(lim[2])) {
      emlrtIntegerCheckR2012b(lim[2], &k_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[2] < 1) || ((int32_T)lim[2] > vy_min->size[1])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[2], 1, vy_min->size[1],
                                    &l_emlrtBCI, (emlrtConstCTX)sp);
    }
    scalarLB = (int32_T)lim[2] - 1;
    if (lim[3] != (int32_T)muDoubleScalarFloor(lim[3])) {
      emlrtIntegerCheckR2012b(lim[3], &l_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[3] < 1) || ((int32_T)lim[3] > vy_min->size[1])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[3], 1, vy_min->size[1],
                                    &m_emlrtBCI, (emlrtConstCTX)sp);
    }
    i1 = (int32_T)lim[3];
  }
  loop_ub = iter - i;
  iter = vy->size[0] * vy->size[1];
  vy->size[0] = loop_ub;
  b_loop_ub = i1 - scalarLB;
  vy->size[1] = b_loop_ub;
  emxEnsureCapacity_real_T(sp, vy, iter, &lb_emlrtRTEI);
  vy_data = vy->data;
  for (iter = 0; iter < b_loop_ub; iter++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      vy_data[i1 + vy->size[0] * iter] =
          vy_min_data[(i + i1) + vy_min->size[0] * (scalarLB + iter)];
    }
  }
  emxFree_real_T(sp, &vy_min);
  if (lim[0] > lim[1]) {
    i = -1;
    iter = -1;
  } else {
    if (lim[0] != (int32_T)muDoubleScalarFloor(lim[0])) {
      emlrtIntegerCheckR2012b(lim[0], &m_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[0] < 1) || ((int32_T)lim[0] > sx->size[0])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[0], 1, sx->size[0],
                                    &n_emlrtBCI, (emlrtConstCTX)sp);
    }
    i = (int32_T)lim[0] - 2;
    if (lim[1] != (int32_T)muDoubleScalarFloor(lim[1])) {
      emlrtIntegerCheckR2012b(lim[1], &n_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[1] < 1) || ((int32_T)lim[1] > sx->size[0])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[1], 1, sx->size[0],
                                    &o_emlrtBCI, (emlrtConstCTX)sp);
    }
    iter = (int32_T)lim[1] - 1;
  }
  if (lim[2] > lim[3]) {
    scalarLB = 0;
    i1 = 0;
  } else {
    if (lim[2] != (int32_T)muDoubleScalarFloor(lim[2])) {
      emlrtIntegerCheckR2012b(lim[2], &o_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[2] < 1) || ((int32_T)lim[2] > sx->size[1])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[2], 1, sx->size[1],
                                    &p_emlrtBCI, (emlrtConstCTX)sp);
    }
    scalarLB = (int32_T)lim[2] - 1;
    if (lim[3] != (int32_T)muDoubleScalarFloor(lim[3])) {
      emlrtIntegerCheckR2012b(lim[3], &p_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[3] < 1) || ((int32_T)lim[3] > sx->size[1])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[3], 1, sx->size[1],
                                    &q_emlrtBCI, (emlrtConstCTX)sp);
    }
    i1 = (int32_T)lim[3];
  }
  loop_ub_tmp = i1 - scalarLB;
  for (i1 = 0; i1 < loop_ub_tmp; i1++) {
    b_loop_ub_tmp = iter - i;
    for (vectorUB = 0; vectorUB < b_loop_ub_tmp; vectorUB++) {
      uy_data[vectorUB + b_loop_ub_tmp * i1] =
          uy_data[((i + vectorUB) + sx->size[0] * (scalarLB + i1)) + 1];
    }
  }
  scalarLB = sx->size[0] * sx->size[1];
  sx->size[0] = iter - i;
  sx->size[1] = loop_ub_tmp;
  emxEnsureCapacity_real_T(sp, sx, scalarLB, &nb_emlrtRTEI);
  if (lim[0] > lim[1]) {
    i = -1;
    iter = -1;
  } else {
    if (lim[0] != (int32_T)muDoubleScalarFloor(lim[0])) {
      emlrtIntegerCheckR2012b(lim[0], &q_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[0] < 1) || ((int32_T)lim[0] > sy->size[0])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[0], 1, sy->size[0],
                                    &r_emlrtBCI, (emlrtConstCTX)sp);
    }
    i = (int32_T)lim[0] - 2;
    if (lim[1] != (int32_T)muDoubleScalarFloor(lim[1])) {
      emlrtIntegerCheckR2012b(lim[1], &r_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[1] < 1) || ((int32_T)lim[1] > sy->size[0])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[1], 1, sy->size[0],
                                    &s_emlrtBCI, (emlrtConstCTX)sp);
    }
    iter = (int32_T)lim[1] - 1;
  }
  if (lim[2] > lim[3]) {
    scalarLB = 0;
    i1 = 0;
  } else {
    if (lim[2] != (int32_T)muDoubleScalarFloor(lim[2])) {
      emlrtIntegerCheckR2012b(lim[2], &s_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[2] < 1) || ((int32_T)lim[2] > sy->size[1])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[2], 1, sy->size[1],
                                    &t_emlrtBCI, (emlrtConstCTX)sp);
    }
    scalarLB = (int32_T)lim[2] - 1;
    if (lim[3] != (int32_T)muDoubleScalarFloor(lim[3])) {
      emlrtIntegerCheckR2012b(lim[3], &t_emlrtDCI, (emlrtConstCTX)sp);
    }
    if (((int32_T)lim[3] < 1) || ((int32_T)lim[3] > sy->size[1])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)lim[3], 1, sy->size[1],
                                    &u_emlrtBCI, (emlrtConstCTX)sp);
    }
    i1 = (int32_T)lim[3];
  }
  loop_ub_tmp = i1 - scalarLB;
  for (i1 = 0; i1 < loop_ub_tmp; i1++) {
    b_loop_ub_tmp = iter - i;
    for (vectorUB = 0; vectorUB < b_loop_ub_tmp; vectorUB++) {
      sy_data[vectorUB + b_loop_ub_tmp * i1] =
          sy_data[((i + vectorUB) + sy->size[0] * (scalarLB + i1)) + 1];
    }
  }
  scalarLB = sy->size[0] * sy->size[1];
  sy->size[0] = iter - i;
  sy->size[1] = loop_ub_tmp;
  emxEnsureCapacity_real_T(sp, sy, scalarLB, &pb_emlrtRTEI);
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtConstCTX)sp);
}

/* End of code generation (register_in_lite.c) */
