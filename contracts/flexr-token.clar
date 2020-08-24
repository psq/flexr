;; (impl-trait .src20-trait.token)

(define-constant too-soon-err u10)
(define-constant balance-too-low-err u11)
(define-constant err-12 u12)
(define-constant err-13 u13)

(define-constant target-price u1000000)
(define-constant rebase-lag u10)  ;; started with 30 then moved to 10
(define-constant deviation-threshold-high u1050000)
(define-constant deviation-threshold-low u950000)
(define-constant rebalance-period u144)

(define-data-var supply uint (* u1000000000 u1000000))
(define-data-var last-rebase-height uint u0)

(define-map balances
  ((owner principal))
  ((base-amount uint) (total-supply-adjuster uint))
)

(define-private (balance-set (recipient principal) (amount uint))
  (map-set balances {owner: recipient} {base-amount: amount, total-supply-adjuster: (var-get supply)})
)

(define-public (transfer (recipient principal) (amount uint))
  (let ((balance-sender (unwrap-panic (balance-of tx-sender))) (balance-recipient (unwrap-panic (balance-of recipient))))
    (if (>= balance-sender amount)
      (begin
        (print "jjjj")
        (print balance-sender)
        (print balance-recipient)
        (print amount)
        (print tx-sender)
        (print recipient)
        (balance-set tx-sender (- balance-sender amount))
        (balance-set recipient (+ balance-recipient amount))
        (ok true)
      )
      (begin
        (print "kkkk")
        (print balance-sender)
        (print balance-recipient)
        (print amount)
        (print tx-sender)
        (print recipient)
        (err balance-too-low-err)
      )
    )
  )
)

;; returns the balance of `recipient`
;; total-supply * base-amount / total-supply-adjuster
(define-public (balance-of (recipient principal))
  (let ((balance (map-get? balances {owner: recipient})))
    (if (is-some balance)
      (ok (/ (* (var-get supply) (unwrap-panic (get base-amount balance))) (unwrap-panic (get total-supply-adjuster balance))))
      (ok u0)
    )
  )
)

;; ;; returns the total number of tokens
(define-public (total-supply)
  (ok (var-get supply))
)

;; returns the token name
(define-public (name)
  (ok "flexr")
)

(define-public (rebase)
  (begin
    (if (> block-height (+ (var-get last-rebase-height) rebalance-period))
      (begin
        (var-set last-rebase-height block-height) ;; TODO(psq): round down so rebase period is actually === rebalance-period?
        ;; TODO(psq): only call run-rebase if outside deviation-threshold-low - deviation-threshold-high
        (ok (run-rebase))
      )
      (err too-soon-err)
    )
  )
)

(define-private (run-rebase)
  (let ((current-price-data (contract-call? .oracle get-price)))
    (let ((current-price (get price current-price-data)))
      (let ((supply-delta (/ (* (- current-price target-price) (var-get supply)) target-price)))
        (let ((supply-delta-smoothed (/ supply-delta rebase-lag)))
          (var-set supply (+ (var-get supply) supply-delta-smoothed))
        )
      )
    )
  )
)

;; flexr treasury
(map-set balances {owner: 'SP1EHFWKXQEQD7TW9WWRGSGJFJ52XNGN6MTJ7X462} {base-amount: u950000000000000, total-supply-adjuster: u1000000000000000})
;; flexr geyser
(map-set balances {owner: 'S1G2081040G2081040G2081040G208105NK8PE5.geyser} {base-amount: u50000000000000, total-supply-adjuster: u1000000000000000})

