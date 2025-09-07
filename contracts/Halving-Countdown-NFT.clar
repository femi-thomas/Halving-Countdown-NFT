;; Halving Countdown NFT Contract
;; Simple NFT contract that evolves with Bitcoin halving events

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-TOKEN-OWNER (err u101))
(define-constant ERR-TOKEN-NOT-FOUND (err u102))
(define-constant ERR-INVALID-HALVING (err u103))

;; Bitcoin halving occurs approximately every 210,000 blocks (~4 years)
;; Historical halvings: 2012 (block 210,000), 2016 (420,000), 2020 (630,000), 2024 (840,000)
(define-constant BLOCKS-PER-HALVING u210000)
(define-constant FIRST-HALVING-BLOCK u210000)

;; NFT definition
(define-non-fungible-token halving-countdown-nft uint)

;; Data variables
(define-data-var last-token-id uint u0)

;; Maps
(define-map token-metadata uint {
  name: (string-ascii 256),
  description: (string-ascii 1024),
  image-uri: (string-ascii 256),
  halving-era: uint
})

;; Private functions
(define-private (get-current-halving-era)
  (let ((current-block-height block-height))
    (if (< current-block-height FIRST-HALVING-BLOCK)
      u0  ;; Pre-first halving
      (/ (- current-block-height FIRST-HALVING-BLOCK) BLOCKS-PER-HALVING))))

(define-private (get-blocks-until-next-halving)
  (let ((current-era (get-current-halving-era)))
    (- (+ FIRST-HALVING-BLOCK (* (+ current-era u1) BLOCKS-PER-HALVING)) block-height)))

(define-private (get-evolution-stage (halving-era uint))
  (if (< halving-era u1) "genesis"
    (if (< halving-era u2) "awakening" 
      (if (< halving-era u3) "maturation"
        (if (< halving-era u4) "transcendence"
          "eternal")))))

(define-private (get-image-uri (halving-era uint))
  (let ((stage (get-evolution-stage halving-era)))
    (if (is-eq stage "genesis") "ipfs://genesis-stage.json"
      (if (is-eq stage "awakening") "ipfs://awakening-stage.json"
        (if (is-eq stage "maturation") "ipfs://maturation-stage.json"
          (if (is-eq stage "transcendence") "ipfs://transcendence-stage.json"
            "ipfs://eternal-stage.json"))))))

;; Public functions
(define-public (mint-nft (recipient principal))
  (let ((token-id (+ (var-get last-token-id) u1))
        (current-era (get-current-halving-era))
        (blocks-remaining (get-blocks-until-next-halving)))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (try! (nft-mint? halving-countdown-nft token-id recipient))
    (map-set token-metadata token-id {
      name: (concat "Halving Countdown #" (int-to-ascii token-id)),
      description: (concat (concat "NFT evolving with Bitcoin halving events. Current era: " 
                                  (int-to-ascii current-era)) 
                          (concat ". Blocks until next halving: " 
                                  (int-to-ascii blocks-remaining))),
      image-uri: (get-image-uri current-era),
      halving-era: current-era
    })
    (var-set last-token-id token-id)
    (ok token-id)))

(define-public (evolve-nft (token-id uint))
  (let ((current-owner (unwrap! (nft-get-owner? halving-countdown-nft token-id) ERR-TOKEN-NOT-FOUND))
        (current-era (get-current-halving-era))
        (token-data (unwrap! (map-get? token-metadata token-id) ERR-TOKEN-NOT-FOUND)))
    (asserts! (is-eq tx-sender current-owner) ERR-NOT-TOKEN-OWNER)
    (asserts! (> current-era (get halving-era token-data)) ERR-INVALID-HALVING)
    (map-set token-metadata token-id (merge token-data {
      description: (concat (concat "NFT evolved to era " 
                                  (int-to-ascii current-era)) 
                          (concat ". Blocks until next halving: " 
                                  (int-to-ascii (get-blocks-until-next-halving)))),
      image-uri: (get-image-uri current-era),
      halving-era: current-era
    }))
    (ok true)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-TOKEN-OWNER)
    (nft-transfer? halving-countdown-nft token-id sender recipient)))

;; Read-only functions
(define-read-only (get-last-token-id)
  (var-get last-token-id))

(define-read-only (get-token-uri (token-id uint))
  (map-get? token-metadata token-id))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? halving-countdown-nft token-id)))

(define-read-only (get-current-halving-info)
  {
    current-era: (get-current-halving-era),
    blocks-until-next: (get-blocks-until-next-halving),
    current-stage: (get-evolution-stage (get-current-halving-era))
  })

(define-read-only (get-halving-era-for-block (block-height-param uint))
  (if (< block-height-param FIRST-HALVING-BLOCK)
    u0
    (/ (- block-height-param FIRST-HALVING-BLOCK) BLOCKS-PER-HALVING)))