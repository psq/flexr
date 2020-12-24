(define-constant swapr-transfer-failed-err u42)
(define-constant reward-transfer-failed-err u43)
(define-constant no-stake-err u44)
(define-constant transfer-fail-err u45)
(define-constant geyser-empty-err u46)

(define-constant reward-period u1000)
(define-constant reward-period-1 u1000)
(define-constant reward-period-2 u2000)

(define-constant reward1 u1)
(define-constant reward2 u2)
(define-constant reward3 u3)

(define-map balances
  { owner: principal }
  {
    amount: uint,
    height: uint,
  }
)

(define-data-var supply uint u0)

;; stake token
;; pass in a swapr token for the FLEXR-STX pair token and amount
(define-public (stake (amount uint))
  (begin
    (print "geyser.stake")
    (print amount)
    (if (is-ok (contract-call? 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.flexr-stx-token transfer (as-contract tx-sender) amount))
      (let ((prior-amount (default-to u0 (get amount (map-get? balances {owner: tx-sender})))))
        (print prior-amount)
        (map-set balances {owner: tx-sender} {amount: (+ amount prior-amount), height: block-height})
        (var-set supply (+ (var-get supply) amount))
        (ok true)
      )
      (err transfer-fail-err)
    )
  )
)


;; unstake token
;; collect back the FLEXR-STX pair token and FLEXR reward
;; reward is based on number of block token was staked (1000 blocks => x1, 2000 blocks => 2x, 3000 blocks => 3x)
(define-public (unstake)
  (let ((balance (map-get? balances {owner: tx-sender})))
    (if (is-some balance)
      (let ((amount (unwrap-panic (get amount balance))) (height (unwrap-panic (get height balance))))
        (var-set supply (- (var-get supply) amount))
        (let ((blocks (- block-height height)))
          (if (< blocks reward-period-1)
            (send-back tx-sender amount blocks reward1)
            (if (< blocks reward-period-2)
              (send-back tx-sender amount blocks reward2)
              (send-back tx-sender amount blocks reward3)
            )
          )
        )
        ;; (ok true)
      )
      (err no-stake-err)
    )
  )
)

;; reward is amount * reward-factor * #blocks / reward-period per 1000 swapr-flexr-wrapr token in flexr tokens
(define-private (send-back (recipient principal) (amount uint) (blocks uint) (reward-factor uint))
  (let ((reward-amount (/ (* amount (* blocks reward-factor)) (* u1000 reward-period))))
    (print "geyser.send-back")
    (print recipient)
    (print amount)
    (print blocks)
    (print reward-factor)
    (print reward-amount)
    (print (as-contract tx-sender))
    (if (is-ok (as-contract (contract-call? 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.flexr-stx-token transfer recipient amount)))
      (if (is-ok (as-contract (contract-call? 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.flexr-token transfer recipient reward-amount)))
        (ok true)
        (err reward-transfer-failed-err)
      )
      (err swapr-transfer-failed-err)
    )
  )
)

;; find out total amount of staked FLEXR-WRAPR pair tokens
(define-read-only (total-supply)
  (ok (var-get supply))
)
