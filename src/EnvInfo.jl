module EnvInfo

using JSON

struct PkgStatusInfo
    name::String
    version::VersionNumber
    revision::String
    is_clean::Bool
end

function status(pkg::AbstractString,
                version::VersionNumber = Pkg.installed(pkg))
    return cd(Pkg.dir(pkg)) do
        PkgStatusInfo(
            pkg,
            version,
            strip(read(`git rev-parse HEAD`, String)),
            strip(read(`git status --short --untracked-files=no`,
                       String)) == "",
        )
    end
end

status(packages::AbstractVector{<: AbstractString}) = map(status, packages)
status() = [status(pkg, v) for (pkg, v) in Pkg.installed()]

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
