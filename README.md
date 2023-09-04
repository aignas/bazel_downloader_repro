# Bazel downloader issue repro

See [this Slack thread](https://bazelbuild.slack.com/archives/CA31HN1T3/p1693462264909799) for context.

This can be reproduced with `last_green` and `6.3.2` versions.

## System info

### Linux

Tested on linux and the downloader config is working as expected.

```console
$ uname -a
Linux panda 6.4.12-arch1-1 #1 SMP PREEMPT_DYNAMIC Thu, 24 Aug 2023 00:38:14 +0000 x86_64 GNU/Linux

2023/09/05 08:47:55 Using unreleased version at commit 290fc80a5aae9dea06de52deed7098a5b8443f26
bazel-bin: /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/execroot/_main/bazel-out/k8-fastbuild/bin
bazel-genfiles: /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/execroot/_main/bazel-out/k8-fastbuild/bin
bazel-testlogs: /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/execroot/_main/bazel-out/k8-fastbuild/testlogs
character-encoding: file.encoding = ISO-8859-1, defaultCharset = ISO-8859-1
command_log: /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/command.log
committed-heap-size: 49MB
execution_root: /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/execroot/_main
gc-count: 13
gc-time: 85ms
install_base: /home/aignas/.cache/bazel/_bazel_aignas/install/db5825675b4c6e0fc3cbc278b4f8ada4
java-home: /home/aignas/.cache/bazel/_bazel_aignas/install/db5825675b4c6e0fc3cbc278b4f8ada4/embedded_tools/jdk
java-runtime: OpenJDK Runtime Environment (build 20.0.1+9) by Azul Systems, Inc.
java-vm: OpenJDK 64-Bit Server VM (build 20.0.1+9, mixed mode) by Azul Systems, Inc.
local_resources: RAM=5836MB, CPU=8.0
max-heap-size: 1530MB
output_base: /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069
output_path: /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/execroot/_main/bazel-out
package_path: %workspace%
release: development version
repository_cache: /home/aignas/.cache/bazel/_bazel_aignas/cache/repos/v1
server_log: /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/java.log.panda.aignas.log.java.20230905-084621.42748
server_pid: 42748
used-heap-size: 27MB
workspace: /home/aignas/src/github/aignas/bazel_downloader_repro
```

### Mac

It seems that this problem can be reproduced on the Mac I have access to.

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

All of the following should fail
```console
$ rm -f MODULE.bazel.lock && bazel clean --expunge --async && USE_BAZEL_VERSION=last_green bazel fetch --noenable_bzlmod @rules_python//python:defs.bzl
$ rm -f MODULE.bazel.lock && bazel clean --expunge --async && USE_BAZEL_VERSION=last_green bazel fetch --enable_bzlmod @rules_python//python:defs.bzl
$ rm -f MODULE.bazel.lock && bazel clean --expunge --async && USE_BAZEL_VERSION=6.3.2 bazel fetch --noenable_bzlmod @rules_python//python:defs.bzl
$ rm -f MODULE.bazel.lock && bazel clean --expunge --async && USE_BAZEL_VERSION=6.3.2 bazel fetch --enable_bzlmod @rules_python//python:defs.bzl
```

## Actual behaviour

### Linux

It works as expected:
```console
$ ./repro.sh
+ grep '^\$'
+ cat README.md
+ sed 's/$ //g'
+ grep -v 'bazel info'
+ grep -v 'uname -a'
+ grep -v repro.sh
+ xargs '-I{}' bash -c '{}'
2023/09/05 08:52:39 Using unreleased version at commit 290fc80a5aae9dea06de52deed7098a5b8443f26
Starting local Bazel server and connecting to it...
INFO: Starting clean.
INFO: Output base moved to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069_tmp_43896_36dd24f1-ada7-4818-928b-453237a1f6c4 for deletion
2023/09/05 08:52:43 Using unreleased version at commit 290fc80a5aae9dea06de52deed7098a5b8443f26
Starting local Bazel server and connecting to it...
WARNING: Download from https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.23.1/rules_python-0.23.1.tar.gz failed: class com.google.devtools.build.lib.bazel.repository.downloader.UnrecoverableHttpException Unknown host: company-artifactory.com
INFO: Repository rules_python instantiated at:
  /home/aignas/src/github/aignas/bazel_downloader_repro/WORKSPACE:3:13: in <toplevel>
Repository rule http_archive defined at:
  /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/bazel_tools/tools/build_defs/repo/http.bzl:379:31: in <toplevel>
ERROR: An error occurred during the fetch of repository 'rules_python':
   Traceback (most recent call last):
        File "/home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/bazel_tools/tools/build_defs/repo/http.bzl", line 139, column 45, in _http_archive_impl
                download_info = ctx.download_and_extract(
Error in download_and_extract: java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.23.1/rules_python-0.23.1.tar.gz] to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/rules_python/temp11778055335064209350/rules_python-0.23.1.tar.gz: Unknown host: company-artifactory.com
ERROR: /home/aignas/src/github/aignas/bazel_downloader_repro/WORKSPACE:3:13: fetching http_archive rule //external:rules_python: Traceback (most recent call last):
        File "/home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/bazel_tools/tools/build_defs/repo/http.bzl", line 139, column 45, in _http_archive_impl
                download_info = ctx.download_and_extract(
Error in download_and_extract: java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.23.1/rules_python-0.23.1.tar.gz] to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/rules_python/temp11778055335064209350/rules_python-0.23.1.tar.gz: Unknown host: company-artifactory.com
ERROR: Error computing the main repository mapping: no such package '@rules_python//python': java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.23.1/rules_python-0.23.1.tar.gz] to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/rules_python/temp11778055335064209350/rules_python-0.23.1.tar.gz: Unknown host: company-artifactory.com
2023/09/05 08:52:46 Using unreleased version at commit 290fc80a5aae9dea06de52deed7098a5b8443f26
INFO: Starting clean.
INFO: Output base moved to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069_tmp_43972_dd04d200-8af1-4382-ab99-14dae3ba270f for deletion
2023/09/05 08:52:47 Using unreleased version at commit 290fc80a5aae9dea06de52deed7098a5b8443f26
Starting local Bazel server and connecting to it...
WARNING: Download from https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.24.0/rules_python-0.24.0.tar.gz failed: class com.google.devtools.build.lib.bazel.repository.downloader.UnrecoverableHttpException Unknown host: company-artifactory.com
INFO: Repository rules_python~0.24.0 instantiated at:
  <builtin>: in <toplevel>
Repository rule http_archive defined at:
  /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/bazel_tools/tools/build_defs/repo/http.bzl:379:31: in <toplevel>
ERROR: An error occurred during the fetch of repository 'rules_python~0.24.0':
   Traceback (most recent call last):
        File "/home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/bazel_tools/tools/build_defs/repo/http.bzl", line 139, column 45, in _http_archive_impl
                download_info = ctx.download_and_extract(
Error in download_and_extract: java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.24.0/rules_python-0.24.0.tar.gz] to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/rules_python~0.24.0/temp1023504642766331791/rules_python-0.24.0.tar.gz: Unknown host: company-artifactory.com
ERROR: <builtin>: fetching http_archive rule //:rules_python~0.24.0: Traceback (most recent call last):
        File "/home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/bazel_tools/tools/build_defs/repo/http.bzl", line 139, column 45, in _http_archive_impl
                download_info = ctx.download_and_extract(
Error in download_and_extract: java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.24.0/rules_python-0.24.0.tar.gz] to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/rules_python~0.24.0/temp1023504642766331791/rules_python-0.24.0.tar.gz: Unknown host: company-artifactory.com
ERROR: no such package '@rules_python~0.24.0//python': java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.24.0/rules_python-0.24.0.tar.gz] to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/rules_python~0.24.0/temp1023504642766331791/rules_python-0.24.0.tar.gz: Unknown host: company-artifactory.com
Loading: 0 packages loaded
2023/09/05 08:52:53 Using unreleased version at commit 290fc80a5aae9dea06de52deed7098a5b8443f26
INFO: Starting clean.
INFO: Output base moved to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069_tmp_44088_c3f3bc2f-eb19-4b13-8c33-d7360e24d9d3 for deletion
Starting local Bazel server and connecting to it...
INFO: Repository rules_python instantiated at:
  /home/aignas/src/github/aignas/bazel_downloader_repro/WORKSPACE:3:13: in <toplevel>
Repository rule http_archive defined at:
  /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/bazel_tools/tools/build_defs/repo/http.bzl:372:31: in <toplevel>
WARNING: Download from https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.23.1/rules_python-0.23.1.tar.gz failed: class com.google.devtools.build.lib.bazel.repository.downloader.UnrecoverableHttpException Unknown host: company-artifactory.com
ERROR: An error occurred during the fetch of repository 'rules_python':
   Traceback (most recent call last):
        File "/home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/bazel_tools/tools/build_defs/repo/http.bzl", line 132, column 45, in _http_archive_impl
                download_info = ctx.download_and_extract(
Error in download_and_extract: java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.23.1/rules_python-0.23.1.tar.gz] to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/rules_python/temp10086934684153678415/rules_python-0.23.1.tar.gz: Unknown host: company-artifactory.com
ERROR: /home/aignas/src/github/aignas/bazel_downloader_repro/WORKSPACE:3:13: fetching http_archive rule //external:rules_python: Traceback (most recent call last):
        File "/home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/bazel_tools/tools/build_defs/repo/http.bzl", line 132, column 45, in _http_archive_impl
                download_info = ctx.download_and_extract(
Error in download_and_extract: java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.23.1/rules_python-0.23.1.tar.gz] to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/rules_python/temp10086934684153678415/rules_python-0.23.1.tar.gz: Unknown host: company-artifactory.com
ERROR: Error computing the main repository mapping: no such package '@rules_python//python': java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.23.1/rules_python-0.23.1.tar.gz] to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/rules_python/temp10086934684153678415/rules_python-0.23.1.tar.gz: Unknown host: company-artifactory.com
2023/09/05 08:52:57 Using unreleased version at commit 290fc80a5aae9dea06de52deed7098a5b8443f26
Starting local Bazel server and connecting to it...
INFO: Starting clean.
INFO: Output base moved to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069_tmp_44317_04fe98d7-d517-418e-af85-2891bbde028a for deletion
Starting local Bazel server and connecting to it...
INFO: Repository rules_python~0.24.0 instantiated at:
  callstack not available
Repository rule http_archive defined at:
  /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/bazel_tools/tools/build_defs/repo/http.bzl:372:31: in <toplevel>
WARNING: Download from https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.24.0/rules_python-0.24.0.tar.gz failed: class com.google.devtools.build.lib.bazel.repository.downloader.UnrecoverableHttpException Unknown host: company-artifactory.com
ERROR: An error occurred during the fetch of repository 'rules_python~0.24.0':
   Traceback (most recent call last):
        File "/home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/bazel_tools/tools/build_defs/repo/http.bzl", line 132, column 45, in _http_archive_impl
                download_info = ctx.download_and_extract(
Error in download_and_extract: java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.24.0/rules_python-0.24.0.tar.gz] to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/rules_python~0.24.0/temp10879110384093049814/rules_python-0.24.0.tar.gz: Unknown host: company-artifactory.com
ERROR: <builtin>: fetching http_archive rule //:rules_python~0.24.0: Traceback (most recent call last):
        File "/home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/bazel_tools/tools/build_defs/repo/http.bzl", line 132, column 45, in _http_archive_impl
                download_info = ctx.download_and_extract(
Error in download_and_extract: java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.24.0/rules_python-0.24.0.tar.gz] to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/rules_python~0.24.0/temp10879110384093049814/rules_python-0.24.0.tar.gz: Unknown host: company-artifactory.com
ERROR: no such package '@rules_python~0.24.0//python': java.io.IOException: Error downloading [https://company-artifactory.com/artifactory/github-releases/bazelbuild/rules_python/releases/download/0.24.0/rules_python-0.24.0.tar.gz] to /home/aignas/.cache/bazel/_bazel_aignas/8c44fc529c65d6d3fca6b30c30f2d069/external/rules_python~0.24.0/temp10879110384093049814/rules_python-0.24.0.tar.gz: Unknown host: company-artifactory.com
Loading: 0 packages loaded
```

### Mac

On Mac the `--experimental_downloader_config` has no effect when running under `bzlmod`.
