;; wrap the native STX token into an SRC20 compatible token to be usable along other tokens
(impl-trait .src20-trait.src20-trait)

;; get the token balance of owner
(define-read-only (balance-of (owner principal))
  (begin
    (ok (stx-get-balance owner))
  )
)

;; returns the total number of tokens
;; TODO(psq): we don't have access yet, but once POX is available, this should be a value that
;; is available from Clarity
(define-public (total-supply)
  (ok u0)
)

;; returns the token name
(define-public (name)
  (ok "stx")
)

;; Transfers tokens to a recipient
(define-public (transfer (recipient principal) (amount uint))
  (stx-transfer? amount tx-sender recipient)
)
