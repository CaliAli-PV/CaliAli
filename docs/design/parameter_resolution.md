# Design: parameter resolution

Status: **agreed, not built.** Nothing in this document is implemented yet.

## Why

Parameters live in a flat namespace and `CaliAli_parameters` copies each one into
every module that uses it. The nested `CaliAli_options` is that projection. It is
not editable: setting a value on one module and not the others is collapsed on
the next parse, and every stage re-parses, so the edit never survives.

```matlab
CaliAli_options.inter_session_alignment.batch_sz = 250;   % looks accepted
CaliAli_options = CaliAli_parameters(CaliAli_options);    % silently back to 'auto'
```

This cost a real experiment: a benchmark scenario configured that way never ran
the condition it claimed to test, and nothing said so. A warning was added as a
stopgap. It reports the discard and tells the user what to type instead, but the
underlying behaviour is still that a reasonable-looking edit does nothing.

The design below makes the edit work.

## The rules

### Setting a value

| Spelling | Effect |
|---|---|
| `CaliAli_parameters(opts,'batch_sz',250)` | 250 in every module, clearing any per-module override |
| `CaliAli_parameters(opts,'motion_correction.batch_sz',250)` | that stage only |
| `CaliAli_parameters(opts,'motion_correction.batch_sz',[])` | drop the override; the stage inherits again |
| `opts.motion_correction.batch_sz = 250` | that stage only, honoured, no warning |

A bare name means the pipeline-wide value. A dotted name means one stage. Both
are explicit, so a pipeline-wide call clearing a per-module override is the user
saying "all modules", not a side effect.

A bare substructure -- `CaliAli_parameters(opts.motion_correction, ...)` -- is
NOT part of this. The function cannot tell which module a bare substructure
belongs to, because most parameter names appear in several. The dotted form says
the same thing unambiguously and keeps one entry point.

### `[]` means auto

For a parameter that is INHERITABLE, auto means: take the value from the module
above. The chain is

    cnmf  <-  inter_session_alignment  <-  motion_correction  <-  preprocessing  <-  downsampling

`downsampling` is the root and must hold a concrete value; it cannot be `[]`.

For a parameter that is DERIVED, `[]` keeps its current meaning of "compute it":
`gSig` from `spatial_ds`, `BVsize` from `gSig`, `w_overlap` from `patch_dims`.
Both readings are the same idea -- "work it out" -- and which applies is a
property of the parameter, written down once.

### Resolution is lazy

The struct stores `[]` where nothing was set. A module resolves when it reads.

This is the only version where the semantics hold permanently. Resolving at parse
time would write concrete values into every module, destroying the `[]` it just
consumed; on the next parse -- and every stage re-parses -- each module would
look deliberately set, and editing an upstream value would stop propagating. The
alternative is recording which values were inherited rather than set, which is
bookkeeping that has to survive being saved and reloaded.

Cost, accepted: every read site for an inheritable parameter needs the accessor.
Bounded but real. `batch_sz` alone is read in `get_batch_size`,
`create_batch_list`, `CaliAli_crop`, motion correction and the detrend stage.

### Named values instead of magic numbers

`0` currently means "all at once" in downsampling and "one batch per session" in
inter-session alignment: the same number, two meanings, neither discoverable.

- **`'auto'`** -- the memory heuristic in `compute_auto_batch_size`, from frame
  size and available RAM. The same meaning in every stage.
- **`'per-session'`** -- batch boundaries fall on session boundaries. Only
  DISTINCT where the data is concatenated, which is CNMF-E, where
  `get_batch_size` splits the combined recording by `F`. Downsampling and motion
  correction already work one file per session, so there it coincides with "the
  whole file". That is a no-op, not an error: a uniform vocabulary is worth more
  than pruning the redundancy.

## What this replaces

The divergence warning in `CaliAli_parameters` becomes wrong and should be
removed with this change. Once a per-module value is honoured, nothing is being
discarded, and the warning would fire on legitimate usage.

## To settle during implementation

- Which parameters are inheritable and which are derived. The list has to be
  explicit; it cannot be inferred from the default being `[]`, because both
  kinds use `[]`.
- Whether every stage accepts every named value, or each accepts only the names
  that mean something for it.
- Whether a stage that reads an inheritable parameter without the accessor
  should fail loudly rather than silently seeing `[]`.
- One consequence to document next to the chain: a user who sets an override and
  forgets will not see it change when they later set the pipeline-wide value
  with a dotted name. The override is visible in the struct, so this is the
  lesser surprise, but it is a surprise.
