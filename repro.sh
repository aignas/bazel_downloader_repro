#!/bin/bash
set -euxo pipefail
cat README.md |
    grep '^\$' |
    sed "s/\$ //g" |
    grep -v "bazel info" |
    grep -v "uname -a" |
    xargs -I{} -L1 bash -c "{}"
