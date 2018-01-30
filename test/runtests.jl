using EnvInfo: status, save, PkgStatusInfo
using Base.Test

@testset "status" begin
    @test status("EnvInfo") isa PkgStatusInfo
    @test all(psi isa PkgStatusInfo for psi in status(["EnvInfo", "JSON"]))
    @test all(psi isa PkgStatusInfo for psi in status())
end

@testset "save" begin
    @test save("/dev/null", ["EnvInfo", "JSON"]) === nothing
end
