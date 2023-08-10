//go:build cgo

// Package conditionalzstd conditionally compiles a reference to github.com/DataDog/zstd if Cgo
// is enabled.
package conditionalzstd

import "github.com/DataDog/zstd"

func UseZSTD(input []byte) ([]byte, error) {
	return zstd.Decompress(nil, input)
}
