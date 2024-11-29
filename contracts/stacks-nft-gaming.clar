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