# Machine Learning Standards

Extends [PYTHON.md](PYTHON.md). Everything there applies. This file covers only what is specific to shipping models.

Global rules are not repeated here. Ownership map: [../README.md](../README.md).

Scope: services that load a trained model and make a decision with it. Training pipelines and research notebooks are out of scope until this document says otherwise.

## Runtime and version

- The inference runtime and its version MUST be pinned like any other dependency. See [../standards/DEPENDENCIES.md](../standards/DEPENDENCIES.md).
- The execution device or provider MUST be configurable by environment, defaulting to CPU. MUST NOT hardcode a device selector in each loader.
- A model's required runtime version MUST be recorded with the model reference. A weights file that only loads under one runtime major is a version pin, whether or not anyone wrote it down.

## Language and types

- Array parameters SHOULD declare dtype and shape, not a bare array type. `NDArray[np.float32]` documents a contract; `np.ndarray` documents nothing.
- Embedding dimensionality MUST appear in the type or in a named constant, never as a bare integer at the call site.
- A score MUST NOT be typed as `int`. Similarity and confidence are floats, and an `int` annotation over a float assignment is a lie the type checker was configured not to catch.

## Project structure

- Model loading MUST be isolated in one module per model. Business code MUST NOT construct a model handle.
- Input and output contracts for each model — embedding dimensionality, expected normalization, alignment, colour space — MUST be documented next to its loader, not only in prose elsewhere.
- Data directories holding real inputs MUST be gitignored and excluded from the build context.

## Lint and format

Follows [PYTHON.md](PYTHON.md). No additions.

## Model artifacts

- Model weights MUST NOT be committed to git. Keep them in a release, registry, or object store, with a checked-in placeholder documenting the expected filenames.
- Any binary that must be committed MUST go through git-lfs. A repo committing a binary raw while gitignoring the rest of its weights has the policy but not the mechanism.
- Artifacts MUST be fetched from a version-pinned source **and** verified by checksum before use. Structural checks — that an archive extracts, that a file is the right type — prove the download completed, not that it is the artifact you intended.
- The fetch step MUST fail the build when verification fails. A warning is not verification.
- Artifact provenance MUST be recorded: source, version or tag, checksum, and the date fetched.

## Determinism

- Random seeds MUST be set in any inference or evaluation path, and MUST be logged with the result.
- A result that cannot be reproduced from the recorded inputs, model version, and seed MUST be treated as unexplained, not as noise.
- Preprocessing MUST be deterministic. Any augmentation or sampling in an inference path MUST be seeded and documented.

## Thresholds and decisions

- A decision threshold MUST live in configuration. MUST NOT be a function default argument. A biometric accept-or-reject threshold written as `strong_threshold: float = 0.75` in a function signature is the most consequential line in the service and the least visible.
- Thresholds MUST be versioned together with the model that produces the scores they compare. A model swap invalidates every threshold tuned against the old one.
- Changing a threshold MUST go through the same review as changing code, and MUST report its measured effect. See [Evaluation](#evaluation).
- The decision function MUST be unit-tested directly, at and around each threshold boundary. See [PYTHON.md](PYTHON.md).

## Errors

- A model failing to load MUST fail startup. MUST NOT degrade to a code path that answers without the model.
- A prediction below a confidence floor MUST return an explicit "no decision" outcome. MUST NOT silently return the best available match.
- Inference errors MUST be distinguishable from input-validation errors in the response and in logs. Follows the error-code rules in [PYTHON.md](PYTHON.md).

## Logging

- Every decision MUST log: model identifier and version, threshold set, score, outcome, and seed.
- Raw inputs MUST NOT be logged. A face, a fingerprint, or a document image in a log file is a data breach with extra steps. See [../standards/SECURITY.md](../standards/SECURITY.md).
- Embeddings MUST NOT be logged. They are derived personal data and, for biometrics, are often reversible enough to matter.
- Inference latency SHOULD be recorded per stage, so a regression can be attributed.

## Security notes

Mandatory rules live in [../standards/SECURITY.md](../standards/SECURITY.md). Model-serving specifics:

- Biometric and personal data directories MUST be gitignored and excluded from build contexts.
- An identifier arriving in a request header MUST NOT be trusted as authorization for the data it names. An unauthenticated tenant header on an index endpoint means any caller can read, add to, or delete another tenant's records.
- Upload size MUST be enforced before the payload is read into memory, with the limit defined in exactly one place. Two different limits in one shared library means neither is the limit.
- Model files are executable input to the runtime. They MUST be treated as untrusted unless checksum-verified from a controlled source.
- Retention for stored inputs and embeddings MUST be stated. Storing a biometric template indefinitely because nothing says otherwise is a decision made by omission.

## Serving

- Models MUST be loaded once at startup into read-only application state. MUST NOT be loaded per request.
- Inference MUST NOT run on the event loop. See the async rules in [PYTHON.md](PYTHON.md). Every CPU-bound model call sitting in an `async def` serializes the whole process, and no amount of concurrency configuration fixes it.
- An in-process index or cache MUST be documented as invalid under multi-process serving unless externalized, at the point it is defined.
- Batch size and concurrency limits MUST be explicit, so load behavior is a decision rather than an accident.

## Evaluation

- A held-out evaluation set MUST exist, versioned, and MUST NOT overlap training data.
- Every model change and every threshold change MUST report accuracy metrics measured on that set, before merge. For a matching or verification system, that means false match rate and false non-match rate at the operating threshold, not a single accuracy number.
- Metrics MUST be recorded in the pull request. See [../standards/PR.md](../standards/PR.md).
- A regression beyond a stated tolerance MUST block the merge, the same as a failing test.
- Each deployed model SHOULD have a short model card: source, version, training data provenance, evaluation results, known limitations, and intended use.
Note: absent this, a model or threshold change that degrades accuracy is undetectable until users report it, which for an authentication system means either lockouts or false accepts.

## Testing

- Every model loader MUST have a test that loads the artifact and asserts the output shape and dtype.
- The decision function MUST have unit tests at each threshold boundary, using fixed scores rather than live inference.
- Inference tests MUST use committed small fixtures, never network downloads.
- An accuracy regression test MUST run against the evaluation set on any change to a model, a threshold, or a preprocessing step. It MAY be excluded from the per-commit suite for runtime reasons, and MUST then run on a schedule and before release. See [../standards/DELIVERY.md](../standards/DELIVERY.md).
- Notebooks MUST be committed with outputs stripped, or not committed.

Strategy and coverage stance: [../standards/TESTING.md](../standards/TESTING.md).
