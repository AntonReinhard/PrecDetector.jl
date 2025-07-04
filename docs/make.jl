using Pkg
using PrecDetector

project_path = Base.Filesystem.joinpath(Base.Filesystem.dirname(Base.source_path()), "..")
Pkg.develop(; path = project_path)

using Documenter

# setup examples using Literate.jl
using Literate

literate_paths = [
    (
        Base.Filesystem.joinpath(project_path, "docs/src/manual.jl"),
        Base.Filesystem.joinpath(project_path, "docs/src/"),
    ),
    (
        Base.Filesystem.joinpath(project_path, "docs/src/example.jl"),
        Base.Filesystem.joinpath(project_path, "docs/src/"),
    ),
]

for (file, output_dir) in literate_paths
    Literate.markdown(file, output_dir; documenter = true)
    Literate.notebook(file, output_dir)
end

pages = [
    "index.md",
    "Manual" => "manual.md",
    "Example" => "example.md",
    "Library" => ["Public" => "lib/public.md", "Internal" => "lib/internal.md"],
    "Contribution" => "contribution.md",
]

makedocs(;
    modules = [PrecDetector],
    checkdocs = :exports,
    authors = "Anton Reinhard",
    repo = Documenter.Remotes.GitHub("AntonReinhard", "PrecDetector.jl"),
    sitename = "PrecDetector.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://AntonReinhard.github.io/PrecDetector.jl",
        assets = String[],
    ),
    pages = pages,
)
deploydocs(; repo = "github.com/AntonReinhard/PrecDetector.jl.git", push_preview = false)
