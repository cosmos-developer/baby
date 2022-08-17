package types

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
)

var _ sdk.Msg = &MsgTemplateRequest{}

// msg types
const (
	TypeMsgCreateProjectRequest = "create_project"
)

func NewMsgCreateProjectRequest(signer string) *MsgTemplateRequest {
	return &MsgTemplateRequest{
		Signer: signer,
	}
}

func (msg *MsgTemplateRequest) Route() string {
	return RouterKey
}

func (msg *MsgTemplateRequest) Type() string {
	return TypeMsgCreateProjectRequest
}

func (msg *MsgTemplateRequest) GetSigners() []sdk.AccAddress {
	sender, err := sdk.AccAddressFromBech32(msg.Signer)
	if err != nil {
		panic(err)
	}
	return []sdk.AccAddress{sender}
}

func (msg *MsgTemplateRequest) GetSignBytes() []byte {
	bz := ModuleCdc.MustMarshalJSON(msg)
	return sdk.MustSortJSON(bz)
}

func (msg *MsgTemplateRequest) ValidateBasic() error {
	_, err := sdk.AccAddressFromBech32(msg.Signer)
	if err != nil {
		return sdkerrors.Wrapf(sdkerrors.ErrInvalidAddress, "invalid sender address (%s)", err)
	}
	return nil
}
