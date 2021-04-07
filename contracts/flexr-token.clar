;; (impl-trait 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.src20-trait.token)

(define-constant too-soon-err u10)
(define-constant balance-too-low-err u11)
(define-constant err-12 u12)
(define-constant err-13 u13)

(define-constant target-price 1000000)
(define-constant rebase-lag u10)  ;; started with 30 then moved to 10
(define-constant deviation-threshold-high u1050000)
(define-constant deviation-threshold-low u950000)
(define-constant rebalance-period u3)  ;; TODO(psq): for testing only, real value should be u144 (1 day)

(define-data-var supply int (* 1000000000 target-price))
(define-data-var last-rebase-height uint u0)

(define-map balances
  { owner: principal }
  { base-amount: uint, total-supply-adjuster: uint }
)

(define-private (balance-set (recipient principal) (amount uint))
  (begin
    (print "flexr.balance-set")
    (print recipient)
    (print amount)
    (print (var-get supply))
    (print (map-set balances {owner: recipient} {base-amount: amount, total-supply-adjuster: (to-uint (var-get supply))}))
  )
)

(define-public (transfer (recipient principal) (amount uint))
  (let ((balance-sender (unwrap-panic (balance-of tx-sender))) (balance-recipient (unwrap-panic (balance-of recipient))))
    (print "flexr.transfer")
    (print tx-sender)
    (print contract-caller)
    (print recipient)
    (print amount)
    (print "balance-sender")
    (print balance-sender)
    (print "balance-recipient")
    (print balance-recipient)
    (if (>= balance-sender amount)
      (begin
        (balance-set tx-sender (- balance-sender amount))
        (balance-set recipient (+ balance-recipient amount))
        (ok true)
      )
      (begin
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
      (ok (/ (* (to-uint (var-get supply)) (unwrap-panic (get base-amount balance))) (unwrap-panic (get total-supply-adjuster balance))))
      (ok u0)
    )
  )
)

;; ;; returns the total number of tokens
(define-read-only (total-supply)
  (ok (to-uint (var-get supply)))
)

;; returns the token name
(define-read-only (name)
  (ok "flexr")
)

;; the token symbol
(define-read-only (symbol)
  (ok "FLXR")
)

;; the number of decimals used
(define-read-only (decimals)
  (ok u6)
)


;; can be run by anyone as long as the block height is farther enough from the previous rebase
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

;; internal calculation of the smoothed supply adjustment
(define-private (run-rebase)
  (let ((current-price-data (contract-call? 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.oracle get-price)))
    (let ((current-price (get price current-price-data)))
      (let ((supply-delta (/ (* (- (to-int current-price) target-price) (var-get supply)) target-price)))
        (let ((supply-delta-smoothed (/ supply-delta (to-int rebase-lag))))
          (var-set supply (+ (var-get supply) supply-delta-smoothed))
        )
      )
    )
  )
)

;; fund the flexr treasury
(map-set balances {owner: 'SP30JX68J79SMTTN0D2KXQAJBFVYY56BZJEYS3X0B} {base-amount: u950000000000000, total-supply-adjuster: u1000000000000000})
;; swapr test address
(map-set balances {owner: 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA} {base-amount: u100000000000000, total-supply-adjuster: u1000000000000000})
;; psq test address
(map-set balances {owner: 'ST1TWA18TSWGDAFZT377THRQQ451D1MSEM69C761} {base-amount: u1000000000000, total-supply-adjuster: u1000000000000000})
(map-set balances {owner: 'ST50GEWRE7W5B02G3J3K19GNDDAPC3XPZPYQRQDW} {base-amount: u1000000000000, total-supply-adjuster: u1000000000000000})
(map-set balances {owner: 'ST2SVRCJJD90TER037VCSAFA781HQTCPFK9YRA6J5} {base-amount: u1000000000000, total-supply-adjuster: u1000000000000000})
;; fund flexr geyser
(map-set balances {owner: 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.geyser} {base-amount: u50000000000000, total-supply-adjuster: u1000000000000000})

