; ~/~ begin <<docs/day05.md#src/viz-day05.scm>>[init]
(import (rnrs (6))
        (srfi srfi-13)   ; string library
        (ice-9 format))

(define-syntax include
  (lambda (x)
    (define read-file
      (lambda (fn k)
        (let ([p (open-input-file fn)])
          (let f ([x (read p)])
            (if (eof-object? x)
                (begin (close-port p) '())
                (cons (datum->syntax k x) (f (read p))))))))
    (syntax-case x ()
      [(k filename)
       (let ([fn (syntax->datum #'filename)])
         (with-syntax ([(expr ...) (read-file fn #'k)])
           #'(begin expr ...)))])))

; ~/~ begin <<docs/svg-gen.md#strip-css-comments>>[init]
(define (strip-css-comments text)
  (let loop ((result '())
             (text text))
    (if (zero? (string-length text))
      (apply string-append (reverse result))
      (let* ((a (string-contains text "/*"))
             (b (if a (string-contains text "*/" (+ a 2)) #f))
             (chunk (if (and a b) (substring text 0 a) text))
             (remain (if (and a b) (substring text (+ b 2) (string-length text)) "")))
        (loop (cons chunk result) remain)))))
; ~/~ end

(define-record-type range
  (fields start stop))

(define-record-type mapping
  (fields from to segments))

(define-record-type almanak
  (fields seeds maps))

(define almanak (include "src/day05-data.scm"))

(define (plot-segment r o)
  (let* ((a (* 1e-9 (range-start r)))
         (b (* 1e-9 (range-stop r)))
         (c (* 1e-9 (+ (range-stop r) o)))
         (d (* 1e-9 (+ (range-start r) o))))
  `((g class: "segment")
      (path d: ,(format #f "M ~a ~a L ~a ~a C ~a ~a, ~a ~a, ~a ~a L ~a ~a C ~a ~a, ~a ~a, ~a ~a"
                        0.0 a 0.0 b 0.5 b 0.5 c 1.0 c 1.0 d 0.5 d 0.5 a 0.0 a)
            class: "fill"
      /)
      (path d: ,(format #f "M ~a ~a C ~a ~a ~a ~a ~a ~a"
                        0.0 b 0.5 b 0.5 c 1.0 c)
            class: "line"
      /)
      (path d: ,(format #f "M ~a ~a C ~a ~a ~a ~a ~a ~a"
                        1.0 d 0.5 d 0.5 a 0.0 a)
            class: "line"
      /)
    (/g))))

(define (flatmap f . args)
  (apply append (apply map f args)))

(define (range n)
  (do ((x 0 (+ x 1))
       (r '() (cons x r)))
      ((= x n) (reverse r))))

(define (plot-mapping m n)
  `((g class: "map" transform: ,(format #f "translate(~a 0)" n))
    ,@(flatmap (lambda (s) (plot-segment (car s) (cdr s))) (mapping-segments m))
    (/g)))

(define style-sheet "
  .segment .line {
    fill: none;
    stroke: black;
    stroke-width: 0.005;
    opacity: 0.4;
  }
  .segment .fill {
    fill: hsl(0deg, 60%, 20%);
    opacity: 0.15;
  }
  .ruler {
    stroke: black;
    stroke-width: 0.01;
  }
  .no0 { --hue: 0deg; }
  .no1 { --hue: 30deg; }
  .no2 { --hue: 60deg; }
  .no3 { --hue: 90deg; }
  .no4 { --hue: 120deg; }
  .no5 { --hue: 150deg; }
  .no6 { --hue: 180deg; }
  .no7 { --hue: 210deg; }
  .no8 { --hue: 240deg; }
  .no9 { --hue: 270deg; }
  .seed {
    stroke: hsl(var(--hue), 60%, 60%);
    stroke-width: 0.1;
    filter: hue-rotate(-20deg) drop-shadow(0px 0px 0.02px #888888);
  }
  text {
    font-size: 30px;
    font-family: 'Monofur Nerd Font';
  }
  ")

(define names
  (let ((m (almanak-maps almanak)))
    (cons (mapping-from (car m))
          (map mapping-to m))))

(define (plot-seed s no)
  `((g class: ,(format #f "ranges no~a" no))
    ,@(flatmap (lambda (rs n)
                 (map (lambda (r)
                        `(line class: "seed" x1: ,n
                               y1: ,(* 1e-9 (range-start r))
                               y2: ,(* 1e-9 (range-stop r)) x2: ,n /)) rs))
           s (range 8))
    (/g)))

`((?xml version: "1.0" standalone: "no" ?)
  (svg viewBox: "0 0 1580 1050"
       xmlns: "http://www.w3.org/2000/svg"
       xmlns:xlink: "http://www.w3.org/1999/xlink")
    (style) ,style-sheet (/style)
    (g transform: "scale(200 200) translate(0.3 0.5)")
    ,@(flatmap plot-mapping (almanak-maps almanak)
               (range (length (almanak-maps almanak))))
    ,@(map (lambda (n) `(line class: "ruler" x1: ,n y1: -0.1  y2: 4.4 x2: ,n /)) (range 8))
    ,@(flatmap plot-seed (almanak-seeds almanak) (range (length (almanak-seeds almanak))))
    (/g)
    (g transform: "translate(60 100)")
    ,@(flatmap (lambda (n t) `((text text-anchor: "middle" x: ,(* 200 n) y: -40) ,t (/text))) (range 8) names)
    (/g)
  (/svg))
; ~/~ end
