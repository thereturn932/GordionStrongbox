# Gordion Strongbox

GordionStrongbox is basic multisig wallet aimed to work on EVM compatible chains. Main chain to run GordionStrongbox is **Avalanche chain**.

## Install

---

```shell
git clone https://github.com/thereturn932/GordionStrongbox.git
npm install
```

then create `.env` file to the root directory of project and write following variables inside

```shell
FUJI= "YOUR TESTNET RPC NODE"
CCHAIN= "YOUR MAINNET RPC NODE"
PRIV_KEY= "YOUR PRIVATE KEY"
```

## Deploy

---

To deploy on testnet
```shell
npx hardhat run --network testnet scripts/deploy.js
```

To deploy on mainnet
```shell
npx hardhat run --network mainnet scripts/deploy.js
```

## Error Codes

---

### 0x00
Pass rate is over 100.

### 0x01
Address list in constructor is empty