load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_push")

TERRAFORM_RELEASES = [
    {
        "version": "0.13.5",
        "sha256": "f7b7a7b1bfbf5d78151cfe3d1d463140b5fd6a354e71a7de2b5644e652ca5147",
    },
    {
        "version": "0.13.4",
        "sha256": "a92df4a151d390144040de5d18351301e597d3fae3679a814ea57554f6aa9b24",
    },
    {
        "version": "0.13.3",
        "sha256": "35c662be9d32d38815cde5fa4c9fa61a3b7f39952ecd50ebf92fd1b2ddd6109b",
    },
    {
        "version": "0.13.0",
        "sha256": "9ed437560faf084c18716e289ea712c784a514bdd7f2796549c735d439dbe378",
    },
]

def terraform_binaries():
    for release in TERRAFORM_RELEASES:
        maybe(
            http_archive,
            name = "terraform_{}_linux_amd64".format(release["version"]),
            build_file_content = "exports_files([\"terraform\"])",
            sha256 = release["sha256"],
            urls = ["https://releases.hashicorp.com/terraform/{}/terraform_{}_linux_amd64.zip".format(release["version"], release["version"])],
        )

def terraform_images():
    for release in TERRAFORM_RELEASES:
        container_image(
            name = release["version"],
            base = "@distroless//image",
            cmd = "help",
            directory = "/bin/",
            entrypoint = ["/bin/terraform"],
            files = ["@terraform_{}_linux_amd64//:terraform".format(release["version"])],
            mode = "0o755",
            repository = "quay.io/hadrienpatte",
        )

        container_push(
            name = "{}_push".format(release["version"]),
            format = "Docker",
            image = ":{}".format(release["version"]),
            registry = "quay.io",
            repository = "hadrienpatte/terraform",
            tag = release["version"],
        )
