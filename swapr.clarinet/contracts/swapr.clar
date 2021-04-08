(use-trait src20-token 'ST000000000000000000002AMW42H.sip-010.ft-trait)
(use-trait swapr-token 'ST000000000000000000002AMW42H.swapr-trait.swapr-trait)

(define-constant contract-owner 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA)
(define-constant no-liquidity-err (err u61))
(define-constant transfer-failed-err (err u62))
(define-constant not-owner-err (err u63))
(define-constant no-fee-to-address-err (err u64))
(define-constant invalid-pair-err (err u65))
(define-constant no-such-position-err (err u66))
(define-constant balance-too-low-err (err u67))
(define-constant too-many-pairs-err (err u68))
(define-constant pair-already-exists-err (err u69))
(define-constant wrong-token-err (err u70))
(define-constant too-much-slippage-err (err u71))

;; for future use, or debug
(define-constant e10-err (err u20))
(define-constant e11-err (err u21))
(define-constant e12-err (err u22))

;; ;; V1
;; ;; overall balance of x-token and y-token held by the contract
;; (define-data-var balance-x uint u0)
;; (define-data-var balance-y uint u0)

;; ;; fees collected so far, that have not been withdrawn (saves gas while doing exchanges)
;; (define-data-var fee-balance-x uint u0)
;; (define-data-var fee-balance-y uint u0)

;; ;; balances help by all the clients holding shares, this is equal to the sum of all the balances held in shares by each client
;; (define-data-var total-balances uint u0)
;; (define-map shares
;;   ((owner principal))
;;   ((balance uint))
;; )

;; ;; when set, enables the fee, and provides whene to send the fee when calling collect-fees
;; (define-data-var fee-to-address (optional principal) none)

;; V2
;; variables
;; (name) => (token-x, token-y)
;; (token-x, token-y) => (shares-total, balance-x, balance-y, fee-balance-x, fee-balance-y, fee-to-address)
;; (token-x, token-y, principal) => (shares)

(define-map pairs-map
  { pair-id: uint }
  {
    token-x: principal,
    token-y: principal,
  }
)

(define-map pairs-data-map
  {
    token-x: principal,
    token-y: principal,
  }
  {
    shares-total: uint,
    fee-balance-x: uint,
    fee-balance-y: uint,
    fee-to-address: (optional principal),
    swapr-token: principal,
    name: (string-ascii 32),
  }
)

;; ;; TODO(psq): replace use of balance-x/balance-y with a call to balance-of(swapr) on the token itself, no write to do actually!!!  The transfer is the write, that's cool :)


;; (define-map shares-map
;;   ((token-x principal) (token-y principal) (owner principal))
;;   ((shares uint))
;; )

;; (define-data-var pairs-list (list 2000 uint) (list))
(define-data-var pair-count uint u0)


;; token support, these ~~4~~3 calls need to be wrapped in a contract that hardcodes the 2 pairs to present
;; a unified, src20 compatible trait

;; (define-public (transfer (token-x-trait <src20-token>) (token-y-trait <src20-token>) (recipient principal) (amount uint) (token-trait <src20-token>))
;;   (let ((token-x (contract-of token-x-trait)) (token-y (contract-of token-y-trait)) (token (contract-of token-trait)))
;;     (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
;;       (if (eq token (get swapr-token pair))
;;         (contract-call? token-trait transfer recipient amount)
;;         (err wrong-token-err)
;;       )
;;     )
;;   )
;; )

(define-read-only (get-name (token-x-trait <src20-token>) (token-y-trait <src20-token>))
  (let ((token-x (contract-of token-x-trait)) (token-y (contract-of token-y-trait)))
    (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
      (ok (get name pair))
    )
  )
)

(define-public (get-symbol (token-x-trait <src20-token>) (token-y-trait <src20-token>))
  ;; TODO(psq): this should be the symbol of the pair, not a single token
  ;; TODO(psq): obvious not the rigth thing to do here
  ;; (contract-call? 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.plaid-token symbol)
  (contract-call? token-y-trait get-symbol)
  ;; (ok (concat (unwrap-panic (as-max-len? (unwrap-panic (contract-call? token-x-trait symbol)) u15)) (concat "-" (unwrap-panic (as-max-len? (unwrap-panic (contract-call? token-y-trait symbol)) u15)))))
)

;; (define-public (balance-of (token-x-trait <src20-token>) (token-y-trait <src20-token>) (owner principal))
;;   (begin
;;     (let ((token-x (contract-of token-x-trait)) (token-y (contract-of token-y-trait)))
;;       (print "swapr.balance-of")
;;       (print token-x)
;;       (print token-y)
;;       (print owner)
;;       (ok (print (shares-of token-x token-y owner)))
;;     )
;;   )
;; )

(define-read-only (get-total-supply (token-x-trait <src20-token>) (token-y-trait <src20-token>))
  (let ((token-x (contract-of token-x-trait)) (token-y (contract-of token-y-trait)))
    (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
      (ok (get shares-total pair))
    )
  )
)


;; wrappers to get an owner's position
;; (define-private (shares-of (token-x principal) (token-y principal) (owner principal))
;;   (default-to u0
;;     (get shares
;;       (map-get? shares-map ((token-x token-x) (token-y token-y) (owner owner)))
;;     )
;;   )
;; )

;; get the number of shares of the pool for owner
;; (define-read-only (get-shares-of (token-x principal) (token-y principal) (owner principal))
;;   (ok (shares-of token-x token-y owner))
;; )

;; get the total number of shares in the pool
(define-read-only (get-shares (token-x principal) (token-y principal))
  (ok (get shares-total (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
)

;; TODO(psq): only works if a token is in only one pair, to make this work, needs a new instance of the contract per pair at a different address
;; which would remove the need for a separate token, as swapr can be its own token
(define-private (get-balance (token-trait <src20-token>))
  (begin
    (unwrap-panic (contract-call? token-trait get-balance-of (as-contract tx-sender)))
  )
)

;; (define-public (get-balances-of (token-x-trait <src20-token>) (token-y-trait <src20-token>) (owner principal))
;;   (let ((token-x (contract-of token-x-trait)) (token-y (contract-of token-y-trait)))
;;     (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
;;       (let ((x (balance token-x-trait)) (y (balance token-y-trait)) (shares-total (get shares-total pair)) (shares (shares-of token-x token-y owner)))
;;         (if (> shares-total u0)
;;           (ok (list (/ (* x shares) shares-total) (/ (* y shares) shares-total)))  ;; less precision loss doing * first
;;           no-liquidity-err  ;; no liquidity
;;         )
;;       )
;;     )
;;   )
;; )

;; (define-private (increase-shares (token-x principal) (token-y principal) (owner principal) (amount uint))
;;   (let ((shares (shares-of token-x token-y owner)))
;;     (print "swapr.increase-shares")
;;     (print token-x)
;;     (print token-y)
;;     (print owner)
;;     (print shares)
;;     (print amount)
;;     (print (map-set shares-map
;;       ((token-x token-x) (token-y token-y) (owner owner))
;;       ((shares (+ shares amount)))
;;     ))
;;     (ok true)
;;   )
;; )

;; (define-private (decrease-shares (token-x principal) (token-y principal) (owner principal) (amount uint))
;;   (let ((shares (shares-of token-x token-y owner)))
;;     (if (< amount shares)
;;       (begin
;;         (map-set shares-map
;;           ((token-x token-x) (token-y token-y) (owner owner))
;;           ((shares (- shares amount)))
;;         )
;;         (ok true)
;;       )
;;       balance-too-low-err
;;     )
;;   )
;; )

;; get overall balances for the pair
(define-public (get-balances (token-x-trait <src20-token>) (token-y-trait <src20-token>))
  (let ((token-x (contract-of token-x-trait)) (token-y (contract-of token-y-trait)))
    (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
      (ok (list (get-balance token-x-trait) (get-balance token-y-trait)))
    )
  )
)

;; since we can't use a constant to refer to contract address, here what x and y are
;; (define-constant x-token 'SP2NC4YKZWM2YMCJV851VF278H9J50ZSNM33P3JM1.my-token)
;; (define-constant y-token 'SP1QR3RAGH3GEME9WV7XB0TZCX6D5MNDQP97D35EH.my-token)
(define-public (add-to-position (token-x-trait <src20-token>) (token-y-trait <src20-token>) (token-swapr-trait <swapr-token>) (x uint) (y uint))
  (let ((token-x (contract-of token-x-trait)) (token-y (contract-of token-y-trait)))
    (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)) (contract-address (as-contract tx-sender)) (recipient-address tx-sender))
      ;; TODO(psq) check if x or y is 0, to calculate proper exchange rate unless shares-total is 0, which would be an error
      (if
        (and
          ;; TODO(psq): check that the amount transfered in matches the amount requested
          (is-ok (contract-call? token-x-trait transfer x tx-sender contract-address))
          (is-ok (contract-call? token-y-trait transfer y tx-sender contract-address))
        )
        (begin
          (print "calculate new-shares")
          (let ((new-shares (if (is-eq (print (get shares-total pair)) u0)
                  (let ((shares (sqrti (* x y))))
                    ;; (increase-shares token-x token-y tx-sender shares)
                    shares
                  )
                  (let ((shares (/ (* (print x) (print (get shares-total pair))) (print (get-balance token-x-trait)))))
                    ;; (increase-shares token-x token-y tx-sender shares)
                    shares
                  )
                )))
            (map-set pairs-data-map { token-x: token-x, token-y: token-y }
              {
                shares-total: (+ new-shares (get shares-total pair)),
                fee-balance-x: (get fee-balance-x pair),
                fee-balance-y: (get fee-balance-y pair),
                fee-to-address: (get fee-to-address pair),
                name: (get name pair),
                swapr-token: (get swapr-token pair),
              }
            )
            (print "token-swapr-trait.mint params")
            (print x)
            (print y)
            (print recipient-address)
            (print new-shares)
            (print (contract-call? token-swapr-trait mint recipient-address new-shares))
          )
        )
        (begin
          transfer-failed-err
        )
      )
    )
  )
)

(define-read-only (get-pair-details (token-x principal) (token-y principal))
  (unwrap-panic (map-get? pairs-data-map { token-x: token-x, token-y: token-y }))
)

(define-read-only (get-pair-contracts (pair-id uint))
  (unwrap-panic (map-get? pairs-map { pair-id: pair-id }))
)

(define-read-only (get-pair-count)
  (ok (var-get pair-count))
)

;; (define-read-only (get-pairs)
;;   (ok (map get-pair-contracts (var-get pairs-list)))
;; )

(define-public (create-pair (token-x-trait <src20-token>) (token-y-trait <src20-token>) (token-swapr-trait <swapr-token>) (pair-name (string-ascii 32)) (x uint) (y uint))
  ;; TOOD(psq): add creation checks, then create map before proceeding to add-to-position
  ;; check neither x,y or y,x exists`
  (let ((name-x (unwrap-panic (contract-call? token-x-trait get-name))) (name-y (unwrap-panic (contract-call? token-y-trait get-name))))
    (let ((token-x (contract-of token-x-trait)) (token-y (contract-of token-y-trait)) (pair-id (+ (var-get pair-count) u1)))
      (if (and (is-none (map-get? pairs-data-map { token-x: token-x, token-y: token-y })) (is-none (map-get? pairs-data-map { token-x: token-y, token-y: token-x })))
        (begin
          (map-set pairs-data-map { token-x: token-x, token-y: token-y }
            {
              shares-total: u0,
              fee-balance-x: u0,
              fee-balance-y: u0,
              fee-to-address: none,
              swapr-token: (contract-of token-swapr-trait),
              name: pair-name,
            }
          )
          (map-set pairs-map { pair-id: pair-id } { token-x: token-x, token-y: token-y })
          ;; (var-set pairs-list (unwrap! (as-max-len? (append (var-get pairs-list) pair-id) u2000) too-many-pairs-err))
          (var-set pair-count pair-id)
          (add-to-position token-x-trait token-y-trait token-swapr-trait x y)
        )
        pair-already-exists-err
      )
    )
  )
)



;; ;; reduce the amount of liquidity the sender provides to the pool
;; ;; to close, use u100
(define-public (reduce-position (token-x-trait <src20-token>) (token-y-trait <src20-token>) (token-swapr-trait <swapr-token>) (percent uint))
  (let ((token-x (contract-of token-x-trait)) (token-y (contract-of token-y-trait)))
    (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
      (let ((shares (unwrap-panic (contract-call? token-swapr-trait get-balance-of tx-sender))) (shares-total (get shares-total pair)) (contract-address (as-contract tx-sender)) (sender tx-sender))
        (let ((withdrawal (/ (* shares percent) u100)))
          (let ((withdrawal-x (/ (* withdrawal (get-balance token-x-trait)) shares-total)) (withdrawal-y (/ (* withdrawal (get-balance token-y-trait)) shares-total)))
            (if
              (and
                (<= percent u100)
                (is-ok (as-contract (contract-call? token-x-trait transfer withdrawal-x contract-address sender)))
                (is-ok (as-contract (contract-call? token-y-trait transfer withdrawal-y contract-address sender)))
              )
              (begin
                ;; (unwrap-panic (decrease-shares token-x token-y tx-sender withdrawal)) ;; should never fail, you know...
                (map-set pairs-data-map { token-x: token-x, token-y: token-y }
                  {
                    shares-total: (- shares-total withdrawal),
                    fee-balance-x: (get fee-balance-x pair),
                    fee-balance-y: (get fee-balance-y pair),
                    fee-to-address: (get fee-to-address pair),
                    name: (get name pair),
                    swapr-token: (get swapr-token pair),
                  }
                )
                ;; TODO(psq): use burn
                (unwrap-panic (contract-call? token-swapr-trait transfer withdrawal tx-sender contract-address))  ;; transfer back to swapr, wish there was a burn instead...
                (ok (list withdrawal-x withdrawal-y))
              )
              transfer-failed-err
            )
          )
        )
      )
    )
  )
)

;; exchange known dx of x-token for whatever dy of y-token based on current liquidity, returns (dx dy)
;; the swap will not happen if can't get at least min-dy back
(define-public (swap-exact-x-for-y (token-x-trait <src20-token>) (token-y-trait <src20-token>) (dx uint) (min-dy uint))
  ;; calculate dy
  ;; calculate fee on dx
  ;; transfer
  ;; update balances
  (let ((token-x (contract-of token-x-trait)) (token-y (contract-of token-y-trait)))
    (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
      (let
        (
          (contract-address (as-contract tx-sender))
          (sender tx-sender)
          (dy (/ (* u997 (get-balance token-y-trait) dx) (+ (* u1000 (get-balance token-x-trait)) (* u997 dx)))) ;; overall fee is 30 bp, either all for the pool, or 25 bp for pool and 5 bp for operator
          (fee (/ (* u5 dx) u10000)) ;; 5 bp
        )
        (if (and
          ;; TODO(psq): check that the amount transfered in matches the amount requested
            (is-ok (contract-call? token-x-trait transfer dx sender contract-address))
            (is-ok (as-contract (contract-call? token-y-trait transfer dy contract-address sender)))
          )
          (begin
            (map-set pairs-data-map { token-x: token-x, token-y: token-y }
              {
                shares-total: (get shares-total pair),
                fee-balance-x:
                  (if (is-some (get fee-to-address pair))  ;; only collect fee when fee-to-address is set
                    (+ fee (get fee-balance-x pair))
                    (get fee-balance-x pair)
                  )
                ,
                fee-balance-y: (get fee-balance-y pair),
                fee-to-address: (get fee-to-address pair),
                name: (get name pair),
                swapr-token: (get swapr-token pair),
              }
            )
            (ok (list dx dy))
          )
          transfer-failed-err
        )
      )
    )
  )
)

;; exchange known dy for whatever dx based on liquidity, returns (dx dy)
;; the swap will not happen if can't get at least min-dx back
(define-public (swap-exact-y-for-x (token-x-trait <src20-token>) (token-y-trait <src20-token>) (dy uint) (min-dx uint))
  ;; calculate dx
  ;; calculate fee on dy
  ;; transfer
  ;; update balances
  (let ((token-x (contract-of token-x-trait)) (token-y (contract-of token-y-trait)))
    (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
      (let
        (
          (contract-address (as-contract tx-sender))
          (sender tx-sender)
          (dx (/ (* u997 (get-balance token-x-trait) dy) (+ (* u1000 (get-balance token-y-trait)) (* u997 dy)))) ;; overall fee is 30 bp, either all for the pool, or 25 bp for pool and 5 bp for operator
          (fee (/ (* u5 dy) u10000)) ;; 5 bp
        )
        (if (and
          ;; TODO(psq): check that the amount transfered in matches the amount requested
          (is-ok (as-contract (contract-call? token-x-trait transfer dx contract-address sender)))
          (is-ok (contract-call? token-y-trait transfer dy sender contract-address))
          )
          (begin
            (map-set pairs-data-map { token-x: token-x, token-y: token-y }
              {
                shares-total: (get shares-total pair),
                ;; (balance-x (- (balance token-x-trait) dx)) ;; remove dx
                ;; (balance-y
                ;;   (if (is-some (get fee-to-address pair))  ;; only collect fee when fee-to-address is set
                ;;     (- (+ (balance token-y-trait) dy) fee)  ;; add dy - fee
                ;;     (+ (balance token-y-trait) dy)  ;; add dy
                ;;   )
                ;; )
                fee-balance-x: (get fee-balance-x pair),
                fee-balance-y:
                  (if (is-some (get fee-to-address pair))  ;; only collect fee when fee-to-address is set
                    (+ fee (get fee-balance-y pair))
                    (get fee-balance-y pair)
                  )
                ,
                fee-to-address: (get fee-to-address pair),
                name: (get name pair),
                swapr-token: (get swapr-token pair),
              }
            )
            (ok (list dx dy))
          )
          transfer-failed-err
        )
      )
    )
  )
)

;; ;; activate the contract fee for swaps by setting the collection address, restricted to contract owner
(define-public (set-fee-to-address (token-x principal) (token-y principal) (address principal))
  (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
    (if (is-eq tx-sender contract-owner)
      (begin
        (map-set pairs-data-map { token-x: token-x, token-y: token-y }
          {
            shares-total: (get shares-total pair),
            ;; (balance-x (balance token-x-trait))
            ;; (balance-y (balance token-y-trait))
            fee-balance-x: (get fee-balance-y pair),
            fee-balance-y: (get fee-balance-y pair),
            fee-to-address: (some address),
            name: (get name pair),
            swapr-token: (get swapr-token pair),
          }
        )
        (ok true)
      )
      not-owner-err
    )
  )
)

;; ;; clear the contract fee addres
;; ;; TODO(psq): if there are any collected fees, prevent this from happening, as the fees can no longer be collect with `collect-fees`
(define-public (reset-fee-to-address (token-x principal) (token-y principal))
  (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
    (if (is-eq tx-sender contract-owner)
      (begin
        (map-set pairs-data-map { token-x: token-x, token-y: token-y }
          {
            shares-total: (get shares-total pair),
            ;; (balance-x (balance token-x-trait))
            ;; (balance-y (balance token-y-trait))
            fee-balance-x: (get fee-balance-y pair),
            fee-balance-y: (get fee-balance-y pair),
            fee-to-address: none,
            name: (get name pair),
            swapr-token: (get swapr-token pair),
          }
        )
        (ok true)
      )
      not-owner-err
    )
  )
)

;; ;; get the current address used to collect a fee
(define-read-only (get-fee-to-address (token-x principal) (token-y principal))
  (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
    (ok (get fee-to-address pair))
  )
)

;; ;; get the amount of fees charged on x-token and y-token exchanges that have not been collected yet
(define-read-only (get-fees (token-x principal) (token-y principal))
  (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
    (ok (list (get fee-balance-x pair) (get fee-balance-y pair)))
  )
)

;; ;; send the collected fees the fee-to-address
(define-public (collect-fees (token-x-trait <src20-token>) (token-y-trait <src20-token>))
  (let ((token-x (contract-of token-x-trait)) (token-y (contract-of token-y-trait)) (contract-address (as-contract tx-sender)))
    (let ((pair (unwrap! (map-get? pairs-data-map { token-x: token-x, token-y: token-y }) invalid-pair-err)))
      (let ((address (unwrap! (get fee-to-address pair) no-fee-to-address-err)) (fee-x (get fee-balance-x pair)) (fee-y (get fee-balance-y pair)))
        (if
          (and
            (or (is-eq fee-x u0) (is-ok (as-contract (contract-call? token-x-trait transfer fee-x contract-address address))))
            (or (is-eq fee-y u0) (is-ok (as-contract (contract-call? token-y-trait transfer fee-y contract-address address))))
          )
          (begin
            (map-set pairs-data-map { token-x: token-x, token-y: token-y }
              {
                shares-total: (get shares-total pair),
                ;; (balance-x (balance token-x-trait))
                ;; (balance-y (balance token-y-trait))
                fee-balance-x: u0,
                fee-balance-y: u0,
                fee-to-address: (get fee-to-address pair),
                name: (get name pair),
                swapr-token: (get swapr-token pair),
              }
            )
            (ok (list fee-x fee-y))
          )
          transfer-failed-err
        )
      )
    )
  )
)
