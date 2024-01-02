all:
	go test ./...
	go mod tidy
	goimports -w .
	staticcheck --checks=all ./...
	go build -o ddzstd-native .
	GOARCH=amd64 GOOS=linux go build -o ddzstd-linux-amd64 .
	GOARCH=arm64 GOOS=linux go build -o ddzstd-linux-arm64 .
	GOARCH=amd64 GOOS=darwin go build -o ddzstd-darwin-amd64 .
	GOARCH=arm64 GOOS=darwin go build -o ddzstd-darwin-arm64 .

	bazelisk build //...
	bazelisk run //:ddzstdbazel

	# cross-compile with rules_go
	bazelisk run --platforms=@rules_go//go/toolchain:linux_amd64 //:ddzstdbazel

gazelle:
	buildozer 'use_repo_add @gazelle//:extensions.bzl go_deps com_github_datadog_zstd' //MODULE.bazel:all
	bazelisk run //:gazelle

# https://bazel.build/external/advanced#overriding-repositories
# This is probably outdated now due to bzlmod
local_override_test:
	bazelisk run --override_repository=io_bazel_rules_go=$(HOME)/rules_go //:ddzstdbazel

clean:
	$(RM) ddzstd-native ddzstd-linux-amd64 ddzstd-linux-arm64 ddzstd-darwin-amd64 ddzstd-darwin-arm64
