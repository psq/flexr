;; Time for a Stacks Request for Comment, the 20th edition...
;; The function needed by tokens compatible with swapr, and the geyser
;; a subset of ERC20 methods
(define-trait src20-trait
  (
    ;; Transfer from the caller to a new principal
    (transfer (principal uint) (response bool uint))

    ;; the human readable name of the token
    (name () (response (buff 32) uint))

    ;; the balance of the passed principal
    (balance-of (principal) (response uint uint))

    ;; the current total supply (which does not need to be a constant)
    (total-supply () (response uint uint))
  )
)
