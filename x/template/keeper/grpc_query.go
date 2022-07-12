package keeper

import (
	"context"

	"github.com/cosmos-developer/baby/x/template/types"
)

var _ types.QueryServer = Querier{}

type Querier struct {
	Keeper Keeper
}

func NewQuerier(k Keeper) Querier {
	return Querier{Keeper: k}
}

func (q Querier) Template(goCtx context.Context, req *types.QueryTemplateRequest) (*types.QueryTemplateResponse, error) {
	return &types.QueryTemplateResponse{}, nil
}
