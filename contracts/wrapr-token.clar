;; this is the original wrapr contract, with the additional functions now required by SRC20

(impl-trait 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.src20-trait.src20-trait)

(define-data-var supply uint u0)

(define-fungible-token wrapped-token)

;; get the token balance of owner
(define-read-only (balance-of (owner principal))
  (begin
    (ok (ft-get-balance wrapped-token owner))
  )
)

;; returns the total number of tokens
(define-public (total-supply)
  (ok (var-get supply))
)

;; returns the token name
(define-public (name)
  (ok "wrapr")
)

;; transfer amount STX and return wrapped fungible token
;; mints new token
(define-public (wrap (amount uint))
  (let ((contract-address (as-contract tx-sender)))
    (if
      (and
        (is-ok (stx-transfer? amount tx-sender contract-address))
        (is-ok (ft-mint? wrapped-token amount tx-sender))
      )
      (begin
        (var-set supply (+ (var-get supply) amount))
        (ok (list amount (var-get supply)))
      )
      (begin
        (err false)
      )
    )
  )
)

;; unwraps wrapped STX token
;; burns unwrapped token (well, can't burn yet, so will forever increase, good thing there is no limit)
(define-public (unwrap (amount uint))
  (let ((caller tx-sender) (contract-address (as-contract tx-sender)))
    (if
      (and
        (<= amount (var-get supply))
        ;; this is where burn would be more appropriate, as trying to reuse tokens or mint
        ;; would make the code more complex for little benefit
        (is-ok (ft-transfer? wrapped-token amount caller contract-address))
        (is-ok (as-contract (stx-transfer? amount contract-address caller)))
      )
      (begin
        (var-set supply (- (var-get supply) amount))
        (ok (list amount (var-get supply)))
      )
      (err false)
    )
  )
)

;; Transfers tokens to a specified principal.
;; just a wrapper to satisfy the `<can-transfer-token>`
(define-public (transfer (recipient principal) (amount uint))
  (begin
    (ft-get-balance wrapped-token tx-sender)
    (ft-transfer? wrapped-token amount tx-sender recipient)
  )
)

