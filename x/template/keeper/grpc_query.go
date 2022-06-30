package keeper

import (
	"github.com/cosmos-developer/baby/x/template/types"
)

var _ types.QueryServer = Keeper{}
