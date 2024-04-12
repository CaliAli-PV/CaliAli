/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * register_in_lite.h
 *
 * Code generation for function 'register_in_lite'
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
emlrtCTX emlrtGetRootTLSGlobal(void);

void emlrtLockerFunction(EmlrtLockeeFunction aLockee, emlrtConstCTX aTLS,
                         void *aData);

void register_in_lite(const emlrtStack *sp, const emxArray_uint8_T *F,
                      const emxArray_uint8_T *M, const struct0_T *opt,
                      emxArray_real_T *Mp, emxArray_real_T *sx,
                      emxArray_real_T *sy, emxArray_real_T *vx,
                      emxArray_real_T *vy, emxArray_real_T *e);

/* End of code generation (register_in_lite.h) */
