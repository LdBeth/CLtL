;;; Here is the program that generated the PostScript code for the graphs
;;; shown in figures~\ref{IDENTITY-PLOT} through~\ref{LAST-PLOT}.  It
;;; contains a mixture of fairly general mechanisms and {\it ad hoc}
;;; kludges for plotting functions of a single complex argument while
;;; gracefully handling extremely large and small values, branch cuts,
;;; singularities, and periodic behavior.  The aim was to provide a simple
;;; user interface that would not require the caller to provide special
;;; advice for each function to be plotted.  The file for
;;; figure~\ref{IDENTITY-PLOT}, for example, was generated by the call
;;; \cd{(picture~'identity)}, which resulted in the writing of a file
;;; named \cd{identity-plot.ps}.
;;;
;;; The program assumes that any periodic behavior will have a period that
;;; is a multiple of $2\pi$; that branch cuts will fall along the real or
;;; imaginary axis; and that singularities or very large or small values
;;; will occur only at the origin, at $\pm 1$ or $\pm {\it i}$, or on the
;;; boundaries of the annuli (particularly those with radius $\pi/2$ or
;;; $\pi$).  The central function is \cd{parametric-path}, which accepts
;;; four arguments: two real numbers that are the endpoints of an interval
;;; of real numbers, a function that maps this interval into a path in the
;;; complex plane, and the function to be plotted; the task of
;;; \cd{parametric-path} is to generate PostScript code (a series of
;;; \cd{lineto} operations) that will plot an approximation to the image
;;; of the parametric path as transformed by the function to be plotted.
;;; Each of the functions \cd{hline}, \cd{vline}, \cd{-hline},
;;; \cd{-vline}, \cd{radial}, and \cd{circumferential} takes appropriate
;;; parameters and returns a function suitable for use as the third
;;; argument to \cd{parametric-path}.  There is some code that defends
;;; against errors (by using \cd{ignore-errors}) and against certain
;;; peculiarities of IEEE floating-point arithmetic (the code that checks
;;; for not-a-number (NaN) results).
;;;
;;; The program is offered here without further comment or apology.
;;;
; (picture 'identity)
; (picture 'exp)
; (picture 'minus-over-plus)
; (picture 'sin)
; (picture 'cos)
; (picture 'tan)
; (picture 'sinh)
; (picture 'cosh)
; (picture 'tanh)
; (picture 'sqrt-one-minus-sq)
; (picture 'series)
(eval-when (:compile-toplevel :load-toplevel :execute)
  (setq *read-default-float-format* 'double-float))

(defparameter units-to-show 4.1)
(defparameter text-width-in-picas 28.0)
(defparameter device-pixels-per-inch 300)
(defparameter pixels-per-unit
  (* (/ (/ text-width-in-picas 6)
        (* units-to-show 2))
     device-pixels-per-inch))

(defparameter big (sqrt (sqrt most-positive-single-float)))
(defparameter tiny (sqrt (sqrt least-positive-single-float)))

(defparameter path-really-losing 1000.0)
(defparameter path-outer-limit (* units-to-show (sqrt 2) 1.1))
(defparameter path-minimal-delta (/ 10 pixels-per-unit))
(defparameter path-outer-delta (* path-outer-limit 0.3))
(defparameter path-relative-closeness 0.00001)
(defparameter back-off-delta 0.0005)

(defun comment-line (stream &rest stuff)
  (format stream "~%% ")
  (apply #'format stream stuff)
  (format t "~%% ")
  (apply #'format t stuff))

(defun parametric-path (from to paramfn plotfn)
  (assert (and (plusp from) (plusp to)))
  (flet ((domainval (x) (funcall paramfn x))
         (rangeval (x) (funcall plotfn (funcall paramfn x)))
         (losing (x) (or (null x)
                         (/= (realpart x) (realpart x))  ;NaN?
                         (/= (imagpart x) (imagpart x))  ;NaN?
                         (> (abs (realpart x)) path-really-losing)
                         (> (abs (imagpart x)) path-really-losing))))
    (when (> to 1000.0)
      (let ((f0 (rangeval from))
            (f1 (rangeval (+ from 1)))
            (f2 (rangeval (+ from (* 2 pi))))
            (f3 (rangeval (+ from 1 (* 2 pi))))
            (f4 (rangeval (+ from (* 4 pi)))))
        (flet ((close (x y)
                 (or (< (careful-abs (- x y)) path-minimal-delta)
                     (< (careful-abs (- x y))
                        (* (+ (careful-abs x) (careful-abs y))
                           path-relative-closeness)))))
          (when (and (close f0 f2)
                     (close f2 f4)
                     (close f1 f3)
                     (or (and (close f0 f1)
                              (close f2 f3))
                         (and (not (close f0 f1))
                              (not (close f2 f3)))))
            (format t "~&Periodicity detected.")
            (setq to (+ from (* (signum (- to from)) 2 pi)))))))
     (let ((fromrange (ignore-errors (rangeval from)))
          (torange (ignore-errors (rangeval to))))
      (if (losing fromrange)
          (if (losing torange)
              '()
              (parametric-path (back-off from to) to paramfn plotfn))
          (if (losing torange)
              (parametric-path from (back-off to from) paramfn plotfn)
              (expand-path (refine-path (list from to) #'rangeval)
                           #'rangeval))))))

(defun back-off (point other)
  (if (or (> point 10.0) (< point 0.1))
      (let ((sp (sqrt point)))
        (if (or (> point sp other) (< point sp other))
            sp
            (* sp (sqrt other))))
      (+ point (* (signum (- other point)) back-off-delta))))

(defun careful-abs (z)
  (cond ((or (> (realpart z) big)
             (< (realpart z) (- big))
             (> (imagpart z) big)
             (< (imagpart z) (- big)))
         big)
        ((complexp z) (abs z))
        ((minusp z) (- z))
        (t z)))

(defparameter max-refinements 5000)

(defun refine-path (original-path rangevalfn)
  (flet ((rangeval (x) (funcall rangevalfn x)))
    (let ((path original-path))
      (do ((j 0 (+ j 1)))
          ((null (rest path)))
        (when (zerop (mod (+ j 1) max-refinements))
              (break "Runaway path"))
        (let* ((from (first path))
               (to (second path))
               (fromrange (rangeval from))
               (torange (rangeval to))
               (dist (careful-abs (- torange fromrange)))
               (mid (* (sqrt from) (sqrt to)))
               (midrange (rangeval mid)))
          (cond ((or (and (far-out fromrange) (far-out torange))
                     (and (< dist path-minimal-delta)
                          (< (abs (- midrange fromrange))
                             path-minimal-delta)
                          ;; Next test is intentionally asymmetric to
                          ;;  avoid problems with periodic functions.
                          (< (abs (- (rangeval (/ (+ to (* from 1.5))
                                                  2.5))
                                     fromrange))
                             path-minimal-delta)))
                 (pop path))
                ((= mid from) (pop path))
                ((= mid to) (pop path))
                (t (setf (rest path) (cons mid (rest path)))))))))
  original-path)

(defun expand-path (path rangevalfn)
  (flet ((rangeval (x) (funcall rangevalfn x)))
    (let ((final-path (list (rangeval (first path)))))
      (do ((p (rest path) (cdr p)))
          ((null p)
           (unless (rest final-path)
             (break "Singleton path"))
           (reverse final-path))
        (let ((v (rangeval (car p))))
          (cond ((and (rest final-path)
                      (not (far-out v))
                      (not (far-out (first final-path)))
                      (between v (first final-path)
                                 (second final-path)))
                 (setf (first final-path) v))
                ((null (rest p))   ;Mustn't omit last point
                 (push v final-path))
                ((< (abs (- v (first final-path))) path-minimal-delta))
                ((far-out v)
                 (unless (and (far-out (first final-path))
                              (< (abs (- v (first final-path)))
                                 path-outer-delta))
                   (push (* 1.01 path-outer-limit (signum v))
                         final-path)))
                (t (push v final-path))))))))

(defun far-out (x)
  (> (careful-abs x) path-outer-limit))

(defparameter between-tolerance 0.000001)

(defun between (p q r)
  (let ((px (realpart p)) (py (imagpart p))
        (qx (realpart q)) (qy (imagpart q))
        (rx (realpart r)) (ry (imagpart r)))
    (and (or (<= px qx rx) (>= px qx rx))
         (or (<= py qy ry) (>= py qy ry))
         (< (abs (- (* (- qx px) (- ry qy))
                    (* (- rx qx) (- qy py))))
            between-tolerance))))

(defun circle (radius)
  #'(lambda (angle) (* radius (cis angle))))

(defun hline (imag)
  #'(lambda (real) (complex real imag)))

(defun vline (real)
  #'(lambda (imag) (complex real imag)))

(defun -hline (imag)
  #'(lambda (real) (complex (- real) imag)))

(defun -vline (real)
  #'(lambda (imag) (complex real (- imag))))

(defun radial (phi quadrant)
  #'(lambda (rho) (repair-quadrant (* rho (cis phi)) quadrant)))

(defun circumferential (rho quadrant)
  #'(lambda (phi) (repair-quadrant (* rho (cis phi)) quadrant)))

;;; Quadrant is 0, 1, 2, or 3, meaning I, II, III, or IV.

(defun repair-quadrant (z quadrant)
  (complex (* (+ (abs (realpart z)) tiny)
              (case quadrant (0 1.0) (1 -1.0) (2 -1.0) (3 1.0)))
           (* (+ (abs (imagpart z)) tiny)
              (case quadrant (0 1.0) (1 1.0) (2 -1.0) (3 -1.0)))))

(defun clamp-real (x)
  (if (far-out x)
      (* (signum x) path-outer-limit)
      (round-real x)))

(defun round-real (x)
  (/ (round (* x 10000.0)) 10000.0))

(defun round-point (z)
  (complex (round-real (realpart z)) (round-real (imagpart z))))

(defparameter hiringshade 0.97)
(defparameter loringshade 0.45)

(defparameter ticklength 0.12)
(defparameter smallticklength 0.09)

;;; This determines the pattern of lines and annuli to be drawn.
(defun moby-grid (&optional (fn 'sqrt) (stream t))
  (comment-line stream "Moby grid for function ~S" fn)
  (shaded-annulus 0.25 0.5 4 hiringshade loringshade fn stream)
  (shaded-annulus 0.75 1.0 8 hiringshade loringshade fn stream)
  (shaded-annulus (/ pi 2) 2.0 16 hiringshade loringshade fn stream)
  (shaded-annulus 3 pi 32 hiringshade loringshade fn stream)
  (moby-lines :horizontal 1.0 fn stream)
  (moby-lines :horizontal -1.0 fn stream)
  (moby-lines :vertical 1.0 fn stream)
  (moby-lines :vertical -1.0 fn stream)
  (let ((tickline 0.015)
        (axisline 0.008))
    (flet ((tick (n) (straight-line (complex n ticklength)
                                    (complex n (- ticklength))
                                    tickline
                                    stream))
           (smalltick (n) (straight-line (complex n smallticklength)
                                         (complex n (- smallticklength))
                                         tickline
                                         stream)))
      (comment-line stream "Real axis")
      (straight-line #c(-5 0) #c(5 0) axisline stream)
      (dotimes (j (floor units-to-show))
        (let ((q (+ j 1))) (tick q) (tick (- q))))
      (dotimes (j (floor units-to-show (/ pi 2)))
        (let ((q (* (/ pi 2) (+ j 1))))
          (smalltick q)
          (smalltick (- q)))))
    (flet ((tick (n) (straight-line (complex ticklength n)
                                    (complex (- ticklength) n)
                                    tickline
                                    stream))
           (smalltick (n) (straight-line (complex smallticklength n)
                                         (complex (- smallticklength) n)
                                         tickline
                                         stream)))
      (comment-line stream "Imaginary axis")
      (straight-line #c(0 -5) #c(0 5) axisline stream)
      (dotimes (j (floor units-to-show))
        (let ((q (+ j 1))) (tick q) (tick (- q))))
      (dotimes (j (floor units-to-show (/ pi 2)))
        (let ((q (* (/ pi 2) (+ j 1))))
          (smalltick q)
          (smalltick (- q)))))))

(defun straight-line (from to wid stream)
  (format stream
      "~%newpath  ~F ~F moveto  ~F ~F lineto  ~F ~
           setlinewidth  1  setlinecap  stroke"
          (realpart from)
          (imagpart from)
          (realpart to)
          (imagpart to)
          wid))

;;; This function draws the lines for the pattern.
(defun moby-lines (orientation signum plotfn stream)
  (let ((paramfn (ecase orientation
                   (:horizontal (if (< signum 0) #'-hline #'hline))
                   (:vertical (if (< signum 0) #'-vline #'vline)))))
    (flet ((foo (from to other wid)
             (ecase orientation
               (:horizontal
                (comment-line stream
                              "Horizontal line from (~F, ~F) to (~F, ~F)"
                              (round-real (* signum from))
                              (round-real other)
                              (round-real (* signum to))
                              (round-real other)))
               (:vertical
                (comment-line stream
                              "Vertical line from (~F, ~F) to (~F, ~F)"
                              (round-real other)
                              (round-real (* signum from))
                              (round-real other)
                              (round-real (* signum to)))))
             (postscript-path
               stream
               (parametric-path from
                                to
                                (funcall paramfn other)
                                plotfn))
             (postscript-penstroke stream wid)))
      (let* ((thick 0.05)
             (thin 0.02))
        ;; Main axis
        (foo 0.5 tiny 0.0 thick)
        (foo 0.5 1.0 0.0 thick)
        (foo 2.0 1.0 0.0 thick)
        (foo 2.0 big 0.0 thick)
        ;; Parallels at 1 and -1
        (foo 2.0 tiny 1.0 thin)
        (foo 2.0 big 1.0 thin)
        (foo 2.0 tiny -1.0 thin)
        (foo 2.0 big -1.0 thin)
        ;; Parallels at 2, 3, -2, -3
        (foo tiny big 2.0 thin)
        (foo tiny big -2.0 thin)
        (foo tiny big 3.0 thin)
        (foo tiny big -3.0 thin)))))

(defun splice (p q)
  (let ((v (car (last p)))
        (w (first q)))
    (and (far-out v)
         (far-out w)
         (>= (abs (- v w)) path-outer-delta)
         ;; Two far-apart far-out points.  Try to walk around
         ;;  outside the perimeter, in the shorter direction.
         (let* ((pdiff (phase (/ v w)))
                (npoints (floor (abs pdiff) (asin .2)))
                (delta (/ pdiff (+ npoints 1)))
                (incr (cis delta)))
           (do ((j 0 (+ j 1))
                (p (list w "end splice") (cons (* (car p) incr) p)))
               ((= j npoints) (cons "start splice" p)))))))

;;; This function draws the annuli for the pattern.
(defun shaded-annulus (inner outer sectors firstshade lastshade fn stream)
  (assert (zerop (mod sectors 4)))
  (comment-line stream "Annulus ~S ~S ~S ~S ~S"
                (round-real inner) (round-real outer)
                sectors firstshade lastshade)
  (dotimes (jj sectors)
    (let ((j (- sectors jj 1)))
      (let* ((lophase (+ tiny (* 2 pi (/ j sectors))))
             (hiphase (* 2 pi (/ (+ j 1) sectors)))
             (midphase (/ (+ lophase hiphase) 2.0))
             (midradius (/ (+ inner outer) 2.0))
             (quadrant (floor (* j 4) sectors)))
        (comment-line stream "Sector from ~S to ~S (quadrant ~S)"
                      (round-real lophase)
                      (round-real hiphase)
                      quadrant)
        (let ((p0 (reverse (parametric-path midradius
                                            inner
                                            (radial lophase quadrant)
                                            fn)))
              (p1 (parametric-path midradius
                                   outer
                                   (radial lophase quadrant)
                                   fn))
              (p2 (reverse (parametric-path midphase
                                            lophase
                                            (circumferential outer
                                                             quadrant)
                                            fn)))
              (p3 (parametric-path midphase
                                   hiphase
                                   (circumferential outer quadrant)
                                   fn))
              (p4 (reverse (parametric-path midradius
                                            outer
                                            (radial hiphase quadrant)
                                            fn)))
              (p5 (parametric-path midradius
                                   inner
                                   (radial hiphase quadrant)
                                   fn))
              (p6 (reverse (parametric-path midphase
                                            hiphase
                                            (circumferential inner
                                                             quadrant)
                                            fn)))
              (p7 (parametric-path midphase
                                   lophase
                                   (circumferential inner quadrant)
                                   fn)))
          (postscript-closed-path stream
            (append
              p0 (splice p0 p1) '("middle radial")
              p1 (splice p1 p2) '("end radial")
              p2 (splice p2 p3) '("middle circumferential")
              p3 (splice p3 p4) '("end circumferential")
              p4 (splice p4 p5) '("middle radial")
              p5 (splice p5 p6) '("end radial")
              p6 (splice p6 p7) '("middle circumferential")
              p7 (splice p7 p0) '("end circumferential")
              )))
        (postscript-shade stream
                          (/ (+ (* firstshade (- (- sectors 1) j))
                                (* lastshade j))
                             (- sectors 1)))))))

(defun postscript-penstroke (stream wid)
  (format stream "~%~S setlinewidth   1 setlinecap  stroke"
          wid))

(defun postscript-shade (stream shade)
  (format stream "~%currentgray   ~S setgray   fill   setgray"
          shade))

(defun postscript-closed-path (stream path)
  (unless (every #'far-out (remove-if-not #'numberp path))
    (postscript-raw-path stream path)
    (format stream "~%  closepath")))

(defun postscript-path (stream path)
  (unless (every #'far-out (remove-if-not #'numberp path))
    (postscript-raw-path stream path)))

;;; Print a path as a series of PostScript "lineto" commands.
(defun postscript-raw-path (stream path)
  (format stream "~%newpath")
  (let ((fmt "~%  ~F ~F moveto"))
    (dolist (pt path)
      (cond ((stringp pt)
             (format stream "~%  %~A" pt))
            (t (format stream
                       fmt
                       (clamp-real (realpart pt))
                       (clamp-real (imagpart pt)))
               (setq fmt "~%  ~F ~F lineto"))))))

;;; Definitions of functions to be plotted that are not
;;; standard Common Lisp functions.

(defun one-plus-over-one-minus (x) (/ (+ 1 x) (- 1 x)))

(defun one-minus-over-one-plus (x) (/ (- 1 x) (+ 1 x)))

(defun sqrt-square-minus-one (x) (sqrt (- 1 (* x x))))

(defun sqrt-one-plus-square (x) (sqrt (+ 1 (* x x))))

;;; Because X3J13 voted for a new definition of the atan function,
;;; the following definition was used in place of the atan function
;;; provided by the Common Lisp implementation I was using.

(defun good-atan (x)
  (/ (- (log (+ 1 (* x #c(0 1))))
        (log (- 1 (* x #c(0 1)))))
     #c(0 2)))

;;; Because the first edition had an erroneous definition of atanh,
;;; the following definition was used in place of the atanh function
;;; provided by the Common Lisp implementation I was using.

(defun really-good-atanh (x)
  (/ (- (log (+ 1 x))
        (log (- 1 x)))
     2))

;;; This is the main procedure that is intended to be called by a user.
(defun picture (&optional (fn #'sqrt))
  (with-open-file (stream (concatenate 'string
                                       (string-downcase (string fn))
                                       "-plot.ps")
                          :direction :output)
    (format stream "% PostScript file for plot of function ~S~%" fn)
    (format stream "% Plot is to fit in a region ~S inches square~%"
            (/ text-width-in-picas 6.0))
    (format stream
            "%  showing axes extending ~S units from the origin.~%"
            units-to-show)
    (let ((scaling (/ (* text-width-in-picas 12) (* units-to-show 2))))
      (format stream "~%~S ~:*~S scale" scaling))
    (format stream "~%~S ~:*~S translate" units-to-show)
    (format stream "~%newpath")
    (format stream "~%  ~F ~F moveto" (- units-to-show) (- units-to-show))
    (format stream "~%  ~F ~F lineto" units-to-show (- units-to-show))
    (format stream "~%  ~F ~F lineto" units-to-show units-to-show)
    (format stream "~%  ~F ~F lineto" (- units-to-show) units-to-show)
    (format stream "~%  closepath")
    (format stream "~%clip")
    (moby-grid fn stream)
    (format stream
            "~%% End of PostScript file for plot of function ~S"
            fn)
    (terpri stream)))