;; ####################################################################################################
;; Some advices
;; ####################################################################################################
(defadvice flyspell-goto-next-error (before push-mark ())
  "Met une marque avant d'aller sur l'erreur prochaine"
  (push-mark)
  )
(ad-activate 'flyspell-goto-next-error)

(defadvice find-function (before push-tag-mark ())
  "Push a tag mark before going to the function definition"
  (push-tag-mark)
  )
(ad-activate 'find-function)

(defadvice find-variable (before push-tag-mark ())
  "Push a tag mark before going to the variable definition"
  (push-tag-mark)
  )
(ad-activate 'find-variable)

(defadvice icicle-bind-completion-keys (after change-maps-for-azerty-keyboard ())
  "Rebind C-é, C-d and delete"
  (define-key map [(control ?é)] 'icicle-candidate-set-complement) ; `C-é' instead of `C-~'
  (define-key map (kbd "<delete>") 'icicle-delete-char) ; `delete' removes char
  (define-key map (kbd "C-d") 'icicle-remove-candidate) ; `C-d' removes candidate
  )
(ad-activate 'icicle-bind-completion-keys)

(defadvice check-parens (before push-mark ())
  (push-mark)
  )
(ad-activate 'check-parens)

(defadvice tags-search (before push-tag-mark ())
  "Push a tag mark before going to the function definition"
  (ring-insert find-tag-marker-ring (point-marker))
  )
(ad-activate 'tags-search)

(defadvice tags-query-replace (before push-tag-mark ())
  "Push a tag mark before going to the function definition"
  (ring-insert find-tag-marker-ring (point-marker))
  )
(ad-activate 'tags-query-replace)

(defadvice semantic-decoration-include-visit (before push-tag-mark ())
  "Push a tag mark before going to the function definition"
  (push-tag-mark)
  )
(ad-activate 'semantic-decoration-include-visit)

(defadvice beginning-of-defun (before push-mark ())
  "Push a mark before going to the function beginning"
  (push-mark)
  )
(ad-activate 'beginning-of-defun)

(defadvice end-of-defun (before push-mark ())
  "Push a mark before going to the function end"
  (push-mark)
  )
(ad-activate 'end-of-defun)

(defadvice c-beginning-of-defun (before push-mark ())
  "Push a mark before going to the function beginning"
  (push-mark)
  )
(ad-activate 'c-beginning-of-defun)

(defadvice c-end-of-defun (before push-mark ())
  "Push a mark before going to the function end"
  (push-mark)
  )
(ad-activate 'c-end-of-defun)
;; ******************************************************************************************
;; TAGS
;; ******************************************************************************************
(defadvice tags-search (before save-window-excursion)
  (setq konix/tags/windows-configuration-saved (current-window-configuration))
  )
(ad-activate 'tags-search)

(defadvice tags-loop-continue (after recontinue-if-on-comment)
  (when (and konix/tags/avoid-comments (hs-inside-comment-p))
	(message "Avoiding comment")
	(tags-loop-continue)
	)
  )
(ad-activate 'tags-loop-continue)
;; ******************************************************************************************
;; Shell
;; ******************************************************************************************
(defadvice shell-command (before kill_async_shell_buffer ())
  (when (string-match ".+[ \r\n&]+$" command)
	(konix/shell/rename-async-shell-buffer)
	)
  )
(ad-activate 'shell-command)

(defadvice dired-do-async-shell-command (before kill_async_shell_buffer ())
  (konix/shell/delete-async-shell-buffer)
  )
(ad-activate 'dired-do-async-shell-command)
;; ******************************************************************************************
;; Icicles disturb tags completion
;; ******************************************************************************************
(defadvice org-set-tags-command (around disable-icy ())
  (let (
		(konix/org-set-tags-command_icy_before icicle-mode)
		)
	(konix/icy-mode nil)
	(unwind-protect
		ad-do-it
	  (konix/icy-mode konix/org-set-tags-command_icy_before)
	  )
	)
  )
(ad-activate 'org-set-tags-command)
;; Icicles disturb also konix/git/command-with-completion
(defadvice konix/git/command-with-completion (around disable-icy ())
  (let (
		(konix/org-set-tags-command_icy_before icicle-mode)
		)
	(konix/icy-mode nil)
	(unwind-protect
		ad-do-it
	  (konix/icy-mode konix/org-set-tags-command_icy_before)
	  )
	)
  )
(ad-activate 'konix/git/command-with-completion)

;; **********************************************************************
;; Org
;; **********************************************************************
(defadvice org-open-at-point (before push-ring ())
  (org-mark-ring-push)
  )
(ad-activate 'org-open-at-point)
