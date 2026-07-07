# julia_sir

A cross-language FaaSr example that fits and integrates an **SIR epidemic model**, and demonstrates a **Julia** function working alongside Python and R functions in a single workflow.

## Workflow

Three actions run in sequence (`getData` → `solve` → `processData`), passing files through the S3 data store:

| Action | Language | Function | What it does |
| --- | --- | --- | --- |
| `getData` | Python | `getSIRData` | Downloads JHU COVID-19 daily reports, estimates SIR parameters (`beta`, `gamma`, `N`, `S0`, `I0`, `R0`, `tmax`), and writes `SIR_init_conditions.csv` |
| `solve` | **Julia** | `solveSIRModel` | Reads the initial conditions and integrates the SIR model, writing the trajectory to `sir_output.csv` |
| `processData` | R | `processSIRData` | Reads the trajectory and computes summary statistics (peak infection, timing, attack rate) into `sir_summary.csv` |

Each step uses the FaaSr API (`faasr_get_file` / `faasr_put_file`) to move files through the data store, so the three languages interoperate purely via S3.

## Files

- `getSIRData.py`, `solveSIRModel.jl`, `processSIRData.R` — the function code
- `julia_sir.json` — the workflow configuration (import into the [FaaSr Workflow Builder](https://faasr.io/FaaSr-workflow-builder/))

## Running it

Import `julia_sir.json` into the Web UI, set your GitHub username under the `GH` compute server, download it, and register/invoke it from your FaaSr-workflow repository — the same flow as the [tutorial](https://faasr.io/FaaSr-Docs/tutorial/). The Python step needs `numpy` and `pandas` (declared in the workflow as PyPI dependencies); the Julia step needs `CSV` and `DataFrames` (baked into the Julia container).

## Containers

The workflow uses the official FaaSr GitHub Actions container images: `ghcr.io/faasr/github-actions-python` for the Python action, `ghcr.io/faasr/github-actions-r` for the R action, and `ghcr.io/faasr/github-actions-julia` for the Julia action.
