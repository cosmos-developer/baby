package keeper_test

import (
	"testing"

	"github.com/stretchr/testify/require"
	testkeeper "github.com/cosmos-developer/baby/testutil/keeper"
	"github.com/cosmos-developer/baby/x/template/types"
)

func TestGetParams(t *testing.T) {
	k, ctx := testkeeper.TemplateKeeper(t)
	params := types.DefaultParams()

	k.SetParams(ctx, params)

	require.EqualValues(t, params, k.GetParams(ctx))
}
