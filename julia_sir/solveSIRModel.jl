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
    p = (Beta, Gamma, N)

    # Integrate the SIR model with a simple Euler scheme
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
