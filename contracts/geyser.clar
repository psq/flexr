(define-constant err-swapr-transfer-failed u2)
(define-constant err-reward-transfer-failed u3)
(define-constant err-no-stake u4)
(define-constant err-transfer-fail u5)

(define-constant reward-period u1000)
(define-constant reward-period-1 u1000)
(define-constant reward-period-2 u2000)

(define-constant reward1 u1)
(define-constant reward2 u2)
(define-constant reward3 u3)

(define-map balances
  ((owner principal))
  ((amount uint) (height uint))
)

;; stake token
;; pass in a swapr token for the FLEXR-STX pair token and amount
(define-public (stake (amount uint))
  (if (is-ok (contract-call? .swapr-token transfer (as-contract tx-sender) amount))
    (let ((prior-amount (default-to u0 (get amount (map-get? balances {owner: tx-sender})))))
      (map-set balances {owner: tx-sender} {amount: amount, height: block-height})
      (ok true)
    )
    (err err-transfer-fail)
  )
)


;; unstake token
;; collect back the FLEXR-STX pair token and FLEXR reward
;; reward is based on number of block token was staked (1000 blocks => x1, 2000 blocks => 2x, 3000 blocks => 3x)
(define-public (unstake)
  (let ((balance (map-get? balances {owner: tx-sender})))
    (if (is-some balance)
      (let ((amount (unwrap-panic (get amount balance))) (height (unwrap-panic (get height balance))))
        (let ((blocks (- block-height height)))
          (if (< blocks reward-period-1)
            (send-back tx-sender amount blocks reward1)
            (if (< blocks reward-period-2)
              (send-back tx-sender amount blocks reward2)
              (send-back tx-sender amount blocks reward3)
            )
          )
        )
      )
      (err err-no-stake)
    )
    (ok true)
  )
)

;; reward is amount * reward-factor * #blocks / reward-period per 1000 swapr token in FLEXR tokens

(define-private (send-back (recipient principal) (amount uint) (blocks uint) (reward-factor uint))
  (let ((reward-amount (/ (* amount (* blocks reward-factor)) (* u1000 reward-period))))
    (if (is-ok (as-contract (contract-call? .swapr-token transfer recipient amount)))
      (if (is-ok (as-contract (contract-call? .flexr-token transfer recipient reward-amount)))
        (ok true)
        (err err-reward-transfer-failed)
      )
      (err err-swapr-transfer-failed)
    )
  )
)
