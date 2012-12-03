;;; 700-KONIX_nxml.el ---

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

(setq-default nxml-bind-meta-tab-to-complete-flag t)
(setq-default nxml-auto-insert-xml-declaration-flag nil)
(setq-default nxml-child-indent 2)
(setq-default nxml-end-tag-indent-scan-distance 400000)
(setq-default nxml-heading-scan-distance nxml-end-tag-indent-scan-distance)
(add-to-list 'safe-local-variable-values
			 '(nxml-section-element-name-regexp . t))
(eval-after-load "rng-loc"
  '(progn
	 (add-to-list 'rng-schema-locating-files (expand-file-name "xml/schemas.xml"
															   perso-dir))
	 )
  )
(defun konix/hs-nxml-forward-sexp-func (dummy)
  (save-match-data
	(unless (looking-at "<\\([a-zA-Z0-9_-]+\\)[ >]")
	  (error "Not in correct beginning of tag")
	  )
	(let (
		  (beg_block_match (format "<%s[ >]" (match-string-no-properties 1)))
		  (end_block_match (format "</%s[ >]" (match-string-no-properties 1)))
		  (beg_encounter 1)
		  )
	  ;; go after the current block start
	  (re-search-forward beg_block_match)
	  (while (and
			  (not (equal beg_encounter 0))
			  (re-search-forward (format "%s\\|%s" beg_block_match
										 end_block_match))
			  )
		;; if the block was a beg, increase the counter
		(when (looking-back beg_block_match)
		  (setq beg_encounter (1+ beg_encounter))
		  )
		;; if on a end, decrease it
		(when (looking-back end_block_match)
		  (setq beg_encounter (- beg_encounter 1))
		  )
		;; if on the good end, beg_encounter should be 0
		)
	  ;; on the corresponding end_block, go to the top of it
	  (re-search-backward end_block_match)
	  )
	)
  )
(setq konix/hs-xml-mode-info
	  '(nxml-mode "<[^/\\?!][^>]*[^/]>"
				  "</[^>]>"
				  nil
				  konix/hs-nxml-forward-sexp-func)
	  )
(eval-after-load "hideshow"
  '(progn
	 (konix/push-or-replace-assoc-in-alist
	  'hs-special-modes-alist
	  konix/hs-xml-mode-info))
  )

(defun konix/nxml-in-cdata-p ()
  (nxml-token-before)
  (equal xmltok-type 'cdata-section)
  )

(defun konix/nxml/indirect-buffer-cdata ()
  (interactive)
  (unless (konix/nxml-in-cdata-p)
	(error "This works only in cdata section")
	)
  (let (
		beg
		end
		)
	(save-excursion
	  (nxml-move-outside-backwards)
	  (setq beg (+ 10 (point)))			;moves just after <![CDATA[
	  (xmltok-forward)
	  (setq end (-
				 (point)
				 3						;moves just before ]]>
				 ))
	  )
	(konix/indirect-region beg end)
	(delete-other-windows)
	)
  )

(defun konix/nxml-indent-line ()
  "Indent only relevent lines"
  ;; fill in the value of xmltok-type
  (nxml-token-before)
  (rng-set-state-after (point))
  (or
   ;; cases where special indentation or no indentation will be performed
   (case xmltok-type
	 ('cdata-section
	  t
	  )
	 )
   (let* (
		  (rng-open-elements_tmp rng-open-elements)
		  (my_elem (pop rng-open-elements_tmp))
		  (found nil)
		  )
	 (while (and my_elem (not found))
	   (when (string-equal (cdr my_elem) "screen")
		 (setq found t)
		 )
	   (setq my_elem (pop rng-open-elements_tmp))
	   )
	 found
	 )
   ;; else, perform the default nxml indentation function
   (nxml-indent-line)
   )
  )

(defun konix/nxml-newline-dwim ()
  (interactive)
  (cond
   ((and (looking-at-p "<") (looking-back ">"))
	(newline)
	(save-excursion
	  (newline-and-indent)
	  )
	(indent-for-tab-command)
	)
   ((or
	 (looking-at-p "[\n\r]")
	 (looking-at-p "<")
	 )
	(newline-and-indent)
	)
   (t
	(newline)
	)
   )
  )

(defun konix/nxml-narrow-to-element ()
  (interactive)
  (skip-chars-backward "[:blank:]")
  (let (
		(beg (point))
		(end (save-excursion (nxml-forward-element) (point)))
		)
	(narrow-to-region beg end)
	)
  )

(defun konix/nxml-kill-element ()
  (interactive)
  (let (
		(beg (point))
		(end (save-excursion (nxml-forward-element) (point)))
		)
	(kill-region beg end)
	)
  )

(defun konix/nxml-show-context ()
  (interactive)
  (nxml-token-before)
  (unless rng-validate-mode
	(rng-validate-mode 1)
	)
  (rng-set-state-after (point))
  (let* (
		 (rng-open-elements_tmp rng-open-elements)
		 (my_elem (pop rng-open-elements_tmp))
		 (message_ "")
		 )
	(while my_elem
	  (setq message_ (concat message_ " in " (car my_elem) ":" (cdr my_elem)))
	  (setq my_elem (pop rng-open-elements_tmp))
	  )
	(message message_)
	)
  )

(defun konix/nxml-zoom-in ()
  (interactive)
  (condition-case nil
	  (nxml-show-direct-subheadings)
	(error
	 (nxml-forward-element)
	 (nxml-backward-element)
	 (nxml-show-direct-subheadings)
	 )
	)
  (next-line)
  (beginning-of-line)
  )

(defun konix/nxml-zoom-out ()
  (interactive)
  (nxml-backward-up-element)
  (nxml-hide-subheadings)
  )

(defun konix/nxml-hide-all ()
  (interactive)
  (if (not current-prefix-arg)
	  (nxml-hide-all-text-content)
	(save-excursion
	  (goto-char (point-min))
	  (nxml-hide-other)
	  )
	)
  )

(defun konix/nxml-mark-element ()
  (interactive)
  (nxml-forward-element)
  (push-mark (point) nil t)
  (nxml-backward-element)
  )

(defun konix/nxml-down-element ()
  (interactive)
  (nxml-down-element)
  (skip-chars-forward " \t\n\r")
  )

(defun konix/nxml-forward-element ()
  (interactive)
  (nxml-forward-element)
  (skip-chars-forward " \t\n\r")
  )

(defun konix/nxml-heading-start-position_get-attribute (&optional bound)
  (interactive)
  (progn
	(when (re-search-backward " \\([^ ]+\\)=.+" bound t)
	  (cons
	   (match-string-no-properties 1)
	   (match-beginning 1)
	   )
	  )
	)
  )

(defun nxml-heading-start-position ()
  "Return the position of the start of the content of a heading element.
Adjust the position to be after initial leading whitespace.
Return nil if no heading element is found.  Requires point to be
immediately after the section's start-tag."
  (let ((depth 0)
		(heading-regexp (concat "\\`\\("
								nxml-heading-element-name-regexp
								"\\)\\'"))

		(section-regexp (concat "\\`\\("
								nxml-section-element-name-regexp
								"\\)\\'"))
		(start (point))
		found
		(start-current-section (save-excursion
								 (search-backward "<")
								 (point)
								 ))
		attribute
		)

	;; check the header in the current attributes="truc"
	(save-excursion
	  (while (and
			  (not found)
			  (setq attribute (konix/nxml-heading-start-position_get-attribute start-current-section))
			  )
		(when (string-match-p
			   heading-regexp
			   (car attribute)
			   )
		  (setq found (cdr attribute))
		  )
		)
	  )
	(save-excursion
      (while (and (not found) (xmltok-forward)
				  (cond
				   ((memq xmltok-type '(end-tag partial-end-tag))
					(and (not (string-match section-regexp
											(xmltok-end-tag-local-name)))
						 (> depth 0)
						 (setq depth (1- depth))))
				   ;; XXX Not sure whether this is a good idea
				   ;;((eq xmltok-type 'empty-element)
				   ;; nil)
				   ((not (memq xmltok-type
							   '(start-tag partial-start-tag)))
					t)
				   ((string-match section-regexp
								  (xmltok-start-tag-local-name))
					nil)
				   ((string-match heading-regexp
								  (xmltok-start-tag-local-name))
					(skip-chars-forward " \t\r\n")
					(setq found (point))
					nil)
				   (t
					(setq depth (1+ depth))
					t))
				  (<= (- (point) start) nxml-heading-scan-distance)))
	  )
    found)
  )
(byte-compile 'konix/nxml-heading-start-position_get-attribute)
(byte-compile 'nxml-heading-start-position)

(defun konix/nxml-mode-hook ()
  ;; extension of hs-mode regexp to fit <![CDATA[ tags
  (auto-fill-mode t)
  (autopair-mode 1)
  (setq show-trailing-whitespace t)
  (setq indent-line-function 'konix/nxml-indent-line)
  (ac-flyspell-workaround)
  (local-set-key (kbd "<C-return>") 'konix/nxml-newline-dwim)
  (local-set-key (kbd "C-c C-d") 'konix/nxml/indirect-buffer-cdata)
  (setq ac-sources
		'(
		  ac-source-konix/rng
		  ac-source-yasnippet
		  ac-source-dictionary
		  ac-source-files-in-current-dir
		  ac-source-words-in-same-mode-buffers
		  )
		)
  (local-set-key (kbd "<f1>") 'konix/nxml-zoom-out)
  (local-set-key (kbd "<f3>") 'konix/nxml-zoom-in)
  (local-set-key (kbd "<f2> <f3>") 'nxml-show-all)
  (local-set-key (kbd "<f2> <f1>") 'konix/nxml-hide-all)
  (local-set-key (kbd "C-x n e") 'konix/nxml-narrow-to-element)
  (local-set-key (kbd "C-M-k") 'konix/nxml-kill-element)
  (local-set-key (kbd "C-M-h") 'konix/nxml-mark-element)
  (local-set-key (kbd "C-M-d") 'konix/nxml-down-element)
  (local-set-key (kbd "C-M-n") 'konix/nxml-forward-element)
  (local-set-key (kbd "C-c C-c") 'konix/nxml-show-context)
  (auto-complete-mode 1)
  )
(add-hook 'nxml-mode-hook
		  'konix/nxml-mode-hook)

(eval-after-load "nxml-mode"
  '(progn
	 (set-face-attribute 'nxml-text nil
						 :weight 'bold
						 )
	 (set-face-attribute 'nxml-cdata-section-content nil
						 :inherit nil)
	 (set-face-foreground 'nxml-element-local-name
						  "dodger blue"
						  )
	 (define-key nxml-outline-showing-tag-map (kbd "<C-tab>") 'nxml-hide-subheadings)
	 (define-key nxml-outline-hiding-tag-map (kbd "<C-tab>") 'nxml-show-direct-subheadings)
	 )
  )

(provide '700-KONIX_nxml)
;;; 700-KONIX_nxml.el ends here
