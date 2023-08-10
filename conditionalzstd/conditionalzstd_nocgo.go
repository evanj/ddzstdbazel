//go:build !cgo

package conditionalzstd

import "errors"

func UseZSTD(input []byte) ([]byte, error) {
	return nil, errors.New("zstd disabled: built without cgo")
}
