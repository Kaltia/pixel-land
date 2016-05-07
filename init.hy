(import pygame)

;; Impure function - merge dict2 onto dict1
(defn merge_dicts [dict1 dict2]
  (do
   (.update dict1 dict2)
   dict1))

(defn list-to-dict [func]
  (defn wrap [&rest args]
    (dict
     (filter (fn [e] (not (nil? e)))
             (map pair-or-nil (apply func args))))))

(defn pair-or-nil [element]
  (do
   (print element)
   (cond
    [(get element 0) [(get element 1) (get element 2)]]
    [(not (nil? (nth element 3))) [(get element 1) (nth element 3)]]
    [True  nil]
   )))


;; Get the base state -  prefered this way instead setv function
(defn init []
  {
       'screen (pygame.display.set_mode [400 300]) ;; Set the window size
       'fondo (pygame.image.load "./assets/img/snow-background.png")
       'is_blue True ;; Verify is the actual color is blue
       'limit False  ;; Set to true only if you close the window
       'color_rect [0 128 255] ;; Color of the rect
       'rect_instance (.Rect pygame 30 30 60 60) ;; Rect that will be drawn
       'clock (pygame.time.Clock)
   })


;; Return
(with-decorator list-to-dict (defn update [event state]
  [
   ;; Verify if the close button was pushed
   [(and (not (nil? event))
         (!= (get state 'limit) True)
         (= event.type pygame.QUIT)) 'limit True ]

   ;; Verify if the color is blue else return orange color
   [(get state 'is_blue) 'color_rect [0 128 255] [255 100 0]]

   ;; Change the color if the key space was typed
   [(and
     (not (nil? event))
     (= event.type pygame.KEYDOWN)
     (= event.key pygame.K_SPACE)) 'is_blue (not (get state 'is_blue))]

   [(nil? event) 'rect_instance (if (nil? event)( do
                                  (setv rect (get state 'rect_instance))
                                  (setv rect.x (+ rect.x 1))
                                  rect)
                                  )]
   ]))

(defn draw [state]
  (do
   (.blit (get state 'screen) (get state 'fondo) '(0 0))
   (pygame.draw.rect
    (get state 'screen)
    (get state 'color_rect)
    (get state 'rect_instance)))) ;; Draw the rect

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
      (draw state)
      (pygame.display.flip)))))
