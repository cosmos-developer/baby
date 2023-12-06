package main

import (
	"os"

	"github.com/cosmos-developer/baby/app"
	"github.com/cosmos-developer/baby/cmd/babyd/cmd"
	svrcmd "github.com/cosmos/cosmos-sdk/server/cmd"
)

func main() {
	rootCmd, _ := cmd.NewRootCmd()

	if err := svrcmd.Execute(rootCmd, app.DefaultNodeHome); err != nil {
		os.Exit(1)
	}
}
