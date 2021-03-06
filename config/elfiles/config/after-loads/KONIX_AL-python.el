;;; 700-KONIX_python-mode.el ---

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

(setq-default python-guess-indent nil)
(setq-default python-indent-offset 4)
(defun konix/python-mode-hook ()
  (setq tab-width 4)
  (konix/prog/config)
  ;; fed up with auto line breaks
  (setq indent-tabs-mode nil)
  (auto-complete-mode 1)
  (setq ac-sources
		'(
		  ac-source-yasnippet
		  ac-source-dictionary
		  ac-source-words-in-same-mode-buffers
		  ac-source-files-in-current-dir
		  )
		)
  ;; Autopair des """ en python
  (setq autopair-handle-action-fns
		(list #'autopair-default-handle-action
			  #'autopair-python-triple-quote-action)
		)
  (add-hook 'after-save-hook 'konix/python/make-executable t t)
  )
(add-hook 'python-mode-hook
		  'konix/python-mode-hook)

(defun konix/python/make-executable ()
  (when (save-excursion
		  (goto-char (point-min))
		  (re-search-forward "__name__.+==.+.__main__." nil t)
		 )
   (konix/make-executable)
   )
  )

(defun konix/inferior-python-mode-hook ()
  (auto-complete-mode t)
  (setq ac-sources
		'(
		  ac-source-konix/python/dir
		  )
		)
  )
(add-hook 'inferior-python-mode-hook
		  'konix/inferior-python-mode-hook)

(provide '700-KONIX_python-mode)
;;; 700-KONIX_python-mode.el ends here
