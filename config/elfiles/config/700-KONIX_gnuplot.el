;;; 700-KONIX_gnuplot-mode.el ---

;; Copyright (C) 2012  sam

;; Author: sam <sam@konubinix>
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

(defvar konix/gnuplot/arguments "smooth cspline with lines")
(defun konix/gnuplot-mode-hook()
  (auto-complete-mode t)
  (setq ac-sources
		'(
		  ac-source-files-in-current-dir ;eshell
		  ac-source-filename ; eshell
		  ac-source-dabbrev
		  )
		)
  (define-key gnuplot-mode-map "\C-xp" 'konix/gnuplot-mode-map)
  (define-prefix-command 'konix/gnuplot-mode-map)
  (define-key konix/gnuplot-mode-map "l" 'konix/gnuplot/load-current-file)
  (define-key konix/gnuplot-mode-map "g" 'konix/gnuplot)
  )
(add-hook 'gnuplot-mode-hook
		  'konix/gnuplot-mode-hook)

(provide '700-KONIX_gnuplot-mode)
;;; 700-KONIX_gnuplot-mode.el ends here
