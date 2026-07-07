using CSV
using DataFrames

function sirModel!(du, u, p, t)
    S, I, R = u
    Beta, Gamma, N = p
    du[1] = -Beta * S * I / N
    du[2] = Beta * S * I / N - Gamma * I
    du[3] = Gamma * I
end

function solveSIRModel()
    inputFile = "SIR_init_conditions.csv"
    faasr_get_file(inputFile, inputFile)

    # Expecting columns: beta, gamma, N, S0, I0, R0, tmax
    data = CSV.read(inputFile, DataFrame)
    Beta = data.beta[1]
    Gamma = data.gamma[1]
    N = data.N[1]
    S0 = data.S0[1]
    I0 = data.I0[1]
    R0 = data.R0[1]
    tmax = data.tmax[1]

    # Basic reproduction number
    R_null = Beta / Gamma

    u0 = [S0, I0, R0]
    tspan = (0.0, tmax)
    p = (Beta, Gamma, N)

    # NOTE: The ODE solver below (OrdinaryDiffEq / DifferentialEquations) is the
    # preferred way to integrate the SIR model. It is commented out because the
    # default github-actions-julia container does not bake in OrdinaryDiffEq, and
    # FaaSr has no runtime Julia-package install mechanism, so the heavy runtime
    # precompile is impractical. To use it, build a container that pre-installs
    # OrdinaryDiffEq and uncomment the two lines below (and `using OrdinaryDiffEq`).
    # prob = ODEProblem(sirModel!, u0, tspan, p)
    # sol = solve(prob, Tsit5())

    # Toy data: simple Euler integration
    dt = 1.0
    t = collect(0.0:dt:tmax)
    n = length(t)
    S = zeros(n)
    I = zeros(n)
    R = zeros(n)
    S[1], I[1], R[1] = u0
    du = zeros(3)
    for i in 2:n
        sirModel!(du, [S[i-1], I[i-1], R[i-1]], p, t[i-1])
        S[i] = S[i-1] + dt * du[1]
        I[i] = I[i-1] + dt * du[2]
        R[i] = R[i-1] + dt * du[3]
    end

    out_df = DataFrame(time=t, S=S, I=I, R=R)
    outName = "sir_output.csv"
    CSV.write(outName, out_df)
    faasr_put_file(outName, outName)
end

#solveSIRModel()
