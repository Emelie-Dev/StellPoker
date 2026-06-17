FROM rust:1.79-slim AS builder
WORKDIR /app
COPY services/coordinator/ ./services/coordinator/
COPY Cargo.toml ./Cargo.toml
RUN cargo build --release -p coordinator 2>/dev/null || true

# Build co-noir from source
FROM rust:1.79-slim AS conoir-builder
RUN apt-get update && apt-get install -y git pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*
RUN cargo install --git https://github.com/TaceoLabs/co-snarks --branch main co-noir

# Compile Noir circuits inside Docker (no local nargo required)
FROM debian:bookworm-slim AS circuit-builder
RUN apt-get update && apt-get install -y curl bash && rm -rf /var/lib/apt/lists/*
RUN curl -L https://raw.githubusercontent.com/noir-lang/noirup/refs/heads/main/install | bash
ENV PATH="/root/.nargo/bin:$PATH"
RUN /root/.nargo/bin/noirup -v 1.0.0-beta.17
COPY circuits/ /app/circuits/
WORKDIR /app/circuits/deal_valid
RUN /root/.nargo/bin/nargo compile
WORKDIR /app/circuits/reveal_board_valid
RUN /root/.nargo/bin/nargo compile
WORKDIR /app/circuits/showdown_valid
RUN /root/.nargo/bin/nargo compile

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates curl && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/coordinator /usr/local/bin/coordinator
COPY --from=conoir-builder /usr/local/cargo/bin/co-noir /usr/local/bin/co-noir
COPY --from=circuit-builder /app/circuits/deal_valid/target/ /app/circuits/deal_valid/target/
COPY --from=circuit-builder /app/circuits/reveal_board_valid/target/ /app/circuits/reveal_board_valid/target/
COPY --from=circuit-builder /app/circuits/showdown_valid/target/ /app/circuits/showdown_valid/target/

CMD ["coordinator"]
