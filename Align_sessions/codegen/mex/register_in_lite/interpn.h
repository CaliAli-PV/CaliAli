/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * interpn.h
 *
 * Code generation for function 'interpn'
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
void interpn(const emlrtStack *sp, const emxArray_real_T *varargin_1,
             const emxArray_real_T *varargin_2,
             const emxArray_real_T *varargin_3,
             const emxArray_real_T *varargin_4,
             const emxArray_real_T *varargin_5, emxArray_real_T *Vq);

/* End of code generation (interpn.h) */
