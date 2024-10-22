using Test
using LinearAlgebra
using SparseArrays
using SDPSymmetryReduction
import CSDP

@testset "SDPSymmetryReduction.jl" begin

    @test iszero(SDPSymmetryReduction.roundToZero(1e-10))

    M = rand(1:10, 10, 10)
    @test SDPSymmetryReduction.part(M).n == length(unique(M))

    P1 = Partition(3, [1 2 2; 2 3 3; 2 3 3])
    P2 = Partition(3, [1 1 2; 1 1 2; 1 1 3])
    P3 = Partition(6, [1 2 4; 2 3 5; 2 3 6])
    @test SDPSymmetryReduction.coarsestPart(P1, P2).P == P3.P

    @test SDPSymmetryReduction.part(SDPSymmetryReduction.rndPart(P1)).P == P1.P

    M = rand(10, 10)
    @test SDPSymmetryReduction.roundMat(M) ≈ M atol = 1e-4

    A = rand(9, 3)
    M = rand(3, 3)
    @test maximum(abs.(A \ vec(SDPSymmetryReduction.projectAndRound(M, A; round=false)))) ≈ 0.0 atol = 1e-10

    T = M - SDPSymmetryReduction.projectAndRound(M, A; round=false)
    @test all(isapprox.(A * (A \ vec(T)) - vec(T), 0, atol=1e-8))

    @testset "unsymmetization and complex" begin
        @test SDPSymmetryReduction.unSymmetrize(P1).P == Partition(4, [1 3 3; 2 4 4; 2 4 4]).P

        # complex block diagonalization tests
        P = Partition(4, [1 2 3 2; 2 1 2 3; 3 2 1 2; 2 3 2 1])
        @test blockDiagonalize(P, true; complex=true).blkSizes == [1, 1, 1]

        @test_throws DimensionMismatch blockDiagonalize(P, true; complex=false)

    end

    include("sd_problems.jl")
    include("lovasz.jl")
    include("qap.jl")
end
