;;; 700-KONIX_notmuch.el ---

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

(defun konix/message-setup-hook ()
  (mml-secure-message-sign-pgpmime)
  (save-excursion
	(goto-char (point-max))
	(newline)
	)
  (gnus-alias-determine-identity)
  )

(add-hook 'message-setup-hook 'konix/message-setup-hook)
;; for notmuch to sort mails like I want
(setq-default notmuch-search-oldest-first nil)
(setq-default notmuch-saved-searches
			  '(
				("inbox" . "tag:inbox AND -tag:deleted")
				("flagged" . "tag:flagged")
				("draft" . "tag:draft and not tag:deleted")
				("unread" . "tag:unread AND NOT tag:rss AND NOT tag:ml AND NOT tag:inbox AND NOT tag:flagged")
				("unread ml" . "tag:ml AND tag:unread")
				("unread rss" . "tag:rss AND tag:unread")
				)
			  )

(setq notmuch-address-command "notmuch_addresses.py")

(defface konix/notmuch-search-unread
  '(
	(
	 ((class color)
	  (background dark))
	 (:inherit default :foreground "green")
	 )
	(
	 ((class color)
	  (background light))
	 (:inherit default :foreground "dark green")
	 )
	)
  ""
  )
(defface konix/notmuch-search-replied
  '(
	(
	 ((class color)
	  (background dark))
	 (:background "aquamarine")
	 )
	(
	 ((class color)
	  (background light))
	 (:background "aquamarine")
	 )
	)
  ""
  )
(defface konix/notmuch-search-temp
  '(
	(
	 ((class color)
	  (background dark))
	 (:background "gainsboro")
	 )
	(
	 ((class color)
	  (background light))
	 (:background "gainsboro")
	 )
	)
  ""
  )
(defface konix/notmuch-search-perso
  '(
	(
	 ((class color)
	  (background dark))
	 (:background "peach puff")
	 )
	(
	 ((class color)
	  (background light))
	 (:background "peach puff")
	 )
	)
  ""
  )
(setq notmuch-search-line-faces '(
								  ("temp" . konix/notmuch-search-temp)
								  ("perso" . konix/notmuch-search-perso)
								  ("deleted" . '(:foreground "red"))
								  ("unread" . konix/notmuch-search-unread)
								  ("replied" . konix/notmuch-search-replied)
								  )
	  )
(defface notmuch-search-count
  '(
	(
	 ((class color)
	  (background dark))
	 (:inherit default :foreground "green")
	 )
	(
	 ((class color)
	  (background light))
	 (:inherit default)
	 )
	)
  ""
  )
(defface notmuch-search-date
  '(
	(
	 ((class color)
	  (background dark))
	 (:inherit default :foreground "cyan")
	 )
	(
	 ((class color)
	  (background light))
	 (:inherit default :foreground "blue")
	 )
	)
  ""
  )
(defface notmuch-search-matching-authors
  '(
	(
	 ((class color)
	  (background dark))
	 (:inherit default :foreground "white")
	 )
	(
	 ((class color)
	  (background light))
	 (:inherit default :foreground "blue")
	 )
	)
  ""
  )
(defface notmuch-search-subject
  '(
	(
	 ((class color)
	  (background dark))
	 (:inherit default :foreground "light green")
	 )
	(
	 ((class color)
	  (background light))
	 (:inherit default :foreground "sienna")
	 )
	)
  ""
  )

(defun konix/notmuch-search-tag-change (tag_change)
  (notmuch-search-tag-region
   (save-excursion (beginning-of-line) (point))
   (save-excursion (end-of-line) (point))
   tag_change
   )
  )
(defun konix/notmuch-remove-tag (tag)
  (let (
		(tag_change (format "-%s" tag))
		)
	(cond
	 ((eq major-mode 'notmuch-search-mode)
	  (konix/notmuch-search-tag-change tag_change)
	  )
	 ((eq major-mode 'notmuch-show-mode)
	  (notmuch-show-tag-message tag_change)
	  )
	 (t
	  (error "Could not found a suitable tag function for mode %s"
			 (symbol-name major-mode)
			 )
	  )
	 )
	)
  )
(defun konix/notmuch-remove-unread ()
  (when (member "unread" (konix/notmuch-get-tags))
	(konix/notmuch-add-tag "wontread")
	(konix/notmuch-remove-tag "unread")
	)
  )
(defun konix/notmuch-add-tag (tag)
  (let (
		(tag_change (format "+%s" tag))
		)
	(cond
	 ((eq major-mode 'notmuch-search-mode)
	  (konix/notmuch-search-tag-change tag_change)
	  )
	 ((eq major-mode 'notmuch-show-mode)
	  (notmuch-show-tag-message tag_change)
	  )
	 (t
	  (error "Could not found a suitable tag function for mode %s"
			 (symbol-name major-mode)
			 )
	  )
	 )
	)
  )
(defun konix/notmuch-get-tags ()
  (cond
   ((eq major-mode 'notmuch-search-mode)
	(notmuch-search-get-tags)
	)
   ((eq major-mode 'notmuch-show-mode)
	(notmuch-show-get-tags)
	)
   (t
	(error "Could not found a tags function for mode %s"
		   (symbol-name major-mode)
		   )
	)
   )
  )
(defun konix/notmuch-toggle-tag (tag &optional toggle_tag)
  (if (member tag (konix/notmuch-get-tags))
	  (progn
		(konix/notmuch-remove-tag tag)
		(when toggle_tag
		  (konix/notmuch-add-tag toggle_tag)
		  )
		)
	(progn
	  (konix/notmuch-add-tag tag)
	  (when toggle_tag
		(konix/notmuch-remove-tag toggle_tag)
		)
	  )
	)
  )
(defun konix/notmuch-toggle-deleted-tag ()
  (interactive)
  (konix/notmuch-toggle-tag "deleted")
  )
(defun konix/notmuch-toggle-spam-tag ()
  (interactive)
  (konix/notmuch-toggle-tag "spam")
  )
(defun konix/notmuch-toggle-unread-tag (&optional no_wontread)
  (interactive "P")
  (konix/notmuch-toggle-tag
   "unread"
   (if (or no_wontread
		   (eq major-mode 'notmuch-show-mode))
	   nil
	 "wontread")
   )
  )
(defun konix/notmuch-toggle-inbox-tag ()
  (interactive)
  (konix/notmuch-toggle-tag "inbox")
  )
(defun konix/notmuch-toggle-flagged-tag ()
  (interactive)
  (konix/notmuch-toggle-tag "flagged")
  )
(defun konix/notmuch-show-open-in-external-browser ()
  (interactive)
  (notmuch-show-pipe-message nil "konix_view_html.sh")
  )
(defun konix/notmuch-message-completion-toggle ()
  (interactive)
  (require 'notmuch)
  (let (
		(need_to_remove (not (not (member notmuch-address-message-alist-member message-completion-alist))))
		)
	(if need_to_remove
		(setq message-completion-alist (remove
										notmuch-address-message-alist-member
										message-completion-alist))
	  (add-to-list 'message-completion-alist
				   notmuch-address-message-alist-member)
	  )
	(message "Activation of notmuch completion : %s" (not need_to_remove))
	)
  )
(defun konix/notmuch-define-key-search-show (key function)
  (define-key notmuch-show-mode-map key function)
  (define-key notmuch-search-mode-map key function)
  )
(defun konix/notmuch-show-remove-tag-and-next (tag show-next)
  "Remove the tag from the current set of messages and go to next.
inspired from `notmuch-show-archive-thread-internal'"
  (goto-char (point-min))
  (loop do (notmuch-show-tag-message (format "-%s"tag))
		until (not (notmuch-show-goto-message-next)))
  ;; Move to the next item in the search results, if any.
  (let ((parent-buffer notmuch-show-parent-buffer))
	(notmuch-kill-this-buffer)
	(if parent-buffer
		(progn
		  (switch-to-buffer parent-buffer)
		  (forward-line)
		  (if show-next
			  (notmuch-search-show-thread))))))

(defun konix/notmuch-show-unflag-and-next ()
  (interactive)
  (konix/notmuch-show-remove-tag-and-next "flagged" t)
  )
(defun konix/notmuch-show-read-delete-and-next ()
  (interactive)
  (notmuch-show-add-tag "deleted")
  (konix/notmuch-show-remove-tag-and-next "TOReadList" t)
  )
(defun konix/notmuch-archive ()
  (konix/notmuch-remove-unread)
  (cond
   ((eq major-mode 'notmuch-search-mode)
	(notmuch-search-archive-thread)
	)
   ((eq major-mode 'notmuch-show-mode)
	(notmuch-show-archive-thread-then-next)
	)
   (t
	(error "Could not found a suitable tag function for mode %s"
		   (symbol-name major-mode)
		   )
	)
   )
  )
(defun konix/notmuch-read-and-archive ()
  (interactive)
  (konix/notmuch-remove-unread)
  (konix/notmuch-archive)
  )

(defun konix/notmuch-search-no-tag ()
  (interactive)
  (let (
		(search_string
		 (shell-command-to-string "konix_notmuch_no_tag_search.sh")
		 )
		)
	(notmuch-search search_string)
	(rename-buffer "*notmuch-search-no-tag*")
	)
  )
(defun konix/notmuch-search-unflag-remove-read-and-next ()
  (interactive)
  (konix/notmuch-remove-tag "flagged")
  (konix/notmuch-remove-unread)
  (next-line)
  )

(defun konix/notmuch-hello-refresh-hook ()
  ;; launches an update on the mail daemon
  (shell-command "konix_mail_tray_daemon_update.sh")
  )
(add-hook 'notmuch-hello-refresh-hook
		  'konix/notmuch-hello-refresh-hook)

(defun konix/notmuch-show-mark-read ()
  "Mark the current message as read. (edited to remove also wontread)"
  (konix/notmuch-remove-tag "wontread")
  (konix/notmuch-remove-tag "unread")
  )

(eval-after-load "notmuch"
  '(progn
	 (require 'notmuch-address)
	 (konix/notmuch-define-key-search-show "d" 'konix/notmuch-toggle-deleted-tag)
	 (konix/notmuch-define-key-search-show (kbd "<deletechar>") 'konix/notmuch-toggle-deleted-tag)
	 (konix/notmuch-define-key-search-show "S" 'konix/notmuch-toggle-spam-tag)
	 (konix/notmuch-define-key-search-show "i" 'konix/notmuch-toggle-inbox-tag)
	 (konix/notmuch-define-key-search-show (kbd "C-f") 'konix/notmuch-toggle-flagged-tag)
	 (konix/notmuch-define-key-search-show "u" 'konix/notmuch-toggle-unread-tag)
	 (konix/notmuch-define-key-search-show (kbd "a") 'konix/notmuch-read-and-archive)
	 (define-key notmuch-search-mode-map (kbd "F") 'konix/notmuch-search-unflag-remove-read-and-next)
	 (define-key notmuch-show-mode-map (kbd "M") 'konix/notmuch-show-open-in-external-browser)
	 (define-key notmuch-show-mode-map (kbd "F") 'konix/notmuch-show-unflag-and-next)
	 (define-key notmuch-show-mode-map (kbd "U") 'konix/notmuch-show-read-delete-and-next)
	 (define-key notmuch-show-mode-map (kbd "<C-return>") 'w3m-view-url-with-external-browser)
	 (define-key notmuch-hello-mode-map (kbd "N") 'konix/notmuch-search-no-tag)
	 ;; redefine notmuch-show-mark-read so that it removes also the wontread tag
	 (defalias 'notmuch-show-mark-read 'konix/notmuch-show-mark-read)
	 )
  )

(provide '700-KONIX_notmuch)
;;; 700-KONIX_notmuch.el ends here