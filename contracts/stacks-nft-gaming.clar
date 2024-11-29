;; title: Stacks NFT Gaming Platform
;; summary: A comprehensive smart contract for managing a gaming ecosystem with NFTs, player registration, score tracking, and reward distribution.
;; description: This smart contract facilitates the creation and management of a gaming platform on the Stacks blockchain. It includes functionalities for minting and transferring NFTs, registering players, updating player scores, and distributing rewards based on performance. The contract ensures secure and authorized operations through a whitelist of game administrators and various validation checks.

;; Error Constants
(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-INVALID-GAME-ASSET (err u2))
(define-constant ERR-INSUFFICIENT-FUNDS (err u3))
(define-constant ERR-TRANSFER-FAILED (err u4))
(define-constant ERR-LEADERBOARD-FULL (err u5))
(define-constant ERR-ALREADY-REGISTERED (err u6))
(define-constant ERR-INVALID-REWARD (err u7))
(define-constant ERR-INVALID-INPUT (err u8))
(define-constant ERR-INVALID-SCORE (err u9))
(define-constant ERR-INVALID-FEE (err u10))
(define-constant ERR-INVALID-ENTRIES (err u11))
(define-constant ERR-PLAYER-NOT-FOUND (err u12))

;; Storage for game configuration and state
(define-data-var game-fee uint u10)
(define-data-var max-leaderboard-entries uint u50)
(define-data-var total-prize-pool uint u0)

;; NFT definition
(define-non-fungible-token game-asset uint)

;; Game Asset Metadata Map
(define-map game-asset-metadata 
  { token-id: uint }
  { 
    name: (string-ascii 50),
    description: (string-ascii 200),
    rarity: (string-ascii 20),
    power-level: uint
  }
)

;; Leaderboard Map
(define-map leaderboard 
  { player: principal }
  { 
    score: uint, 
    games-played: uint,
    total-rewards: uint 
  }
)

;; Whitelist for game creators and administrators
(define-map game-admin-whitelist principal bool)

;; Global variables
(define-data-var total-game-assets uint u0)

;; Read-only functions for validation

;; Check if sender is a game admin
(define-read-only (is-game-admin (sender principal))
  (default-to false (map-get? game-admin-whitelist sender))
)

;; Validate input string
(define-read-only (is-valid-string (input (string-ascii 200)))
  (> (len input) u0)
)

;; Validate principal
(define-read-only (is-valid-principal (input principal))
  (and 
    (not (is-eq input tx-sender))
    (not (is-eq input (as-contract tx-sender)))
  )
)

;; Enhanced principal validation
(define-read-only (is-safe-principal (input principal))
  (and 
    (is-valid-principal input)
    (or 
      (is-game-admin input)
      (is-some (map-get? leaderboard { player: input }))
    )
  )
)

;; Public Functions

;; Add game administrator
(define-public (add-game-admin (new-admin principal))
  (begin
    (asserts! (is-game-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-safe-principal new-admin) ERR-INVALID-INPUT)
    (map-set game-admin-whitelist new-admin true)
    (ok true)
  )
)

;; Mint new game asset NFT
(define-public (mint-game-asset 
  (name (string-ascii 50))
  (description (string-ascii 200))
  (rarity (string-ascii 20))
  (power-level uint)
)
  (let 
    (
      (token-id (+ (var-get total-game-assets) u1))
    )
    (asserts! (is-game-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-string name) ERR-INVALID-INPUT)
    (asserts! (is-valid-string description) ERR-INVALID-INPUT)
    (asserts! (is-valid-string rarity) ERR-INVALID-INPUT)
    (asserts! (and (>= power-level u0) (<= power-level u1000)) ERR-INVALID-INPUT)
    
    (try! (nft-mint? game-asset token-id tx-sender))
    
    (map-set game-asset-metadata 
      { token-id: token-id }
      {
        name: name,
        description: description, 
        rarity: rarity,
        power-level: power-level
      }
    )
    
    (var-set total-game-assets token-id)
    
    (ok token-id)
  )
)