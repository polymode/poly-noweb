;;; poly-noweb.el --- Polymode for noweb -*- lexical-binding: t -*-
;;
;; Author: Vitalie Spinu
;; Maintainer: Vitalie Spinu
;; Copyright (C) 2013-2018 Vitalie Spinu
;; Version: 0.1
;; Package-Requires: ((emacs "25") (polymode "0.1"))
;; URL: https://github.com/polymode/poly-noweb
;; Keywords: languages, multi-modes
;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This file is *NOT* part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

(require 'polymode)

(defvaralias 'noweb-code-mode 'polymode-default-inner-mode)

(defun poly-noweb-mode-matcher ()
  "Match mode of the noweb chunk.
There are several ways to specify noweb chunk mode (from highest
to lowest priority):
 1. (lang-name) after the chunk head (nw2md spec, e.g. <<name>>= (bash))
 2. short mode name preceded by a period (e.g. <<name.bash>>=)
 3. extension of the file name is looked in `auto-mode-alist' (e.g. <<name.cpp>>=)
 4. local value of noweb-code-mode (for compatibility with noweb-mode)
 5. local value of `polymode-default-inner-mode'
 6. `poly-fallback-mode'"
  (let ((eol (point-at-eol)))
    (or (save-excursion
          (when (and (re-search-forward ">>=" eol t)
                     (re-search-forward "(\\(.*\\))" eol t))
            (match-string-no-properties 1)))
        (save-excursion
          (when (re-search-forward "\\.\\([[:alpha:]]+\\)" eol t)
            (let ((str (match-string 1)))
              (pm-get-mode-symbol-from-name str)))))))

(defcustom  pm-inner/noweb
  (pm-inner-chunkmode :name "noweb"
                      :head-matcher (cons "^[ \t]*\\(<<\\(.*\\)>>=.*\n\\)" 1)
                      :tail-matcher (cons "^[ \t]*\\(@.*\\)$" 1))
  "Noweb static chunk.
To be used in derived polymodes when type of chunk is known in
advance."
  :group 'poly-innermodes
  :type 'object)

(defcustom  pm-inner/noweb-auto
  (pm-inner-auto-chunkmode :name "noweb-auto"
                           :head-matcher (cons "^[ \t]*\\(<<.*>>=.*\n\\)" 1)
                           :tail-matcher (cons "^[ \t]*\\(@.*\\)$" 1)
                           :mode-matcher #'poly-noweb-mode-matcher
                           :can-overlap t)
  "Noweb auto chunk.
See `poly-noweb-mode-matcher' for how mode of the chunk is
detected."
  :group 'poly-innermodes
  :type 'object)

(defcustom pm-inner/noweb-inline-code
  (pm-inner-chunkmode :name "noweb-inline-code"
                      :head-matcher "\\[\\["
                      :tail-matcher "\\]\\]"
                      :head-mode 'host
                      :tail-mode 'host)
  "Noweb inline code of the form [[some + code]].
Code is rendered in the mode specified by the value of
`polymode-default-inner-mode' (or `noweb-code-mode'). If nil or
not a function, use `poly-fallback-mode'."
  :group 'poly-innermodes
  :type 'object)

(defcustom pm-host/latex-for-noweb
  (clone pm-host/latex
         :name "latex-for-noweb"
         :protect-font-lock t
         :protect-syntax t
         :protect-indent t)
  "LaTeX host for noweb."
  :group 'pm-innermoes
  :type 'object)

(defcustom pm-poly/noweb
  (clone pm-poly/latex
         :name "noweb"
         :hostmode 'pm-host/latex-for-noweb
         :innermodes '(pm-inner/noweb-auto pm-inner/noweb-inline-code)
         :exporters '(pm-exporter/latexmk
                      pm-exporter/pdflatex
                      pm-exporter/lualatex
                      pm-exporter/xelatex)
         :keylist '(("<" . poly-noweb-electric-<)))
  "Noweb polymode configuration."
  :group 'polymodes
  :type 'object)

;;;###autoload (autoload 'poly-noweb-mode "poly-noweb")
(define-polymode poly-noweb-mode pm-poly/noweb)
(add-to-list 'auto-mode-alist '("\\.nw$" . poly-noweb-mode))

(defun poly-noweb-electric-< (arg)
  "Auto insert noweb chunk if at bol followed by white space.
If given an numerical argument, it simply insert `<'. Otherwise,
if at the beginning of a line in a host chunk insert \"<<>>=\", a
closing \"@\" and a newline if necessary."
  (interactive "P")
  (if (or arg (car (pm-innermost-span)))
      (self-insert-command (if (numberp arg) arg 1))
    (if (not (looking-back "^[ \t]*"))
        (self-insert-command 1)
      (insert "<<")
      (save-excursion
        (insert ">>=\n\n@ ")
        (unless(looking-at "\\s *$")
          (newline)))
      (ess-noweb-update-chunk-vector))))

(defcustom pm-exporter/pdflatex
  (pm-shell-exporter :name "pdflatex"
                     :from
                     '(("latex" "\\.tex\\'" "LaTeX" "pdflatex -jobname %b %t %i"))
                     :to
                     '(("pdf"   "pdf"  "PDF" ""))
                     :quote t)
  "Shell pdflatex exporter."
  :group 'polymode-export
  :type 'object)

(defcustom pm-exporter/lualatex
  (pm-shell-exporter :name "LuaLaTeX"
                     :from
                     '(("latex" "\\.tex\\'" "LuaLaTeX" "lualatex -jobname %b %t %i"))
                     :to
                     '(("pdf"   "pdf"  "PDF" ""))
                     :quote t)
  "Shell pdflatex exporter."
  :group 'polymode-export
  :type 'object)

(defcustom pm-exporter/xelatex
  (pm-shell-exporter :name "XeLaTeX"
                     :from
                     '(("latex" "\\.tex\\'" "XeLaTeX" "xelatex -jobname %b %t %i"))
                     :to
                     '(("pdf"   "pdf"  "PDF" ""))
                     :quote t)
  "Shell pdflatex exporter."
  :group 'polymode-export
  :type 'object)

(defcustom pm-exporter/latexmk
  (pm-shell-exporter :name "latexmk"
                     :from
                     '(("latex" "\\.tex\\'" "LaTeX(MK)" "latexmk -jobname=%b %t %i"))
                     :to
                     '(("pdf"        "pdf"  "latex" "-pdf")
                       ("xelatex"    "pdf"  "xe" "-xelatex")
                       ("lualatex"   "pdf"  "lua" "-lualatex")
                       ("ps"         "ps"  "latex" "-ps")
                       ("dvi"        "dvi"  "latex" "-dvi"))
                     :quote t)
  "Shell latexmk dvi, ps and pdf exporter."
  :group 'polymode-export
  :type 'object)

(provide 'poly-noweb)
;;; poly-noweb.el ends here
