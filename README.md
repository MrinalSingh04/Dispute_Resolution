# 🧑‍⚖️ Dispute Resolution with Community Voting

A decentralized smart contract system for resolving disputes fairly and trustlessly using community voting.

## 💡 What is it?

This smart contract enables two parties to enter into an escrow deal. If a disagreement arises, a community of registered jurors vote to decide who receives the locked funds.

Juror votes are used to settle disputes in a transparent, decentralized manner — without needing a central authority.

---

## 🎯 Why build this?

- ✅ Trustless deal settlements for freelancing, marketplaces, or peer-to-peer services.
- ✅ Reduces reliance on centralized mediation (e.g. PayPal disputes or court).
- ✅ Empowers the community to handle conflicts with transparent resolution.
- ✅ Jurors can earn a reputation or incentive in future versions.

---

## ⚙️ Features

- Party A creates a deal with Party B by locking funds.
- Either party can start a dispute.
- Smart contract randomly selects 3 jurors from a pool.
- Jurors vote for Party A or Party B.
- Majority vote decides the winner.
- Funds are sent to the winning party.

---

## 🛠️ Tech Stack

- **Solidity v0.8.24+**
- **Hardhat** for local development/testing
- **JavaScript** (for deployment scripts/tests)

---

## 🧪 Functions Overview

| Function            | Description                          |
| ------------------- | ------------------------------------ |
| `createDeal()`      | Start a deal by depositing ETH       |
| `registerAsJuror()` | Join the juror pool                  |
| `startDispute()`    | Trigger a dispute and select jurors  |
| `vote()`            | Jurors vote on the dispute outcome   |
| `resolveDispute()`  | Automatically resolves once all vote |
| `getDeal()`         | View details of a specific deal      |
| `getVote()`         | View juror's vote                    |

---

## 🚀 How to Run Locally

```bash
git clone https://github.com/yourusername/dispute-resolution-contract.git
cd dispute-resolution-contract
npm install
npx hardhat compile
npx hardhat test
```

## 📄 License

MIT License
