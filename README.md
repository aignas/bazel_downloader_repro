# Bazel downloader issue repro

See [this Slack thread](https://bazelbuild.slack.com/archives/CA31HN1T3/p1693462264909799) for context.

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
