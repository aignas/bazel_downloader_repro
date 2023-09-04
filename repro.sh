#!/bin/bash
set -euxo pipefail
cat README.md |
    grep '^\$' |
    sed "s/\$ //g" |
    grep -v "bazel info" |
    grep -v "uname -a" |
    grep -v "repro.sh" |
    xargs -I{} bash -c "{}"
