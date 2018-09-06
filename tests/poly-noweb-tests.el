
(require 'polymode-test-utils)
(require 'poly-noweb)

(ert-deftest poly-noweb/changes ()
  (pm-test-poly-lock poly-noweb-mode "hello.nw"
    ((delete-include ("#include" beg))
     (kill-word 1))
    ((delete-python-comment ("'''" end))
     (backward-delete-char 1))
    ((insert-return ("return 0" beg))
     (insert "return 0;\n"))))


(ert-deftest poly-noweb/spans-at-borders ()
  (pm-test-run-on-file poly-noweb-mode "hello.nw"
    (pm-map-over-spans
     (lambda (span)
       (let* ((sbeg (nth 1 span))
              (send (nth 2 span))
              (range1 (pm-innermost-range sbeg))
              (range2 (pm-innermost-range send)))
         (should (eq sbeg (car range1)))
         (should (eq send (cdr range1)))
         (unless (eq send (point-max))
           (should (eq send (car range2)))))))))

(ert-deftest poly-noweb/modes ()
  ;; fixme: in tests file locals are not hacked in indirect buffers for some
  ;; reason
  (let ((polymode-default-inner-mode 'pascal-mode))
    (pm-test-run-on-file poly-noweb-mode "hello.nw"
      (goto-char (point-min))
      (re-search-forward "return 0;")
      (pm-switch-to-buffer)
      (should (eq major-mode 'c-mode))
      (re-search-forward "hello.py")
      (pm-switch-to-buffer)
      (should (eq major-mode 'poly-head-tail-mode))
      (re-search-forward "'''")
      (pm-switch-to-buffer)
      (should (eq major-mode 'python-mode))
      (re-search-forward "\\*)")
      (pm-switch-to-buffer)
      (should (eq major-mode 'pascal-mode))
      (re-search-forward "hello.perl")
      (pm-switch-to-buffer)
      (should (eq major-mode 'poly-head-tail-mode))
      (re-search-forward "=cut")
      (pm-switch-to-buffer)
      (should (eq major-mode 'perl-mode))
      (re-search-forward "license>>= ")
      (pm-switch-to-buffer)
      (should (eq major-mode 'poly-head-tail-mode))
      (forward-line 1)
      (pm-switch-to-buffer)
      (should (eq major-mode 'text-mode)))))

(ert-deftest poly-noweb/spans-at-narrowed-borders ()
  (pm-test-run-on-file poly-noweb-mode "hello.nw"
    (pm-map-over-spans
     (lambda (span)
       (pm-with-narrowed-to-span span
         (let* ((range1 (pm-innermost-range (point-min)))
                (range2 (pm-innermost-range (point-max))))
           (should (eq (car range1) (point-min)))
           (should (eq (cdr range1) (point-max)))
           (should (eq (car range2) (point-min)))
           (should (eq (cdr range2) (point-max)))))))))

(ert-deftest poly-noweb/spans-at-point-max ()
  (pm-test-run-on-file poly-noweb-mode "hello.nw"
    (goto-char (point-max))
    (pm-switch-to-buffer)

    (let ((span (pm-innermost-span (point-max))))
      (should (eq (car span) 'body))
      (should (eq (nth 2 span) (point-max)))
      (delete-region (nth 1 span) (nth 2 span)))

    (let ((span (pm-innermost-span (point-max))))
      (should (eq (car span) 'head))
      (should (eq (nth 2 span) (point-max)))
      (delete-region (nth 1 span) (nth 2 span)))

    (let ((span (pm-innermost-span (point-max))))
      (should (eq (car span) 'nil))
      (should (eq (nth 2 span) (point-max)))
      (delete-region (nth 1 span) (nth 2 span)))

    (let ((span (pm-innermost-span (point-max))))
      (should (eq (car span) 'tail))
      (should (eq (nth 2 span) (point-max)))
      (delete-region (nth 1 span) (nth 2 span)))

    (let ((span (pm-innermost-span (point-max))))
      (should (eq (car span) 'body))
      (should (eq (nth 2 span) (point-max)))
      (delete-region (nth 1 span) (nth 2 span)))))

(ert-deftest poly-noweb/inline-code ()
  (let ((noweb-code-mode 'pascal-mode))
    (pm-test-run-on-string 'poly-noweb-mode
      "Function [[checkExpectPasses]] runs a [[check-expect]]
test and tells if the test passes. If the test does not pass,
[[checkExpectPasses]] also writes an error
message. [[checkExpectPasses]]"
      (goto-char 11)
      (pm-switch-to-buffer)
      (should (eq major-mode 'latex-mode))
      (goto-char 12)
      (pm-switch-to-buffer)
      (should (eq major-mode 'pascal-mode))
      (goto-char 52)
      (pm-switch-to-buffer)
      (should (eq major-mode 'pascal-mode))
      (goto-char 119)
      (pm-switch-to-buffer)
      (should (eq major-mode 'latex-mode))
      (goto-char 66)
      (pm-switch-to-buffer)
      (should (eq major-mode 'latex-mode))
      (goto-char 125)
      (pm-switch-to-buffer)
      (should (eq major-mode 'pascal-mode))
      (goto-char 183)
      (pm-switch-to-buffer)
      (should (eq major-mode 'pascal-mode))
      (goto-char 189)
      (pm-switch-to-buffer)
      (should (eq major-mode 'latex-mode)))))

(ert-deftest poly-noweb/indentation ()
  (let ((polymode-default-inner-mode 'pascal-mode))
    (pm-test-indentation poly-noweb-mode "hello.nw")))
