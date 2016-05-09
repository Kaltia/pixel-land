(import pygame)

(defmacro rule [key pred &rest expr] `(fn [event state] (if (unquote pred)
                         [(unquote key) ~(nth expr 0)]
                         ~(lif (nth expr 1)
                               [key (nth expr 1)]
                               nil))))

;; Impure function - merge dict2 onto dict1
(defn merge_dicts [dict1 dict2]
  (do
   (.update dict1 dict2)
   dict1))

(defn list-to-dict [func]
  (defn wrap [&rest args]
    (dict
     (filter (fn [e] (do (if e (print e))
                         (not (nil? e))))
             (apply func args)))))


;; Get the base state -  prefered this way instead setv function
(defn init []
  {
       'screen (pygame.display.set_mode [400 300]) ;; Set the window size
       'fondo (pygame.image.load "./assets/img/snow-background.png")
       'is_blue True
       'limit False  ;; Set to true only if you close the window
       'color_rect [0 128 255] ;; Color of the rect
       'rect_instance (.Rect pygame 30 150 60 60) ;; Rect that will be drawn
       'clock (pygame.time.Clock)
       'offset-y 0
       'jump False
})


(defmacro regulation [&rest args] `(defn updates [] (unquote args)))
(defmacro draw [&rest args]
  `(defn painting [state]
     (setv strokes ~args)
     (for [view strokes]

       (apply (get view 1) (map (fn [key] (get state key)) (get view 0)))

       ))
  )


;;
(defmacro brushstroke [req stroke]
  `(, '(~@req) (fn [~@req] ~stroke)))

(regulation
   ;; Verify if the close button was pushed
   (rule 'limit (and (not (nil? event))
                     (= event.type pygame.QUIT)) True)
   (rule 'color_rect    (get state 'is_blue) [0 128 255] [255 100 0])
   (rule 'rect_instance (nil? event) (do
                                        (setv rect (.copy (get state 'rect_instance)))
                                        (setv rect.x (+ rect.x 1))
                                        (setv rect.y (+ rect.y (get state 'offset-y)))
                                        rect))

   (rule 'rect_instance (and (nil? event) (>= (do (setv rect (get state 'rect_instance)) rect.x) 400) )
         (do
          (setv rect (.copy (get state 'rect_instance)))
          (setv rect.x -60)
          rect))

   (rule 'is_blue (and
                   (not (nil? event))
                   (= event.type pygame.KEYDOWN)
                   (= event.key pygame.K_SPACE)) (not (get state 'is_blue)))

   (rule 'jump (and
                (not (nil? event))
                (= (get state 'offset-y) 0)
                (= event.type pygame.KEYDOWN)
                (= event.key pygame.K_SPACE)) True)


   (rule 'jump (and (nil? event)
                    (>= (get state 'offset-y) 10)) False)
   (rule 'offset-y (and (nil? event)
                        (get state 'jump)
                        (= (get state 'offset-y) 0)) -1)

   (rule 'offset-y (and (nil? event) (<= (get state 'offset-y) -10)) 1)

   (rule 'offset-y (and (nil? event)
                    (get state 'jump)
                    (<= (get state 'offset-y) -1)
                    (>= (get state 'offset-y) -10))   (- (get state  'offset-y) 1))

   (rule 'offset-y (and (nil? event) (>= (get state 'offset-y) 10)) 0)

   (rule 'offset-y (and
                    (nil? event)
                    (get state 'jump)
                    (>= (get state 'offset-y) 1)
                    (<= (get state 'offset-y) 10)) (+ (get state 'offset-y) 1))
   )


;; Return
(with-decorator list-to-dict (defn update [event state]
  (map (fn [f]  (apply f [event state])) (updates))))

(draw
 (brushstroke [screen fondo]
              (.blit screen fondo '(0 0)))
 (brushstroke [screen color_rect rect_instance]
              (pygame.draw.rect screen color_rect rect_instance))
 )

(defmain [&rest args]
  (do
   (.init pygame)
   (setv state (init))
   (while (not (get state 'limit))
     (do
      (.tick (get state 'clock) 60)
      (for [event (pygame.event.get)]
        (merge_dicts state (update event state))
        (else (merge_dicts state (update nil state))))
      (painting state)
      (pygame.display.flip)))))
