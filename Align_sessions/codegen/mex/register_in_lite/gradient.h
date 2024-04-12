/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * gradient.h
 *
 * Code generation for function 'gradient'
 *
 */

#pragma once

/* Include files */
#include "register_in_lite_types.h"
#include "rtwtypes.h"
#include "emlrt.h"
#include "mex.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Function Declarations */
void gradient(const emlrtStack *sp, const emxArray_real_T *x,
              emxArray_real_T *varargout_1, emxArray_real_T *varargout_2);

/* End of code generation (gradient.h) */
