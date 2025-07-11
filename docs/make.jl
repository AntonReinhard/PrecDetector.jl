using Pkg
using PrecisionCarriers

project_path = Base.Filesystem.joinpath(Base.Filesystem.dirname(Base.source_path()), "..")
Pkg.develop(; path = project_path)

using Documenter


# some paths for links
readme_path = joinpath(project_path, "README.md")
index_path = joinpath(project_path, "docs/src/index.md")
license_path = "https://github.com/AntonReinhard/PrecisionCarriers.jl/blob/main/LICENSE"

# Copy README.md from the project base folder and use it as the start page
open(readme_path, "r") do readme_in
    readme_string = read(readme_in, String)

    # replace relative links in the README.md
    readme_string = replace(readme_string, "[MIT](LICENSE)" => "[MIT]($(license_path))")

    open(index_path, "w") do readme_out
        write(readme_out, readme_string)
    end
end


# setup examples using Literate.jl
using Literate

literate_paths = [
    (
        Base.Filesystem.joinpath(project_path, "docs/src/literal/manual.jl"),
        Base.Filesystem.joinpath(project_path, "docs/src/literal"),
    ),
    (
        Base.Filesystem.joinpath(project_path, "docs/src/literal/example.jl"),
        Base.Filesystem.joinpath(project_path, "docs/src/literal"),
    ),
    (
        Base.Filesystem.joinpath(project_path, "docs/src/literal/bench_epsilons.jl"),
        Base.Filesystem.joinpath(project_path, "docs/src/literal"),
    ),
]

for (file, output_dir) in literate_paths
    Literate.markdown(file, output_dir; documenter = true)
    Literate.notebook(file, output_dir)
end

pages = [
    "Index" => "index.md",
    "Example" => "literal/example.md",
    "Benchmarking" => "literal/bench_epsilons.md",
    "Manual" => "literal/manual.md",
    "Extensions" => "extensions.md",
    "Library" => ["Public" => "lib/public.md", "Internal" => "lib/internal.md"],
    "Contribution" => "contribution.md",
]

try
    makedocs(;
        modules = [PrecisionCarriers],
        checkdocs = :exports,
        authors = "Anton Reinhard",
        repo = Documenter.Remotes.GitHub("AntonReinhard", "PrecisionCarriers.jl"),
        sitename = "PrecisionCarriers.jl",
        format = Documenter.HTML(;
            prettyurls = get(ENV, "CI", "false") == "true",
            canonical = "https://AntonReinhard.github.io/PrecisionCarriers.jl",
            assets = String[],
        ),
        pages = pages,
    )
finally
    @info "GarbageCollection: remove generated landing page"
    rm(index_path)
end


deploydocs(; repo = "github.com/AntonReinhard/PrecisionCarriers.jl.git", push_preview = true)
