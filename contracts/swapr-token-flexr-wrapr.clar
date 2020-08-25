;; we implement the src20 + a mint function
(impl-trait .swapr-trait.swapr-trait)

;; we can use an ft-token here, so use it!
(define-fungible-token token)

(define-constant no-acccess-err u30)

;; implement all 4 functions required by src20

(define-public (transfer (recipient principal) (amount uint))
  (begin
    (ft-get-balance token tx-sender)
    (ft-transfer? token amount tx-sender recipient)
  )
)

(define-public (name)
  (contract-call? .swapr name .wrapr-token .flexr-token)
)

(define-public (balance-of (owner principal))
  (contract-call? .swapr balance-of .wrapr-token .flexr-token owner)
)

(define-public (total-supply)
  (contract-call? .swapr total-supply .wrapr-token .flexr-token)
)

;; the extra mint method used by swapr
;; can only be used by swapr main contract
(define-public (mint (recipient principal) (amount uint))
  (if (is-eq contract-caller .swapr)
    (ft-mint? token amount recipient)
    (err no-acccess-err)
  )
)
