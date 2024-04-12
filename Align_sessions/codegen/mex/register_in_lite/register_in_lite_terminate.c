/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * register_in_lite_terminate.c
 *
 * Code generation for function 'register_in_lite_terminate'
 *
 */

/* Include files */
#include "register_in_lite_terminate.h"
#include "_coder_register_in_lite_mex.h"
#include "register_in_lite_data.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void register_in_lite_atexit(void)
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void register_in_lite_terminate(void)
{
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (register_in_lite_terminate.c) */
