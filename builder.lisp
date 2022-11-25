(in-package :cl-user)
(load "@asdf@")

(defun load-systems ()
  (handler-case
      (let ((systems (uiop:getenv "systems")))
        (dolist (s (uiop:split-string systems :separator " "))
          (asdf:load-system s)))
    (error (c)
      (format t "~&BUILD FAILED: ~S: ~A~%" (class-name (class-of c)) c)
      (describe c)
      (uiop:quit 1)))
  (uiop:quit 0))

(load-systems)
