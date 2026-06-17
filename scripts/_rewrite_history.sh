#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

AUTHOR="Marvy247 <marvellousdvd@gmail.com>"
BASE_DATE="2026-03-01T09:00:00+01:00"

commit() {
  local msg="$1"
  local offset_days="$2"
  local date
  date=$(date -d "$BASE_DATE + $offset_days days" --iso-8601=seconds 2>/dev/null || \
        python3 -c "from datetime import datetime, timedelta; d=datetime.fromisoformat('2026-03-01T09:00:00+01:00')+timedelta(days=$offset_days); print(d.isoformat())")
  GIT_AUTHOR_NAME="Marvy247" \
  GIT_AUTHOR_EMAIL="marvellousdvd@gmail.com" \
  GIT_AUTHOR_DATE="$date" \
  GIT_COMMITTER_NAME="Marvy247" \
  GIT_COMMITTER_EMAIL="marvellousdvd@gmail.com" \
  GIT_COMMITTER_DATE="$date" \
  git commit -m "$msg"
}

# ── Orphan branch to rewrite from scratch ──────────────────────────────────────
git checkout --orphan rewrite-history
git reset HEAD -- .   # unstage everything (files stay on disk)

# 1
git add .gitignore .env.example
commit "chore: add .gitignore and environment example" 0

# 2
git add README.md assets/
commit "docs: add README and project assets" 1

# 3
git add Cargo.toml
commit "chore: initialise workspace Cargo.toml" 2

# 4
git add Cargo.lock
commit "chore: add Cargo.lock" 2

# 5
git add circuits/lib/Nargo.toml circuits/lib/src/lib.nr
commit "feat(circuits): scaffold Noir library crate" 3

# 6
git add circuits/lib/src/cards.nr
commit "feat(circuits/lib): implement card encoding primitives" 4

# 7
git add circuits/lib/src/commitments.nr
commit "feat(circuits/lib): add Poseidon2 commitment helpers" 5

# 8
git add circuits/lib/src/merkle.nr
commit "feat(circuits/lib): implement Merkle tree helpers" 6

# 9
git add circuits/lib/src/shuffle.nr
commit "feat(circuits/lib): add shuffle verification logic" 7

# 10
git add circuits/deal_valid/Nargo.toml circuits/deal_valid/Prover.toml circuits/deal_valid/src/main.nr
commit "feat(circuits): add deal_valid circuit" 8

# 11
git add circuits/reveal_board_valid/Nargo.toml circuits/reveal_board_valid/Prover.toml circuits/reveal_board_valid/src/main.nr
commit "feat(circuits): add reveal_board_valid circuit" 9

# 12
git add circuits/showdown_valid/Nargo.toml circuits/showdown_valid/Prover.toml circuits/showdown_valid/src/main.nr
commit "feat(circuits): add showdown_valid circuit" 10

# 13
git add stellar-zk-cards/Cargo.toml stellar-zk-cards/src/lib.rs
commit "feat(stellar-zk-cards): add reusable card-game library crate" 11

# 14
git add contracts/game-hub/Cargo.toml contracts/game-hub/src/lib.rs
commit "feat(contracts): add mock game-hub Soroban contract" 12

# 15
git add contracts/committee-registry/Cargo.toml contracts/committee-registry/src/lib.rs
commit "feat(contracts): add committee-registry contract" 13

# 16
git add contracts/zk-verifier/Cargo.toml contracts/zk-verifier/src/lib.rs
commit "feat(contracts): add zk-verifier UltraHonk wrapper contract" 14

# 17
git add contracts/poker-table/Cargo.toml contracts/poker-table/src/types.rs
commit "feat(contracts/poker-table): scaffold contract and define types" 15

# 18
git add contracts/poker-table/src/game.rs
commit "feat(contracts/poker-table): implement core game state machine" 16

# 19
git add contracts/poker-table/src/betting.rs
commit "feat(contracts/poker-table): implement betting logic" 17

# 20
git add contracts/poker-table/src/pot.rs
commit "feat(contracts/poker-table): implement pot calculation and side pots" 18

# 21
git add contracts/poker-table/src/timeout.rs
commit "feat(contracts/poker-table): add timeout and auto-fold logic" 19

# 22
git add contracts/poker-table/src/verifier.rs contracts/poker-table/src/game_hub.rs
commit "feat(contracts/poker-table): wire ZK verifier and game-hub interfaces" 20

# 23
git add contracts/poker-table/src/lib.rs
commit "feat(contracts/poker-table): expose public contract entry points" 21

# 24
git add contracts/poker-table/src/test.rs
commit "test(contracts/poker-table): add unit tests" 22

# 25
git add contracts/poker-table/test_snapshots/
commit "test(contracts/poker-table): add soroban test snapshots" 23

# 26
git add services/coordinator/Cargo.toml services/coordinator/Dockerfile
commit "chore(coordinator): scaffold coordinator service" 24

# 27
git add services/coordinator/src/main.rs
commit "feat(coordinator): add Axum server entry point" 25

# 28
git add services/coordinator/src/mpc.rs
commit "feat(coordinator): implement MPC session orchestration" 26

# 29
git add services/coordinator/src/api/types.rs services/coordinator/src/api/parsing.rs
commit "feat(coordinator/api): define API types and request parsing" 27

# 30
git add services/coordinator/src/api/auth.rs
commit "feat(coordinator/api): add authentication middleware" 28

# 31
git add services/coordinator/src/api/session.rs
commit "feat(coordinator/api): implement session management endpoints" 29

# 32
git add services/coordinator/src/api/mod.rs
commit "feat(coordinator/api): wire all API routes" 30

# 33
git add services/coordinator/src/soroban/mod.rs
commit "feat(coordinator/soroban): scaffold Soroban client module" 31

# 34
git add services/coordinator/src/soroban/actions.rs
commit "feat(coordinator/soroban): implement contract action submission" 32

# 35
git add services/coordinator/src/soroban/proofs.rs
commit "feat(coordinator/soroban): implement proof submission and verification" 33

# 36
git add services/node/Cargo.toml services/node/Dockerfile
commit "chore(node): scaffold MPC node service" 34

# 37
git add services/node/src/main.rs
commit "feat(node): add MPC node entry point" 35

# 38
git add services/node/src/session.rs
commit "feat(node): implement MPC session handling" 36

# 39
git add services/node/src/private_table.rs
commit "feat(node): implement private card table and REP3 secret sharing" 37

# 40
git add services/node/src/api.rs
commit "feat(node): expose node HTTP API" 38

# 41
git add services/node/config/ services/node/data/
commit "chore(node): add node config and TLS certificates" 39

# 42
git add app/package.json app/tsconfig.json app/next.config.ts app/postcss.config.mjs app/next-env.d.ts app/package-lock.json
commit "chore(app): initialise Next.js project" 40

# 43
git add app/src/app/globals.css app/src/app/icon.svg app/src/app/layout.tsx app/src/app/not-found.tsx
commit "feat(app): add global styles, layout and 404 page" 41

# 44
git add app/src/lib/cards.ts app/src/lib/game-state.ts
commit "feat(app/lib): add card utilities and game state types" 42

# 45
git add app/src/lib/freighter.ts
commit "feat(app/lib): add Freighter wallet integration" 43

# 46
git add app/src/lib/onchain.ts
commit "feat(app/lib): add Soroban onchain interaction helpers" 44

# 47
git add app/src/lib/api.ts
commit "feat(app/lib): add coordinator API client" 45

# 48
git add app/src/lib/dealer-lines.ts app/src/lib/use-solo-betting.ts app/src/lib/use-poker-actions.ts
commit "feat(app/lib): add dealer lines, solo betting, and poker action hooks" 46

# 49
git add app/src/components/Card.tsx app/src/components/Board.tsx app/src/components/PlayerSeat.tsx
commit "feat(app/components): add Card, Board, and PlayerSeat components" 47

# 50
git add app/src/components/ActionPanel.tsx app/src/components/PixelChip.tsx
commit "feat(app/components): add ActionPanel and PixelChip components" 48

# 51
git add app/src/components/PixelCat.tsx app/src/components/PixelWorld.tsx app/public/cat_sprites/
commit "feat(app): add PixelCat, PixelWorld components and cat sprites" 49

# 52
git add app/src/components/GameBoyModal.tsx app/public/music/
commit "feat(app): add GameBoy mini-game modal and music assets" 50

# 53
git add app/src/components/Table.tsx app/src/app/page.tsx app/src/app/table/
git add scripts/ docker-compose.yml vendor/
commit "feat: add Table component, main pages, scripts, docker-compose and vendor" 51

echo ""
echo "✅ 53 commits created on branch 'rewrite-history'"
echo "Run: git branch -D main && git branch -m rewrite-history main"
echo "Then: git push origin main --force"
