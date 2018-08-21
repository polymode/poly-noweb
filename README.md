<p align="center">
  <!-- <a href="https://travis-ci.org/polymode/poly-noweb"><img src="https://travis-ci.org/polymode/poly-noweb.svg?branch=master" alt="Travis Build"/></a> -->
  <a href="http://www.gnu.org/licenses/gpl-3.0.txt"><img src="https://img.shields.io/badge/license-GPL_3-green.svg" alt="License GPL 3" /></a>
  <a href="https://melpa.org/#/poly-noweb"><img alt="MELPA" src="https://melpa.org/packages/poly-noweb-badge.svg"/></a>
  <a href="https://stable.melpa.org/#/poly-noweb"><img alt="MELPA Stable" src="https://stable.melpa.org/packages/poly-noweb-badge.svg"/></a>
</p>


This package provides `poly-noweb-mode` which is a [polymode](https://polymode.github.io) for [noweb](https://en.wikipedia.org/wiki/Noweb).

Detection of major in noweb chunks follows the following rules:

 1. (lang-name) after the chunk head (nw2md spec, e.g. <<name>>= (bash))
 2. short mode name preceded by a period (e.g. <<name.bash>>=)
 3. extension of the file name is looked in `auto-mode-alist` (e.g. <<name.cpp>>=)
 4. local value of noweb-code-mode (for compatibility with noweb-mode)
 5. local value of `poly-inner-mode'
 6. `poly-fallback-mode'



