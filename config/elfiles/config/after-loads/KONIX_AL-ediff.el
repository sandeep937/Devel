;;; 700-KONIX_ediff.el ---

;; Copyright (C) 2012  konubinix

;; Author: konubinix <konubinixweb@gmail.com>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(setq-default ediff-ignore-similar-regions t)
;; replace the ediff-patch-file-internal function with the one that does not
;; edit the orignal file by default
(eval-after-load "ediff"
  '(progn
	 (set-face-attribute 'ediff-current-diff-B
						 nil
						 :background "yellow"
						 )
	 )
  )
(eval-after-load "ediff-ptch"
  '(progn
	 (defalias 'ediff-patch-file-internal 'konix/ediff-patch-file-internal-for-viewing)
	 )
  )

(provide '700-KONIX_ediff)
;;; 700-KONIX_ediff.el ends here
