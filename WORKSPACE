load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "1698624e878b0607052ae6131aa216d45ebb63871ec497f26c67455b34119c80",
    strip_prefix = "rules_docker-0.15.0",
    urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.15.0/rules_docker-v0.15.0.tar.gz"],
)

load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)

container_repositories()

load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps = "deps")

container_deps()

load("@io_bazel_rules_docker//container:container.bzl", "container_pull")

container_pull(
    name = "distroless",
    digest = "sha256:f2d2b4f3b53f952d74148ad1242f3d36904598b33cd6411ee886088e0744270e",
    registry = "gcr.io",
    repository = "distroless/static-debian10",
)

http_archive(
    name = "terraform_0.13.0_linux_amd64",
    build_file_content = "exports_files([\"terraform\"])",
    sha256 = "9ed437560faf084c18716e289ea712c784a514bdd7f2796549c735d439dbe378",
    urls = ["https://releases.hashicorp.com/terraform/0.13.0/terraform_0.13.0_linux_amd64.zip"],
)
