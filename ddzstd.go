package main

import (
	"encoding/base64"
	"fmt"

	"github.com/evanj/ddzstdbazel/conditionalzstd"
)

func main() {
	// generated with: echo "hello hello hello zstd" | zstd | base64
	const inBase64 = "KLUv/QRYjQAAWGhlbGxvIHpzdGQKAQDhShE6BCTR"
	in, err := base64.StdEncoding.DecodeString(inBase64)
	if err != nil {
		panic(err)
	}
	out, err := conditionalzstd.UseZSTD(in)
	if err != nil {
		fmt.Printf("ERROR: conditionalzstd.UseZSTD()=%s\n", err.Error())
	} else {
		fmt.Printf("out=%#v\n", string(out))
	}
}
