package keeper_test

import (
	"context"
	"testing"

	keepertest "github.com/cosmos-developer/baby/testutil/keeper"
	"github.com/cosmos-developer/baby/x/claim/keeper"
	"github.com/cosmos-developer/baby/x/claim/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
)

func setupMsgServer(t testing.TB) (types.MsgServer, context.Context) {
	k, ctx := keepertest.ClaimKeeper(t)
	return keeper.NewMsgServerImpl(*k), sdk.WrapSDKContext(ctx)
}
