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

Currently as of `rules_go` commit 57ef719d617dbf9a139190452705f62592818c06 on `Wed Aug 9 14:21:27 2023`:

```
ERROR: external/com_github_datadog_zstd/BUILD.bazel:3:11: GoCompilePkg external/com_github_datadog_zstd/zstd.a failed: (Exit 1): builder failed: error executing command (from target @com_github_datadog_zstd//:zstd) bazel-out/k8-opt-exec-2B5CBBC6/bin/external/go_sdk/builder_reset/builder compilepkg -sdk external/go_sdk -installsuffix linux_amd64 -src external/com_github_datadog_zstd/errors.go -src ... (remaining 215 arguments skipped)

Use --sandbox_debug to see verbose messages from the sandbox and retain the sandbox build root for debugging
/tmp/rules_go_work-3697279274/cgo/github.com/DataDog/zstd/_x16.o:huf_decompress.c:function HUF_decompress4X1_usingDTable_internal: error: undefined reference to 'HUF_decompress4X1_usingDTable_internal_fast_asm_loop'
/tmp/rules_go_work-3697279274/cgo/github.com/DataDog/zstd/_x16.o:huf_decompress.c:function HUF_decompress4X2_usingDTable_internal: error: undefined reference to 'HUF_decompress4X2_usingDTable_internal_fast_asm_loop'
collect2: error: ld returned 1 exit status
compilepkg: error running subcommand /usr/bin/gcc: exit status 1
```
