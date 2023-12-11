package keeper_test

import (
	"testing"

	"github.com/stretchr/testify/suite"

	apptesting "github.com/cosmos-developer/baby/app/testing"
)

type KeeperTestSuite struct {
	apptesting.KeeperTestHelper
}

func TestKeeperTestSuite(t *testing.T) {
	suite.Run(t, new(KeeperTestSuite))
}

func (suite *KeeperTestSuite) SetupTest() {
	suite.Setup(suite.T(), apptesting.SimAppChainID)
}

// go test -v -run ^TestKeeperTestSuite/PrintOutBalance$ github.com/cosmos-developer/baby/x/claim/keeper
// warning: must add "Test" to suite name
func (suite *KeeperTestSuite) TestPrintOutBalance() {
	suite.SetupTest()

	suite.App.ClaimKeeper.PrintOutBalance()
}
