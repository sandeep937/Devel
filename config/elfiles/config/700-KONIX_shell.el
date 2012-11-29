;;; 700-KONIX_shell-mode.el ---

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

(defun konix/shell/find-command-completions (prefix)
  (let* (
         (filenondir     (file-name-nondirectory prefix))
         (path-dirs      (reverse exec-path))
         (cwd            (file-name-as-directory (expand-file-name default-directory)))
         (ignored-extensions
          (and comint-completion-fignore
               (mapconcat #'(lambda (x) (concat (regexp-quote x) "$"))
                          comint-completion-fignore "\\|")))
         (dir            "")
         (comps-in-dir   ())
         (file           "")
         (abs-file-name  "")
         (completions    ()))
    (while path-dirs                    ; Go thru each dir in the search path, finding completions.
      (setq dir           (file-name-as-directory (comint-directory (or (car path-dirs) ".")))
            comps-in-dir  (and (file-accessible-directory-p dir)
                               (file-name-all-completions filenondir dir)))
      (while comps-in-dir               ; Go thru each completion, to see whether it should be used.
        (setq file           (car comps-in-dir)
              abs-file-name  (concat dir file))
        (when (and (not (member file completions))
                   (not (and ignored-extensions (string-match ignored-extensions file)))
                   (or (string-equal dir cwd) (not (file-directory-p abs-file-name)))
                   (or (null shell-completion-execonly) (file-executable-p abs-file-name)))
          (setq completions  (cons file completions)))
        (setq comps-in-dir  (cdr comps-in-dir)))
      (setq path-dirs  (cdr path-dirs)))
	completions
    )
  )
(defun konix/shell/delete-async-shell-buffer ()
  (let (
		(async_shell_buffer (get-buffer "*Async Shell Command*"))
		)
	(when (and async_shell_buffer
			   (save-window-excursion
				 (switch-to-buffer async_shell_buffer)
				 (y-or-n-p
				  (format "%s buffer already exists, kill it ?"
						  async_shell_buffer)
				  )
				 )
			   )
	  (kill-buffer async_shell_buffer)
	  )
	)
  )

(defun konix/shell/rename-async-shell-buffer ()
  (let (
		(async_shell_buffer (get-buffer "*Async Shell Command*"))
		)
	(when (and async_shell_buffer
			   (save-window-excursion
				 (switch-to-buffer async_shell_buffer)
				 (y-or-n-p
				  (format "%s buffer already exists, rename it ?"
						  async_shell_buffer)
				  )
				 (rename-uniquely)
				 )
			   )
	  )
	)
  )

(defcustom konix/shell-font-lock-keywords '() "")
(setq-default explicit-shell-file-name (locate-file "bash" exec-path exec-suffixes))
(setq-default konix/shell/bash-dirtrack-list '("^[^|\r\n]+|path=\\([^|]+\\)|" 1 nil))
(add-to-list 'ac-modes 'shell-mode)

(defun konix/shell/is-cmd ()
  (string-match "cmd" (first (process-command(get-buffer-process (buffer-name)))))
  )

(defun konix/shell/is-shell ()
  (string-match "shell" (first (process-command(get-buffer-process (buffer-name)))))
  )

(defun konix/shell/get-env (name &optional command_template regexp match_string)
  (unless command_template
	(setq command_template
		  (if (konix/shell/is-cmd)
			  "echo %%%s%%"
			"echo ${%s}"
			)
		  )
	)
  (unless regexp
	(setq regexp "^\\(.*\\)$")
	)
  (unless match_string
	(setq match_string 1)
	)
  (let (
		(get_env_handler (if (konix/shell/is-cmd)
							 (lambda ()
							   (if (re-search-forward (concat "%" name "%") nil t)
								   ""
								 (when (re-search-forward regexp nil t)
								   (match-string match_string)
								   )
								 )
							   )
						   (lambda ()
							 (when (re-search-forward regexp nil t)
							   (match-string match_string)
							   )
							 )
						   )
						 )
		)
	(konix/comint/send-command-redirect
	 (format command_template name)
	 get_env_handler
	 )
	)
  )

(defun konix/shell/import-path ()
  (interactive)
  (message "Getting path of current shell")
  (let (
		(import_path (konix/shell/get-env "PATH"))
		)
	(set (make-variable-buffer-local 'exec-path)
		 (split-string import_path path-separator)
		 )
	(message "exec-path set to '%s' in the buffer '%s'" exec-path (current-buffer))
	)
  )

(defun konix/shell-complete-rlc ()
  (interactive)
  (let* (
		 (completion (rlc-candidates))
		 (word-before
		  (if
			  (looking-back "[ \t\n]+\\(.+\\)")
			  (match-string-no-properties 1)
			(error "Cannot match the word before point")
			)
		  )
		 (beginning-of-word-before (match-beginning 1))
		 (completion (and
					  completion
					  (completing-read "Completion: " (all-completions word-before completion))
					  )
					 )
		 )
	(if completion
		(progn
		  (delete-region beginning-of-word-before (point))
		  (insert completion)
		  t
		  )
	  nil
	  )
	)
  )

(defun konix/shell-complete-rlc-no-error (&rest args)
  (interactive)
  (and (ignore-errors (konix/shell-complete-rlc))
	   t)
  )

(defun konix/bash-completion-dynamic-complete-no-error (&rest args)
  (interactive)
  (and (ignore-errors (bash-completion-dynamic-complete))
	   t)
  )

(defvar konix/bash-completion-history '() "")

(defun konix/bash-completion (&rest args)
  (interactive)
  (when bash-completion-enabled
    (when (not (window-minibuffer-p))
      (message "Bash completion..."))
    (let* ( (start (comint-line-beginning-position))
			(pos (point))
			(tokens (bash-completion-tokenize start pos))
			(open-quote (bash-completion-tokenize-open-quote tokens))
			(parsed (bash-completion-process-tokens tokens pos))
			(line (cdr (assq 'line parsed)))
			(point (cdr (assq 'point parsed)))
			(cword (cdr (assq 'cword parsed)))
			(words (cdr (assq 'words parsed)))
			(stub (nth cword words))
			(completions (bash-completion-comm line point words cword open-quote))
			;; Override configuration for comint-dynamic-simple-complete.
			;; Bash adds a space suffix automatically.
			(comint-completion-addsuffix nil) )
      (if completions
		  (progn
			(comint-dynamic-simple-complete
			 stub
			 (list
			  (completing-read "Complete: " completions nil nil stub
							   'konix/bash-completion-history)
			  )
			 )
			t
			)
		;; no standard completion
		;; try default (file) completion after a wordbreak
		(bash-completion-dynamic-try-wordbreak-complete stub open-quote)
		)
	  )
	)
  )

(defun konix/shell-mode-hook ()
  (require 'readline-complete)
  (require 'bash-completion)
  (compilation-shell-minor-mode)
  (auto-complete-mode t)
  (if (string-match
	   "linux"
	   (getenv "KONIX_PLATFORM")
	   )
	  (setq ac-sources '(
						 ac-source-shell
						 ;; ac-source-yasnippet
						 ;; ac-source-files-in-current-dir
						 ;; ac-source-filename
						 ))
	(setq ac-sources '(
					   ac-source-yasnippet
					   ac-source-files-in-current-dir
					   ac-source-filename
					   ))
	)
  (local-set-key (kbd "<S-return>") 'newline)
  (ansi-color-for-comint-mode-on)
  (font-lock-add-keywords nil konix/shell-font-lock-keywords)
  (auto-complete-mode t)
  (ansi-color-for-comint-mode-on)
  (setq show-trailing-whitespace nil)
  (autopair-mode t)
  (cond
   ((string-match-p "shell" (buffer-name))
	(set (make-variable-buffer-local 'dirtrack-list)
		 konix/shell/bash-dirtrack-list)
	(dirtrack-mode t)
	)
   ((string-match-p "cmd" (buffer-name))
	(set (make-variable-buffer-local 'dirtrack-list)
		 '("^\\[[A-Z0-9]+\\][ 0-9:.]+ [A-Za-z]+ [0-9/]+
\\([a-zA-Z]:\\\\[ a-zA-Z_0-9-\\\\]+\\) > .*$" 1 nil))
	(dirtrack-mode t)
	)
   (t
	(dirtrack-mode -1)
	)
   )
  (set (make-variable-buffer-local 'hippie-expand-try-functions-list)
	   '(
		 konix/bash-completion
		 konix/shell-complete-rlc-no-error
		 konix/comint-dynamic-complete-no-error
		 )
	   )
  (local-set-key (kbd "C-j") 'hippie-expand)
  (local-set-key (kbd "<tab>") 'hippie-expand)
  )
(add-hook 'shell-mode-hook
		  'konix/shell-mode-hook
		  )

(provide '700-KONIX_shell-mode)
;;; 700-KONIX_shell-mode.el ends here
