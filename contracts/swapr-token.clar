;; we implement the src20 + a mint function
(impl-trait 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.swapr-trait.swapr-trait)

;; we can use an ft-token here, so use it!
(define-fungible-token token)

(define-constant no-acccess-err u30)

;; implement all 4 functions required by src20

(define-public (transfer (recipient principal) (amount uint))
  (begin
    (ft-transfer? token amount tx-sender recipient)
  )
)

(define-public (name)
  (contract-call? 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.swapr name 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.flexr-token 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.stx-token)
)

(define-public (symbol)
  (contract-call? 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.swapr symbol 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.flexr-token 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.stx-token)
)

;; the number of decimals used
(define-public (decimals)
  (ok u6)  ;; arbitrary
)

(define-public (balance-of (owner principal))
  ;; (contract-call? 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.swapr balance-of 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.flexr-token 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.stx-token owner)
  (ok (ft-get-balance token owner))
)

(define-public (total-supply)
  (contract-call? 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.swapr total-supply 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.flexr-token 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.stx-token)
)

;; the extra mint method used by swapr
;; can only be used by swapr main contract
(define-public (mint (recipient principal) (amount uint))
  (begin
    (print "token-swapr.mint")
    (print contract-caller)
    (print amount)
    (if (is-eq contract-caller 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.swapr)
      (ft-mint? token amount recipient)
      (err no-acccess-err)
    )
  )
)
