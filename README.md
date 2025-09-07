📘 README: Halving Countdown NFT

Overview

The Halving Countdown NFT is a Clarity smart contract that mints and evolves non-fungible tokens (NFTs) based on Bitcoin halving events. Each NFT reflects the current halving era, updates its metadata as halvings occur, and evolves through distinct stages tied to Bitcoin’s block schedule.

Key Features

Dynamic NFT Evolution: Tokens automatically gain new descriptions and images as Bitcoin progresses through halving events.

Halving Awareness: Metadata includes the current halving era, the stage name (e.g., "genesis", "awakening", "maturation"), and blocks remaining until the next halving.

Owner-Only Minting: Only the contract owner can mint NFTs.

Secure Transfers: Token owners can transfer NFTs to other principals.

Controlled Evolution: NFT owners can trigger evolution once a new halving has been reached.

Halving Stages

Genesis (Pre-2012 halving)

Awakening (2012–2016)

Maturation (2016–2020)

Transcendence (2020–2024)

Eternal (2024 and beyond)

Public Functions

mint-nft (recipient principal) → Mint a new NFT for the given recipient.

evolve-nft (token-id uint) → Update NFT metadata to the new halving era (only if halving advanced).

transfer (token-id uint sender principal recipient principal) → Transfer NFT ownership.

Read-Only Functions

get-last-token-id → Returns the most recently minted token ID.

get-token-uri (token-id uint) → Returns metadata for the given token.

get-owner (token-id uint) → Returns the owner of a token.

get-current-halving-info → Returns current halving era, stage, and blocks until next halving.

get-halving-era-for-block (block-height-param uint) → Calculates the halving era for a given block height.

Error Codes

u100 → Owner-only function.

u101 → Caller is not the token owner.

u102 → Token not found.

u103 → Invalid halving evolution attempt.