using DelimitedFiles

function read_qapdata(file_name, T::Type)
    n = parse(Int, readline(file_name))
    str = read(file_name, String)
    str = replace(str, r" +\n" => '\n')
    dat_matrix::Matrix{T} = DelimitedFiles.readdlm(Vector{UInt8}(str), ' ', T, '\n', skipstart=1) # finally dlm file!
    A = sparse(@view dat_matrix[1:n, :])
    B = sparse(@view dat_matrix[n+1:end, :])
    return A, B
end

@testset "qap problem: esc16j" begin
    esc16_file = joinpath(@__DIR__, "qapdata", "esc16j.dat")

    A, B = read_qapdata(esc16_file, Float64)
    CAb = QuadraticAssignment(A, B)
    P = admPartSubspace(CAb..., true)
    @test P.n == 150

    blkD = blockDiagonalize(P, true)
    @test sort(blkD.blkSizes) == [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 7, 7, 7, 7, 7]

    model = opt_model(P, blkD, CAb)
    JuMP.set_optimizer(model, CSDP.Optimizer)
    JuMP.set_silent(model)
    JuMP.optimize!(model)

    @test JuMP.termination_status(model) == JuMP.OPTIMAL
    @test JuMP.objective_value(model) ≈ 7.7942186 rtol = 1e-7
end