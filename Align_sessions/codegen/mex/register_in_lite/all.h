/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * all.h
 *
 * Code generation for function 'all'
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
boolean_T all(const boolean_T x[2]);

boolean_T b_all(const emlrtStack *sp, const emxArray_boolean_T *x);

/* End of code generation (all.h) */
