package testing

import (
	"encoding/json"
	"testing"
	"time"

	"github.com/cosmos-developer/baby/app"
	appparams "github.com/cosmos-developer/baby/app/params"
	"github.com/cosmos/cosmos-sdk/baseapp"
	codectypes "github.com/cosmos/cosmos-sdk/codec/types"
	cryptocodec "github.com/cosmos/cosmos-sdk/crypto/codec"
	"github.com/cosmos/cosmos-sdk/crypto/keys/ed25519"
	"github.com/cosmos/cosmos-sdk/crypto/keys/secp256k1"
	"github.com/cosmos/cosmos-sdk/simapp"
	"github.com/cosmos/cosmos-sdk/testutil/testdata"
	sdk "github.com/cosmos/cosmos-sdk/types"
	authtypes "github.com/cosmos/cosmos-sdk/x/auth/types"
	banktypes "github.com/cosmos/cosmos-sdk/x/bank/types"
	stakingtypes "github.com/cosmos/cosmos-sdk/x/staking/types"

	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"

	abci "github.com/tendermint/tendermint/abci/types"
	"github.com/tendermint/tendermint/libs/log"
	tmproto "github.com/tendermint/tendermint/proto/tendermint/types"
	tmtypes "github.com/tendermint/tendermint/types"
	dbm "github.com/tendermint/tm-db"
)

// SimAppChainID hardcoded chainID for simulation
const (
	SimAppChainID = "babytesnet"
)

// DefaultConsensusParams defines the default Tendermint consensus params used
// in app testing.
var DefaultConsensusParams = &abci.ConsensusParams{
	Block: &abci.BlockParams{
		MaxBytes: 200000,
		MaxGas:   2000000,
	},
	Evidence: &tmproto.EvidenceParams{
		MaxAgeNumBlocks: 302400,
		MaxAgeDuration:  504 * time.Hour, // 3 weeks is the max duration
		MaxBytes:        10000,
	},
	Validator: &tmproto.ValidatorParams{
		PubKeyTypes: []string{
			tmtypes.ABCIPubKeyTypeEd25519,
		},
	},
}

// KeeperTestHelper provides all general features needed to test a keeper logic.
// Most chain would have KeeperTestHelper structure
type KeeperTestHelper struct {
	suite.Suite

	App         *app.App
	Ctx         sdk.Context // ctx is deliver ctx
	CheckCtx    sdk.Context
	QueryHelper *baseapp.QueryServiceTestHelper
	TestAccs    []sdk.AccAddress
}

func (s *KeeperTestHelper) Setup(_ *testing.T, chainID string) {
	s.App = SetupApp(s.T())
	s.Ctx = s.App.BaseApp.NewContext(false, tmproto.Header{Height: 1, ChainID: chainID, Time: time.Now().UTC()})
	s.CheckCtx = s.App.BaseApp.NewContext(true, tmproto.Header{Height: 1, ChainID: chainID, Time: time.Now().UTC()})
	s.QueryHelper = &baseapp.QueryServiceTestHelper{
		GRPCQueryRouter: s.App.GRPCQueryRouter(),
		Ctx:             s.Ctx,
	}

	s.TestAccs = s.RandomAccountAddresses(3)
}

func SetupApp(t *testing.T) *app.App {
	t.Helper()

	privVal := ed25519.GenPrivKey()
	pubKey, err := cryptocodec.ToTmPubKeyInterface(privVal.PubKey())
	require.NoError(t, err)
	// create validator set with single validator
	validator := tmtypes.NewValidator(pubKey, 1)
	valSet := tmtypes.NewValidatorSet([]*tmtypes.Validator{validator})

	// generate genesis account
	senderPrivKey := secp256k1.GenPrivKey()
	acc := authtypes.NewBaseAccount(senderPrivKey.PubKey().Address().Bytes(), senderPrivKey.PubKey(), 0, 0)
	balance := banktypes.Balance{
		Address: acc.GetAddress().String(),
		Coins:   sdk.NewCoins(sdk.NewCoin(appparams.DefaultBondDenom, sdk.NewInt(100000000000000))),
	}

	app := SetupWithGenesisValSet(t, valSet, []authtypes.GenesisAccount{acc}, balance)

	return app
}

// SetupWithGenesisValSet initializes a new app with a validator set and genesis accounts
// that also act as delegators. For simplicity, each validator is bonded with a delegation
// of one consensus engine unit in the default token of the app from first genesis
// account. A Nop logger is set in app.
func SetupWithGenesisValSet(t *testing.T, valSet *tmtypes.ValidatorSet, genAccs []authtypes.GenesisAccount, balances ...banktypes.Balance) *app.App {
	t.Helper()

	terraApp, genesisState := setup(true, 5)
	genesisState = genesisStateWithValSet(t, terraApp, genesisState, valSet, genAccs, balances...)

	stateBytes, err := json.MarshalIndent(genesisState, "", " ")
	require.NoError(t, err)

	// init chain will set the validator set and initialize the genesis accounts
	terraApp.InitChain(
		abci.RequestInitChain{
			ChainId:         SimAppChainID,
			Validators:      []abci.ValidatorUpdate{},
			ConsensusParams: DefaultConsensusParams,
			AppStateBytes:   stateBytes,
		},
	)

	// commit genesis changes
	terraApp.Commit()
	terraApp.BeginBlock(abci.RequestBeginBlock{Header: tmproto.Header{
		ChainID:            SimAppChainID,
		Height:             terraApp.LastBlockHeight() + 1,
		AppHash:            terraApp.LastCommitID().Hash,
		ValidatorsHash:     valSet.Hash(),
		NextValidatorsHash: valSet.Hash(),
	}})

	return terraApp
}

func setup(withGenesis bool, invCheckPeriod uint) (*app.App, app.GenesisState) {
	db := dbm.NewMemDB()
	encCdc := appparams.MakeEncodingConfig()

	newApp := app.New(
		log.NewNopLogger(),
		db,
		nil,
		true,
		map[int64]bool{},
		app.DefaultNodeHome,
		invCheckPeriod,
		encCdc,
		simapp.EmptyAppOptions{},
	)
	if withGenesis {
		return newApp, app.NewDefaultGenesisState()
	}

	return newApp, app.GenesisState{}
}

func genesisStateWithValSet(t *testing.T,
	app *app.App, genesisState app.GenesisState,
	valSet *tmtypes.ValidatorSet, genAccs []authtypes.GenesisAccount,
	balances ...banktypes.Balance,
) app.GenesisState {
	// set genesis accounts
	authGenesis := authtypes.NewGenesisState(authtypes.DefaultParams(), genAccs)
	genesisState[authtypes.ModuleName] = app.AppCodec().MustMarshalJSON(authGenesis)

	validators := make([]stakingtypes.Validator, 0, len(valSet.Validators))
	delegations := make([]stakingtypes.Delegation, 0, len(valSet.Validators))

	bondAmt := sdk.DefaultPowerReduction

	for _, val := range valSet.Validators {
		pk, err := cryptocodec.FromTmPubKeyInterface(val.PubKey)
		require.NoError(t, err)
		pkAny, err := codectypes.NewAnyWithValue(pk)
		require.NoError(t, err)
		validator := stakingtypes.Validator{
			OperatorAddress:   sdk.ValAddress(val.Address).String(),
			ConsensusPubkey:   pkAny,
			Jailed:            false,
			Status:            stakingtypes.Bonded,
			Tokens:            bondAmt,
			DelegatorShares:   sdk.OneDec(),
			Description:       stakingtypes.Description{},
			UnbondingHeight:   int64(0),
			UnbondingTime:     time.Unix(0, 0).UTC(),
			Commission:        stakingtypes.NewCommission(sdk.ZeroDec(), sdk.ZeroDec(), sdk.ZeroDec()),
			MinSelfDelegation: sdk.ZeroInt(),
		}
		validators = append(validators, validator)
		delegations = append(delegations, stakingtypes.NewDelegation(genAccs[0].GetAddress(), val.Address.Bytes(), sdk.OneDec()))

	}
	// set validators and delegations
	defaultStParams := stakingtypes.DefaultParams()
	stParams := stakingtypes.NewParams(
		defaultStParams.UnbondingTime,
		defaultStParams.MaxValidators,
		defaultStParams.MaxEntries,
		defaultStParams.HistoricalEntries,
		appparams.DefaultBondDenom,
	)

	// set validators and delegations
	stakingGenesis := stakingtypes.NewGenesisState(stParams, validators, delegations)
	genesisState[stakingtypes.ModuleName] = app.AppCodec().MustMarshalJSON(stakingGenesis)

	totalSupply := sdk.NewCoins()
	for _, b := range balances {
		// add genesis acc tokens to total supply
		totalSupply = totalSupply.Add(b.Coins...)
	}

	for range delegations {
		// add delegated tokens to total supply
		totalSupply = totalSupply.Add(sdk.NewCoin(appparams.DefaultBondDenom, bondAmt))
	}

	// add bonded amount to bonded pool module account
	balances = append(balances, banktypes.Balance{
		Address: authtypes.NewModuleAddress(stakingtypes.BondedPoolName).String(),
		Coins:   sdk.Coins{sdk.NewCoin(appparams.DefaultBondDenom, bondAmt)},
	})

	// update total supply
	bankGenesis := banktypes.NewGenesisState(
		banktypes.DefaultGenesisState().Params,
		balances,
		totalSupply,
		[]banktypes.Metadata{},
	)

	genesisState[banktypes.ModuleName] = app.AppCodec().MustMarshalJSON(bankGenesis)

	return genesisState
}

func (s *KeeperTestHelper) RandomAccountAddresses(n int) []sdk.AccAddress {
	addrsList := make([]sdk.AccAddress, n)
	for i := 0; i < n; i++ {
		_, _, addrs := testdata.KeyTestPubAddr()
		addrsList[i] = addrs
	}
	return addrsList
}
