(ns tastoids
 (:require [clojure.string :as str]))

(defn with-k [t k] (assoc t :tastoids/k k))
(defn single [t] (with-k t 1))
(def tasteless (with-k {} 0))

(defn taste "Yields a taste `of` a single thing."
  ([of] (single {of 1}))
  ([of weight] (single {of weight})))
(def like taste)

(defn cardinality [tastoid] (or (:tastoids/k tastoid) 0))

(defn un [tastoid] (let [k (cardinality tastoid)]
  (update tastoid :tastoids/k -)))
(defn dis [tastoid] (un (update-vals tastoid -)))

(defn adjuct [tastoid] (-> tastoid un dis))
(def retract adjuct)

;; ───────────── algebra  ⩐  ⁻¹  ‖ ─────────────
(defn blend "Combine two or more tastoids"
  ([t u]
(merge-with + t u))  ([t u & vs] (reduce blend (blend t u) vs)))

(defn norm [tastoid]
 (let [k (cardinality tastoid)]
  (cond (zero? k) tasteless
        (= 1 k) tastoid
        :else (-> tastoid (update-vals #(double (/ % k))) (with-k 1)
        ))))
(def squash norm)

;; ───────────── playground ─────────────

(defn echo [x] (println x) x)

(defn demo []
  (println "Hello, Tastoids!\n")
  (let [apples  (-> (like "apples")  echo)
        oranges (-> (like "oranges") echo)
        mix     (-> (blend apples oranges) echo)]
    (println "\nSquash to an average of …")
    (-> (squash mix) echo)

    (println "\nBlend is also invertible!  blend(mix, retract(oranges)) ⇒ like(apples)")
    (-> (blend mix (retract oranges)) echo)

    (println "\n\"Blue Blue Brown Blue\" |> split |> like |> reduce(blend)")
    (print "↪ ")
    (->> (str/split "Blue Blue Brown Blue" #" ")
         (map like)
         (reduce blend)
         echo
         norm
         echo)
    (println "\nHave fun!")))

(defn -main [& _] (demo))
(demo)
