package keeper

import (
	"context"

	"github.com/cosmos-developer/baby/x/template/types"
)

type msgServer struct {
	Keeper
}

// NewMsgServerImpl returns an implementation of the MsgServer interface
// for the provided Keeper.
func NewMsgServerImpl(keeper Keeper) types.MsgServer {
	return &msgServer{Keeper: keeper}
}

var _ types.MsgServer = msgServer{}

func (server msgServer) Template(goCtx context.Context, msg *types.MsgTemplateRequest) (*types.MsgTemplateResponse, error) {
	return &types.MsgTemplateResponse{}, nil
}
