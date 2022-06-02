package main

import (
	"os"

	"github.com/cosmos-developer/baby/app"
	"github.com/cosmos-developer/baby/cmd/babyd/cmd"
	svrcmd "github.com/cosmos/cosmos-sdk/server/cmd"
	banktypes "github.com/cosmos/cosmos-sdk/x/bank/types"
	"github.com/ignite-hq/cli/ignite/pkg/cosmoscmd"
)

func main() {
	cmdOptions := GetCmdOptions()
	rootCmd, _ := cosmoscmd.NewRootCmd(
		app.Name,
		app.AccountAddressPrefix,
		app.DefaultNodeHome,
		app.Name,
		app.ModuleBasics,
		app.New,
		cmdOptions...,
	)

	if err := svrcmd.Execute(rootCmd, app.DefaultNodeHome); err != nil {
		os.Exit(1)
	}
}

func GetCmdOptions() []cosmoscmd.Option {
	var options []cosmoscmd.Option

	options = append(options,
		cosmoscmd.AddSubCmd(cmd.TestnetCmd(app.ModuleBasics, banktypes.GenesisBalancesIterator{})),
	)

	return options
}
