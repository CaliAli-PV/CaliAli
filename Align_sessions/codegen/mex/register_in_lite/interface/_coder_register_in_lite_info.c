/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_register_in_lite_info.c
 *
 * Code generation for function 'register_in_lite'
 *
 */

/* Include files */
#include "_coder_register_in_lite_info.h"
#include "emlrt.h"
#include "tmwtypes.h"

/* Function Declarations */
static const mxArray *emlrtMexFcnResolvedFunctionsInfo(void);

/* Function Definitions */
static const mxArray *emlrtMexFcnResolvedFunctionsInfo(void)
{
  const mxArray *nameCaptureInfo;
  const char_T *data[5] = {
      "789ced54cb4ac340149d6805376a70e15ee84e092888b86c4bc4405bfa428a46344da634"
      "388f90a4d27e857e869fe152ffc0cfb1c94cda24769ad262dde42e7a"
      "e77232f79e7b921e2069350900b00f781cb2b4c74b99e72d908c342ef1bc9daaa3d80185"
      "c4bd087fe5d9a4c487239f15c4c0707ad3a2d82606f13b630702177a",
      "14bd402b44fa36821d1bc376bca80715be8e41d3228082736500cde7f6100377e0cd18a2"
      "7831d5e35db06f61493dca023de4147eaf55bbea43111b3e327a2ea5"
      "7e51f729453d3ad221463ab27b3ac37487a2717f48747b2298eb10054b55adae965a49de"
      "6f6bf23ecde01de126b5a0ab845c8881d861c2d0f0213fd7a03fa096",
      "a79289de317e4f2bf24b87885f14d1bc8f15e745fd1f33e64578f01eebf3dfa337305c68"
      "e9a162fcf784a7483f7e6202eabf045470a67e074bee93ceb3e777c3"
      "dc3cfe0ea14dcd03ddd2d746e7f1f8af792341bf65bfc723c13c3985d7b4c6c52db42fef"
      "ae6ae72d93ba4d7ca6b937331e8d8c39593c80a0de54ff75fdb922e8",
      "2fa7f075fc397067b5dd49f0cefd9945eecff3f7c9fd9945eecf8be764f100827a53fd3f"
      "05f797d5b127e82fa7f005febce2ff9a54a969a02aa54e995a630527"
      "f7cafd9b45eedff3f7c9fd9b45eedf8be764f10082faaffbff00423f5f72",
      ""};
  nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(&data[0], 4632U, &nameCaptureInfo);
  return nameCaptureInfo;
}

mxArray *emlrtMexFcnProperties(void)
{
  mxArray *xEntryPoints;
  mxArray *xInputs;
  mxArray *xResult;
  const char_T *propFieldName[7] = {
      "Version",      "ResolvedFunctions", "Checksum",    "EntryPoints",
      "CoverageInfo", "IsPolymorphic",     "PropertyList"};
  const char_T *epFieldName[6] = {
      "Name",           "NumberOfInputs", "NumberOfOutputs",
      "ConstantInputs", "FullPath",       "TimeStamp"};
  xEntryPoints =
      emlrtCreateStructMatrix(1, 1, 6, (const char_T **)&epFieldName[0]);
  xInputs = emlrtCreateLogicalMatrix(1, 3);
  emlrtSetField(xEntryPoints, 0, "Name",
                emlrtMxCreateString("register_in_lite"));
  emlrtSetField(xEntryPoints, 0, "NumberOfInputs",
                emlrtMxCreateDoubleScalar(3.0));
  emlrtSetField(xEntryPoints, 0, "NumberOfOutputs",
                emlrtMxCreateDoubleScalar(7.0));
  emlrtSetField(xEntryPoints, 0, "ConstantInputs", xInputs);
  emlrtSetField(xEntryPoints, 0, "FullPath",
                emlrtMxCreateString(
                    "F:\\Tracking data\\Optimal Focus\\register_in_lite.m"));
  emlrtSetField(xEntryPoints, 0, "TimeStamp",
                emlrtMxCreateDoubleScalar(739214.49278935185));
  xResult =
      emlrtCreateStructMatrix(1, 1, 7, (const char_T **)&propFieldName[0]);
  emlrtSetField(xResult, 0, "Version",
                emlrtMxCreateString("9.14.0.2254940 (R2023a) Update 2"));
  emlrtSetField(xResult, 0, "ResolvedFunctions",
                (mxArray *)emlrtMexFcnResolvedFunctionsInfo());
  emlrtSetField(xResult, 0, "Checksum",
                emlrtMxCreateString("d4QRJNzJz5OX8ZCEoYXjDG"));
  emlrtSetField(xResult, 0, "EntryPoints", xEntryPoints);
  return xResult;
}

/* End of code generation (_coder_register_in_lite_info.c) */
