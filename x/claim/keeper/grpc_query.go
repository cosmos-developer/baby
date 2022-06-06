package keeper

import (
	"github.com/cosmos-developer/baby/x/claim/types"
)

var _ types.QueryServer = Keeper{}
