import { SigningStargateClient } from '@cosmjs/stargate';
import { DirectSecp256k1HdWallet, OfflineSigner } from '@cosmjs/proto-signing';
import { StdFee } from '@cosmjs/amino';
import { Coin } from 'cosmjs-types/cosmos/base/v1beta1/coin';
import { toBase64 } from '@cosmjs/encoding';
import { TxRaw } from 'cosmjs-types/cosmos/tx/v1beta1/tx'
import axios from 'axios';

const MNEMONIC="permit omit share float blind matrix soldier trust light author fly side lend you what happy multiply monster yard have similar outdoor other drama"
const TO_ADDRESS="baby1wtdp8e3935mptdmd8ydq9n2qxxtdj4ut8gye5v"

const network = {
    provider: "http://localhost:2281",
    api: 'http://localhost:1310',
    bech32Prefix: "baby",
    nativeDenom: "ubaby",
    defaultTxFee: 100,
    defaultGas: 200000,
};

function getDefaultStdFee(): StdFee {
    return {
        amount: [
            {
              amount: network.defaultTxFee.toString(),
              denom: network.nativeDenom,
            },
        ],
        gas: network.defaultGas.toString(),
    }
}

async function getSigningClient(signer: OfflineSigner): Promise<SigningStargateClient> {
    return await SigningStargateClient.connectWithSigner(network.provider, signer, {prefix: network.bech32Prefix})
}

async function sendTransaction ({ to, amount, mnemonic} : {to: string, amount: number, mnemonic: string}): Promise<any> {
    const signer = await DirectSecp256k1HdWallet.fromMnemonic(mnemonic, {prefix: network.bech32Prefix})
    const signingClient = await getSigningClient(signer)

    const accs = await signer.getAccounts()

    const sendAmt: Coin[] = [{ denom: network.nativeDenom, amount: amount.toString() }]

    const fee = getDefaultStdFee()

    // create tx_bytes
    let msgs = [
        {
            typeUrl: '/cosmos.bank.v1beta1.MsgSend',
            value: {
                fromAddress: accs[0].address,
                toAddress: to,
                amount: sendAmt,
            },
        },
    ]
    let bodyBytes = await signingClient.sign(accs[0].address, msgs, fee, "")

    let payload = {
        tx_bytes: toBase64(TxRaw.encode(bodyBytes).finish()),
        mode: 'BROADCAST_MODE_SYNC'
    }

    let res = await axios.post(network.api + '/cosmos/tx/v1beta1/txs', payload);

    return res.data
}

(async () => {
    try {
        let res = await sendTransaction({
            to: TO_ADDRESS,
            amount: 1000000,
            mnemonic: MNEMONIC
        })

        console.log(res)
    } catch(e) {
        console.log(e)
    }
})();