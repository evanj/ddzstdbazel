# DataDog/zstd demo with Bazel

Example of using `github.com/DataDog/zstd` with Go and Bazel.

* normal `go build``: will use Cgo by default and link DataDog/zstd
* `CGO_ENABLED=0 go build`: does not use Cgo; does not link DataDog/zstd
* normal cross-compile using `GOOS` or `GOARCH`: disabled Cgo

`Makefile`: Contains some useful "scripts"; all tries to test everything.

## Expected output with native go

```
~/ddzstdbazel $ go run .
out="hello hello hello zstd\n"
~/ddzstdbazel $ CGO_ENABLED=0 go run .
ERROR: conditionalzstd.UseZSTD()=zstd disabled: built without cgo
```

## Output with Bazel

Previously `rules_go` had some bugs related to Cgo assembly that prevented this from working correctly. As of commit `2e821f66bb9fe1e16ea42743d30936248c1fa11a` on 2023-08-20, it should be working correctly. That is:

* Normal build: `bazelisk run //:ddzstdbazel`: Builds and links zstd Cgo correctly.
* Cross-compile build: `bazelisk run --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64 //:ddzstdbazel`: Builds without Cgo.

The previous error for native builds was the following, and was fixed with [my pull request](https://github.com/bazelbuild/rules_go/pull/3648):

```
ERROR: external/com_github_datadog_zstd/BUILD.bazel:3:11: GoCompilePkg external/com_github_datadog_zstd/zstd.a failed: (Exit 1): builder failed: error executing command (from target @com_github_datadog_zstd//:zstd) bazel-out/k8-opt-exec-2B5CBBC6/bin/external/go_sdk/builder_reset/builder compilepkg -sdk external/go_sdk -installsuffix linux_amd64 -src external/com_github_datadog_zstd/errors.go -src ... (remaining 215 arguments skipped)

Use --sandbox_debug to see verbose messages from the sandbox and retain the sandbox build root for debugging
/tmp/rules_go_work-3697279274/cgo/github.com/DataDog/zstd/_x16.o:huf_decompress.c:function HUF_decompress4X1_usingDTable_internal: error: undefined reference to 'HUF_decompress4X1_usingDTable_internal_fast_asm_loop'
/tmp/rules_go_work-3697279274/cgo/github.com/DataDog/zstd/_x16.o:huf_decompress.c:function HUF_decompress4X2_usingDTable_internal: error: undefined reference to 'HUF_decompress4X2_usingDTable_internal_fast_asm_loop'
collect2: error: ld returned 1 exit status
compilepkg: error running subcommand /usr/bin/gcc: exit status 1
```

After that, a cross-compile did not work, which was fixed with [another pull request](https://github.com/bazelbuild/rules_go/pull/3661):

```
$ bazelisk run --override_repository=io_bazel_rules_go=$HOME/rules_go --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64 //:ddzstdbazel
INFO: Analyzed target //:ddzstdbazel (0 packages loaded, 0 targets configured).
INFO: Found 1 target...
ERROR: /home/ej/.cache/bazel/_bazel_ej/52d15eac7376e1e0d1ea71c590f7efe9/external/com_github_datadog_zstd/BUILD.bazel:3:11: GoCompilePkg external/com_github_datadog_zstd/zstd.a failed: (Exit 1): builder failed: error executing command (from target @com_github_datadog_zstd//:zstd) bazel-out/k8-opt-exec-2B5CBBC6/bin/external/go_sdk/builder_reset/builder compilepkg -sdk external/go_sdk -installsuffix linux_amd64 -src external/com_github_datadog_zstd/errors.go -src ... (remaining 203 arguments skipped)

Use --sandbox_debug to see verbose messages from the sandbox and retain the sandbox build root for debugging
portability_macros.h:42: unexpected token after '#': if
compilepkg: error running subcommand external/go_sdk/pkg/tool/linux_amd64/asm: exit status 1
Target //:ddzstdbazel failed to build
```
