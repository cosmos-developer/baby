package template_test

import (
	"testing"

	keepertest "github.com/cosmos-developer/baby/testutil/keeper"
	"github.com/cosmos-developer/baby/testutil/nullify"
	"github.com/cosmos-developer/baby/x/template"
	"github.com/cosmos-developer/baby/x/template/types"
	"github.com/stretchr/testify/require"
)

func TestGenesis(t *testing.T) {
	genesisState := types.GenesisState{
		Params:	types.DefaultParams(),
		
		// this line is used by starport scaffolding # genesis/test/state
	}

	k, ctx := keepertest.TemplateKeeper(t)
	template.InitGenesis(ctx, *k, genesisState)
	got := template.ExportGenesis(ctx, *k)
	require.NotNil(t, got)

	nullify.Fill(&genesisState)
	nullify.Fill(got)

	

	// this line is used by starport scaffolding # genesis/test/assert
}
