using EnvInfo: status, save, PkgStatusInfo

@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end


@testset "status" begin
    @test status("EnvInfo") isa PkgStatusInfo
    @test all(psi isa PkgStatusInfo for psi in status(["EnvInfo", "JSON"]))
    @test all(psi isa PkgStatusInfo for psi in status())
end

@testset "save" begin
    @test save("/dev/null", ["EnvInfo", "JSON"]) === nothing
    @test save("/dev/null", ["EnvInfo", "JSON"],
               include_installed = true) === nothing
end
