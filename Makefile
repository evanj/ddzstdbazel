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
	bazelisk run //:gazelle -- update-repos -from_file=go.mod
	bazelisk run //:gazelle
	bazelisk build //...

	bazelisk run //:ddzstdbazel
	bazelisk run --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64 //:ddzstdbazel

# https://bazel.build/external/advanced#overriding-repositories
local_override_test:
	bazelisk run --override_repository=io_bazel_rules_go=$(HOME)/rules_go //:ddzstdbazel
	bazelisk run --override_repository=io_bazel_rules_go=$(HOME)/rules_go --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64 //:ddzstdbazel

clean:
	$(RM) ddzstd-native ddzstd-linux-amd64 ddzstd-linux-arm64 ddzstd-darwin-amd64 ddzstd-darwin-arm64
