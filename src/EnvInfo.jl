module EnvInfo

@static if VERSION < v"0.7.0-"
    # Pkg is already imported.
else
    using Pkg
end

using JSON


"""
A thin wrapper of `Pkg.installed`.

In Julia 0.7, stdlib packages are included in Pkg.installed() and `v`
is a `nothing` in that case.

Furthermore, it looks like that `Pkg.dir(pkg)` is a `nothing` when the
package `pkg` is installed as a dependency.
"""
_all_packages_07() =
    [(pkg, v) for (pkg, v) in Pkg.installed()
     if v !== nothing && Pkg.dir(pkg) !== nothing]

@static if VERSION < v"0.7.0-"
    const package_version = Pkg.installed
    const devnul = DevNull
    const all_packages = Pkg.installed
else
    const all_packages = _all_packages_07
    package_version(pkg) = Pkg.installed()[pkg]
end


struct PkgStatusInfo
    name::String
    version::VersionNumber
    revision::String
    is_clean::Bool
end


function status(pkg::AbstractString,
                version::VersionNumber = package_version(pkg))

    local revision, is_clean

    cd(Pkg.dir(pkg)) do
        try
            revision = strip(read(
                pipeline(`git rev-parse HEAD`; stderr=devnul),
                String))
        catch
            # In Julia >= 0.7, Pkg.dir(pkg) is not a Git
            # repository for normal installation.
            revision = ""
            is_clean = true
            return
        end
        is_clean = strip(read(`git status --short --untracked-files=no`,
                              String)) == ""
    end

    return PkgStatusInfo(pkg, version, revision, is_clean)
end

status(packages::AbstractVector{<: AbstractString}) = map(status, packages)
status() = [status(pkg, v) for (pkg, v) in all_packages()]

function envinfo(packages; include_installed = false)
    info = Dict{String, Any}(
        "status" => status(packages),
    )
    if include_installed
        info["installed"] = Pkg.installed()
    end
    return info
end

function save(filename::AbstractString, packages::AbstractVector;
              assert_clean = false,
              kwargs...)
    info = envinfo(packages; kwargs...)

    if assert_clean
        unclean = []
        for psi in info["status"]
            if ! psi.is_clean
                push!(unclean, psi.name)
            end
        end
        if length(unclean) > 0
            names = join(unclean, ", ")
            error("Package(s) $names are not clean.")
        end
    end

    open(filename, "w") do io
        JSON.print(io, info)
    end
end

# package code goes here

end # module
