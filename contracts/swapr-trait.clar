;; Time for Stacks Request for Comment, the 20th edition...
(define-trait swapr-trait
  (
    (transfer (principal uint) (response bool uint))
    (name () (response (buff 32) uint))
    (balance-of (principal) (response uint uint))
    (total-supply () (response uint uint))
    (mint (principal uint) (response uint uint))
  )
)
