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

### 0x02
One of the requested owners is zero address

### 0x03
Message sender is not owner

### 0x04
Message sender is already confirmed the payment

### 0x05
Payment reciever can not be 0x0 address

### 0x06
Payment is already not accepted by message sender

### 0x07
Payment order does not have enough confirmations

### 0x08
Failed to send AVAX

### 0x09
Order is already executed

### 0x10
Message sender is already confirmed

### 0x11
Not enough confirmations

### 0x12
Request is already not accepted by message sender

### 0x13
Address is already one of the owners

### 0x14
Requested liquidity amount to remove is above current liquidity amount in the wallet

### 0x15
Allovance is lower than the value requested