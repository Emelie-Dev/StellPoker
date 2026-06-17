# Contributing to Stellar Poker

Thank you for your interest in contributing. This document explains how to get started.

## Development Setup

```bash
./scripts/setup.sh
```

See the [README](README.md) for full prerequisites.

## Project Structure

| Directory | Description |
|---|---|
| `contracts/` | Soroban smart contracts (Rust) |
| `circuits/` | Noir ZK circuits |
| `stellar-zk-cards/` | Reusable card-game library crate |
| `services/coordinator/` | MPC session orchestrator (Axum) |
| `services/node/` | MPC node (TACEO coNoir participant) |
| `app/` | Next.js frontend |
| `scripts/` | Build, deploy, and test scripts |

## Workflow

1. Fork the repository and create a branch from `main`.
2. Make your changes. Run the relevant tests before opening a PR.
3. Open a pull request with a clear description of what changed and why.

## Running Tests

**Soroban contracts:**
```bash
cargo test -p poker-table
```

**Noir circuits:**
```bash
cd circuits/lib && nargo test
```

**Integration tests:**
```bash
./scripts/test-flow.py
```

**Frontend:**
```bash
cd app && npm test
```

## Code Style

- Rust: `cargo fmt` and `cargo clippy --all-targets`
- TypeScript: the project uses ESLint (`cd app && npm run lint`)
- Noir: follow the existing module structure in `circuits/lib/`

## Reporting Issues

Open a GitHub issue with steps to reproduce, expected behaviour, and actual behaviour.

## License

By contributing you agree that your contributions will be licensed under the [MIT License](LICENSE).
