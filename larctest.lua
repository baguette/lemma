;; Testing :)

(def hello (name)
   (prn "hello, " name))

(let x 42.0
   (prn "The meaning of life is " x))

(if (is ch #\newline)
    (prn "Found a newline")
    (prn "Not a newline"))
   
#| Again,
   this is just a test.
|#

(getf alist 'item)
(setf alist `(item ,x))

#;(def test ()
  (prn "Test code"))

[error test]
