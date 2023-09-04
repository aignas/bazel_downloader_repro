# Bazel downloader issue repro

See [this Slack thread](https://bazelbuild.slack.com/archives/CA31HN1T3/p1693462264909799) for context.

## System info

```console
$ uname -a
Darwin FA21050003 22.5.0 Darwin Kernel Version 22.5.0: Thu Jun  8 22:22:22 PDT 2023; root:xnu-8796.121.3~7/RELEASE_X86_64 x86_64

$ bazel info
Starting local Bazel server and connecting to it...
bazel-bin: /private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7/execroot/_main/bazel-out/darwin-fastbuild/bin
bazel-genfiles: /private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7/execroot/_main/bazel-out/darwin-fastbuild/bin
bazel-testlogs: /private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7/execroot/_main/bazel-out/darwin-fastbuild/testlogs
character-encoding: file.encoding = ISO-8859-1, defaultCharset = ISO-8859-1
command_log: /private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7/command.log
committed-heap-size: 268MB
execution_root: /private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7/execroot/_main
gc-count: 4
gc-time: 22ms
install_base: /var/tmp/_bazel_ignas.anikevicius/install/3b6d3b89ac6edd12cb24971ba5ddc98f
java-home: /private/var/tmp/_bazel_ignas.anikevicius/install/3b6d3b89ac6edd12cb24971ba5ddc98f/embedded_tools/jdk
java-runtime: OpenJDK Runtime Environment (build 11.0.6+10-LTS) by Azul Systems, Inc.
java-vm: OpenJDK 64-Bit Server VM (build 11.0.6+10-LTS, mixed mode) by Azul Systems, Inc.
max-heap-size: 4294MB
output_base: /private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7
output_path: /private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7/execroot/_main/bazel-out
package_path: %workspace%
release: release 6.3.2
repository_cache: /var/tmp/_bazel_ignas.anikevicius/cache/repos/v1
server_log: /private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7/java.log.fa21050003.ignas.anikevicius.log.java.20230904-190321.53487
server_pid: 53487
used-heap-size: 39MB
workspace: /Users/ignas.anikevicius/src/github/aignas/bazel_downloader_repro
```

## Expected behaviour

It seems that disabling `bzlmod` works as expected:
```console
$ bazel fetch --noenable_bzlmod @rules_python//python:defs.bzl
INFO: Repository rules_python instantiated at:
  /Users/ignas.anikevicius/src/github/aignas/bazel_downloader_repro/WORKSPACE:3:13: in <toplevel>
Repository rule http_archive defined at:
  /private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7/external/bazel_tools/tools/build_defs/repo/http.bzl:372:31: in <toplevel>
WARNING: Download from https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.23.1/rules_python-0.23.1.tar.gz failed: class com.google.devtools.build.lib.bazel.repository.downloader.UnrecoverableHttpException Unknown host: company-artifactory.com
ERROR: An error occurred during the fetch of repository 'rules_python':
   Traceback (most recent call last):
        File "/private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7/external/bazel_tools/tools/build_defs/repo/http.bzl", line 132, column 45, in _http_archive_impl
                download_info = ctx.download_and_extract(
Error in download_and_extract: java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.23.1/rules_python-0.23.1.tar.gz] to /private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7/external/rules_python/temp772708765773696381/rules_python-0.23.1.tar.gz: Unknown host: company-artifactory.com
ERROR: /Users/ignas.anikevicius/src/github/aignas/bazel_downloader_repro/WORKSPACE:3:13: fetching http_archive rule //external:rules_python: Traceback (most recent call last):
        File "/private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7/external/bazel_tools/tools/build_defs/repo/http.bzl", line 132, column 45, in _http_archive_impl
                download_info = ctx.download_and_extract(
Error in download_and_extract: java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.23.1/rules_python-0.23.1.tar.gz] to /private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7/external/rules_python/temp772708765773696381/rules_python-0.23.1.tar.gz: Unknown host: company-artifactory.com
ERROR: Error computing the main repository mapping: no such package '@rules_python//python': java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.23.1/rules_python-0.23.1.tar.gz] to /private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7/external/rules_python/temp772708765773696381/rules_python-0.23.1.tar.gz: Unknown host: company-artifactory.com
```

## Actual behaviour

And enabling `bzlmod` means that the downloader is not used anymore:
```console
$ bazel clean --expunge --async && bazel fetch --enable_bzlmod @rules_python//python:defs.bzl
INFO: Starting clean.
INFO: Output base moved to /private/var/tmp/_bazel_ignas.anikevicius/2170a98a6de670b82d7ef712358291b7_tmp_13496_ac9640e1-6fc8-4426-9ab7-b6b9c49ce71f for deletion
Starting local Bazel server and connecting to it...
INFO: All external dependencies fetched successfully.
Loading: 1 packages loaded
```
