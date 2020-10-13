;; this is an SRC20 method with an additional mint function
;; as Clarity does not support "includes", copy the needed funcitons, and add new ones

(define-trait swapr-trait
  (
    (transfer (principal uint) (response bool uint))
    (name () (response (string-ascii 32) uint))
    (symbol () (response (string-ascii 32) uint))
    (decimals () (response uint uint))
    (balance-of (principal) (response uint uint))
    (total-supply () (response uint uint))
    (mint (principal uint) (response bool uint))
  )
)
