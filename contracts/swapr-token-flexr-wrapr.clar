(impl-trait .swapr-trait.swapr-trait)

(define-fungible-token token)

(define-constant no-acccess-err u30)

(define-public (transfer (recipient principal) (amount uint))
  (ft-transfer? token amount tx-sender recipient)
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

;; can only be used by swapr main contract
(define-public (mint (recipient principal) (amount uint))
  (if (is-eq contract-caller .swapr)
    (ft-mint? token amount recipient)
    (err no-acccess-err)
  )
)
