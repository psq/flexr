;; wrap the native STX token into an SRC20 compatible token to be usable along other tokens
;; (use-trait src20-token .src20-trait.src20-trait)
(impl-trait 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.src20-trait.src20-trait)

(define-fungible-token plaid)

;; get the token balance of owner
(define-read-only (balance-of (owner principal))
  (begin
    (ok (print (ft-get-balance plaid owner)))
  )
)

;; returns the total number of tokens
;; TODO(psq): we don't have access yet, but once POX is available, this should be a value that
;; is available from Clarity
(define-read-only (total-supply)
  (ok u0)
)

;; returns the token name
(define-read-only (name)
  (ok "Plaid")
)

(define-read-only (symbol)
  (ok "PLD")
)

;; the number of decimals used
(define-read-only (decimals)
  (ok u8)
)

;; Transfers tokens to a recipient
(define-public (transfer (recipient principal) (amount uint))
  (begin
    (print "plaid.transfer")
    (print amount)
    (print tx-sender)
    (print recipient)
    (print (ft-transfer? plaid amount tx-sender recipient))
  )
)

(ft-mint? plaid u100000000000000 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA)
(ft-mint? plaid u100000000000000 'ST1TWA18TSWGDAFZT377THRQQ451D1MSEM69C761)
(ft-mint? plaid u100000000000000 'ST50GEWRE7W5B02G3J3K19GNDDAPC3XPZPYQRQDW)
