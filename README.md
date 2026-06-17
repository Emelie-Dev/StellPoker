# Stellar Poker

[![CI](https://github.com/HitEmPoka/StellPoker/actions/workflows/ci.yml/badge.svg)](https://github.com/HitEmPoka/StellPoker/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Onchain Texas Hold'em poker on Stellar with cryptographically private cards using ZK-MPC (coSNARKs).

No single party ever sees the full deck. A 3-node MPC committee (TACEO coNoir) shuffles and deals cards using REP3 secret sharing. UltraHonk ZK proofs verify every deal, reveal, and showdown onchain via Soroban's native BN254 host functions.

**[Live Demo](https://stell-poker.vercel.app)** · [Slide Deck](https://www.canva.com/design/DAHB5JrdEAk/XThK1QgbEATHwZ0rX-W2aA/view?utm_content=DAHB5JrdEAk&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=hb4aca74548)

![Gameplay](assets/game.png)

## Why ZK alone is not enough

ZK proofs can verify that a computation was done correctly, but they cannot keep inputs secret from the prover. In a card game, the entity generating the proof would necessarily know all cards. REP3 secret sharing across multiple MPC nodes ensures no single party — including the coordinator — ever holds the full deck. The slide deck above covers this in detail.

## Architecture

```
Player A          Player B
   |                  |
   +------+  +--------+
          |  |
       [Web App]              Next.js frontend
          |
       [Coordinator]          Orchestrates MPC sessions (Axum)
       /    |    \
   [Node0] [Node1] [Node2]    TACEO coNoir MPC nodes (REP3)
          |
       [Soroban]              Onchain settlement
    /      |        \
[PokerTable] [ZKVerifier] [CommitteeRegistry]
```

Supports up to 6 players. Includes a solo mode against a deterministic AI opponent.

## Key Properties

- **Private cards** — Cards exist only as REP3 secret shares across 3 MPC nodes. Privacy holds as long as at least 2 nodes are honest.
- **ZK-verified** — Deal, reveal, and showdown proofs are UltraHonk proofs verified onchain via Soroban's native BN254 host functions (Protocol 25).
- **Trustless settlement** — All bets, pot calculation, and payouts are handled entirely in Soroban smart contracts.
- **Reusable library** — `stellar-zk-cards` is a standalone Rust crate for card encoding and hand evaluation that any Soroban app can use.

## Contracts on Testnet

| Contract | Address |
|---|---|
| Poker Table | [CB7M3V3POQJR66425J3ILLHS3T4EUBRY67R7AVKSM255WBWOZG7XCYGL](https://stellar.expert/explorer/testnet/contract/CB7M3V3POQJR66425J3ILLHS3T4EUBRY67R7AVKSM255WBWOZG7XCYGL) |
| Committee Registry | [GBTYELEQ2YZH2W6SXLHT4AX6TYBHHU7LNNPKJV7J37VS3S5GPA75KRDU](https://stellar.expert/explorer/testnet/account/GBTYELEQ2YZH2W6SXLHT4AX6TYBHHU7LNNPKJV7J37VS3S5GPA75KRDU) |

Works alongside the Stellar Game Studio deployed at [CB4VZAT2U3UC6XFK3N23SKRF2NDCMP3QHJYMCHHFMZO7MRQO6DQ2EMYG](https://stellar.expert/explorer/testnet/contract/CB4VZAT2U3UC6XFK3N23SKRF2NDCMP3QHJYMCHHFMZO7MRQO6DQ2EMYG).

## Repository Structure

```
stellar-poker/
  contracts/
    poker-table/        Main game contract (betting, state machine, settlement)
    zk-verifier/        UltraHonk proof verification (BN254 native ops)
    committee-registry/ MPC committee management and slashing
    game-hub/           Mock Game Hub contract (Stellar Game Studio interface)
  circuits/
    lib/                Shared Noir library (cards, commitments, Merkle)
    deal_valid/         Proves deck shuffle + deal consistency
    reveal_board_valid/ Proves community card reveals match committed deck
    showdown_valid/     Proves winner has the best hand
  stellar-zk-cards/     Reusable card-game library crate (encoding, hand eval)
  services/
    coordinator/        Axum HTTP server orchestrating MPC sessions
    node/               MPC node (TACEO coNoir participant)
  app/                  Next.js web frontend
  tests/                Integration tests
  vendor/               Vendored UltraHonk verifier
  scripts/              Build, deploy, and test scripts
  docker-compose.yml    Full-stack local development
```

## Tech Stack

| Component | Technology |
|---|---|
| Smart contracts | Soroban (Rust, soroban-sdk 22.0.0) |
| ZK proofs | Noir circuits + UltraHonk (Barretenberg) |
| MPC | TACEO coNoir (REP3, 3-party) |
| Hash function | Poseidon2 |
| Frontend | Next.js 15, Freighter wallet |

## Prerequisites

- Rust (stable)
- Nargo 1.0.0-beta.17 — `noirup -v 1.0.0-beta.17`
- Node.js 18+
- Docker
- Stellar CLI — `cargo install stellar-cli --features opt`
- co-noir (for CRS download) — `cargo install --git https://github.com/TaceoLabs/co-snarks co-noir`

## Quick Start

```bash
# Install dependencies and verify build
./scripts/setup.sh

# Download BN254 common reference string
./scripts/download-crs.sh

# Start full stack
docker-compose up
```

Then open `http://localhost:3000`.

## Development

```bash
# Check all Rust crates
cargo check

# Run contract tests
cargo test -p poker-table

# Compile and test Noir circuits
./scripts/compile-circuits.sh
cd circuits/lib && nargo test

# Run the frontend
cd app && npm run dev

# Run integration tests (requires docker-compose up)
python3 scripts/test-flow.py
```

## Deploy to Testnet

```bash
NETWORK=testnet ./scripts/deploy.sh
```

## Game Flow

1. **Create table** — Admin creates a `PokerTable` contract with config (blinds, buy-in range, timeout).
2. **Join** — Players join with a buy-in (tokens escrowed in contract).
3. **Start hand** — Triggers the MPC committee to shuffle and deal.
4. **Deal** — Committee generates a `deal_valid` ZK proof, commits deck Merkle root + hand commitments onchain, privately delivers hole cards to each player.
5. **Betting** — Players submit actions (fold / check / call / bet / raise / all-in) to the contract.
6. **Reveal** — After each betting round, committee reveals community cards with a `reveal_board_valid` proof.
7. **Showdown** — Committee reveals remaining hands, generates a `showdown_valid` proof, contract settles the pot.

## Circuits

### `deal_valid`
- **Private**: `deck[52]`, `salts[52]` (secret-shared in MPC)
- **Public**: `deck_root`, `hand_commitments[6]`, `dealt_indices`
- **Proves**: Valid 52-card deck, Merkle root matches commitments, hand commitments match dealt cards.

### `reveal_board_valid`
- **Private**: `deck[52]`, `salts[52]`
- **Public**: `deck_root`, `revealed_cards`, `revealed_indices`, `previously_used_indices`
- **Proves**: Revealed cards match committed deck, no indices reused.

### `showdown_valid`
- **Private**: `hole_cards`, `board_cards`, `salts`
- **Public**: `hand_commitments`, `board_commitments`, `declared_winner`
- **Proves**: Cards match commitments, hand evaluation is correct, winner has best hand.

## License

[MIT](LICENSE)
