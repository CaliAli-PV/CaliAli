/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * register_in_lite_initialize.c
 *
 * Code generation for function 'register_in_lite_initialize'
 *
 */

/* Include files */
#include "register_in_lite_initialize.h"
#include "_coder_register_in_lite_mex.h"
#include "register_in_lite_data.h"
#include "rt_nonfinite.h"

/* Function Declarations */
static void register_in_lite_once(void);

/* Function Definitions */
static void register_in_lite_once(void)
{
  mex_InitInfAndNan();
}

void register_in_lite_initialize(void)
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2022b(&st);
  emlrtClearAllocCountR2012b(&st, false, 0U, NULL);
  emlrtEnterRtStackR2012b(&st);
  emlrtLicenseCheckR2022a(&st, "EMLRT:runTime:MexFunctionNeedsLicense",
                          "image_toolbox", 2);
  if (emlrtFirstTimeR2012b(emlrtRootTLSGlobal)) {
    register_in_lite_once();
  }
}

/* End of code generation (register_in_lite_initialize.c) */
