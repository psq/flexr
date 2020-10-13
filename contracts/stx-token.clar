;; wrap the native STX token into an SRC20 compatible token to be usable along other tokens
;; (use-trait src20-token .src20-trait.src20-trait)
(impl-trait 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.src20-trait.src20-trait)

;; get the token balance of owner
(define-read-only (balance-of (owner principal))
  (begin
    (ok (print (stx-get-balance owner)))
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

(define-public (symbol)
  (ok "STX")
)

;; the number of decimals used
(define-public (decimals)
  (ok u6)
)

;; Transfers tokens to a recipient
(define-public (transfer (recipient principal) (amount uint))
  (begin
    (print "stx.transfer")
    (print amount)
    (print tx-sender)
    (print recipient)
    (print (stx-transfer? amount tx-sender recipient))
  )
)

