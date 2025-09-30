### sessions_non_rigid {#sessions_non_rigid}

```matlab
function [P, CaliAli_options] = sessions_non_rigid(P, CaliAli_options, neurons_only)
```

#### Description
`sessions_non_rigid`: Perform non-rigid alignment for session data.

##### Function Inputs:
| Parameter Name | Type    | Description                                                                 |
|---------------|---------|-----------------------------------------------------------------------------|
| P               | Cell array | Cell array containing the session projections.                           |
| CaliAli_options | Structure | Structure containing configuration options for alignment.                 |
| neurons_only    | Boolean   | (Optional) Boolean flag indicating whether to align only neuron data. Default is false. |

##### Function Outputs:
| Parameter Name | Type    | Description                                                                 |
|---------------|---------|-----------------------------------------------------------------------------|
| P               | Cell array | Updated cell array with applied non-rigid shifts.                         |
| CaliAli_options | Structure | Updated structure with computed non-rigid transformations.               |

##### Example usage:
```matlab
[P, CaliAli_options] = sessions_non_rigid(P, CaliAli_options);
[P, CaliAli_options] = sessions_non_rigid(P, CaliAli_options, true);  % Align utilizing only neurons projections
```
