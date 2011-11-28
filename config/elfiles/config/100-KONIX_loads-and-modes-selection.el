;; ####################################################################################################
;; Here stands the needed information to load the good files when they are
;; required and to add correct load path in the load-path variable
;; ####################################################################################################
;; ************************************************************
;; Libraries path
;; ************************************************************
(add-to-list 'load-path (expand-file-name (concat elfiles "/ecb")))
(add-to-list 'load-path (expand-file-name (concat elfiles "/notmuch")))
(add-to-list 'load-path (expand-file-name (concat elfiles "/w3m")))
(add-to-list 'load-path (expand-file-name (concat elfiles "/csharp")))
(add-to-list 'load-path (expand-file-name (concat elfiles "/yasnippet")))
(add-to-list 'load-path (expand-file-name (concat elfiles "/git")))
(add-to-list 'load-path (expand-file-name (concat elfiles "/magit")))
(add-to-list 'load-path (expand-file-name (concat elfiles "/org/lisp")))
(add-to-list 'load-path (expand-file-name (concat elfiles "/org/contrib/lisp")))
(add-to-list 'load-path (expand-file-name (concat elfiles "/icicles")))
(add-to-list 'load-path (expand-file-name (concat elfiles "/full-ack")))

;; ************************************************************
;; Autoloads (TODO, automatise that with update-directory-autoloads)
;; ************************************************************
;; Loaddef file
;; (setq-default generated-autoload-file (expand-file-name "loaddefs.el" user-emacs-directory))
;; (load-file generated-autoload-file)
(defun konix/update-loaddefs ()
  (interactive)
  (mapc
   'update-file-autoloads
   load-path
   )
  )

(autoload 'php-mode "php-mode" "Major mode for editing php code." t)
(autoload 'maxima-mode "maxima" "Mode maxima" t)
(autoload 'lua-mode "lua-mode")
(autoload 'nsi-mode "nsi-mode" "Loading nsi mode" t nil)
(autoload 'csharp-mode "csharp-mode" "Major mode for editing C# code." t)
(autoload 'doc-mode "doc-mode" "Loading doc mode" t nil)
(autoload 'batch-mode "batch-mode" "Loading batch mode" t nil)
(autoload 'konix/prog/config "KONIX_programmation" "Loading konix programmation stuffs" t nil)
(autoload 'magit-status "magit" nil t)
(autoload 'konix/semantic-mode "KONIX_semantic" nil t)
(autoload 'zoom-in "zoom-frm" nil t)
(autoload 'zoom-out "zoom-frm" nil t)
(autoload 'zoom-frm-unzoom "zoom-frm" nil t)
(autoload 'zoom-frm-out "zoom-frm" nil t)
(autoload 'zoom-frm-in "zoom-frm" nil t)
(autoload 'konix/wm-mode "KONIX_windowsmanager" nil t)
(autoload 'mediawiki-site "mediawiki" nil t)
(autoload 'wikipedia-mode "wikipedia-mode" nil t)
(autoload 'graphviz-dot-mode "graphviz-dot-mode" nil t)
(autoload 'org-annotate-file "org-annotate-file" nil t)
(autoload 'org-id-update-id-locations "org-id" nil t)
(autoload 'visual-basic-mode "visual-basic-mode" nil t)
(autoload 'w3m "w3m" nil t)
(autoload 'w3m-buffer "w3m" nil t)
(autoload 'pick-backup-and-diff "pick-backup")
(autoload 'pick-backup-and-ediff "pick-backup")
(autoload 'pick-backup-and-revert "pick-backup")
(autoload 'pick-backup-and-view "pick-backup")
(autoload 'konix/org-meta-context/next-context "KONIX_org-meta-context")
(autoload 'konix/org-meta-context/init-context "KONIX_org-meta-context")
(autoload 'konix/org-meta-context/echo-current-context "KONIX_org-meta-context")
(autoload 'konix/org-meta-context/initialize "KONIX_org-meta-context")
(autoload 'konix/org-meta-context/goto-root "KONIX_org-meta-context")
(autoload 'konix/org-pomodoro-goto "KONIX_org-pomodoro")
(autoload 'org-timer-cancel-timer "org-timer")
(autoload 'notmuch "notmuch")
(autoload 'appt-check "appt")
(autoload 'elk-test-mode "elk-test" nil t)
(autoload 'macro-math-eval-and-round-region "macro-math" t nil)
(autoload 'macro-math-eval-region "macro-math" t nil)
(autoload 'highlight-symbol-at-point "highlight-symbol" t nil)

;; ************************************************************
;; Automodes
;; ************************************************************
;; .h -> cpp-mode
(add-to-list 'auto-mode-alist (cons "\\.h$" 'c++-mode))
;; .php
(add-to-list 'auto-mode-alist (cons "\\.php5$" 'php-mode))
(add-to-list 'auto-mode-alist (cons "\\.php$" 'php-mode))
;; Assembleur
(add-to-list 'auto-mode-alist (cons "\\.deca$" 'java-mode))
(add-to-list 'auto-mode-alist (cons "\\.ass$" 'asm-mode))
;; Les .l en mode ada
(add-to-list 'auto-mode-alist (cons "\\.l$" 'ada-mode))
;; Les .mel en mode tcl car ça y ressemble mine de rien
(add-to-list 'auto-mode-alist (cons "\\.mel$" 'tcl-mode))
;; clp -> clips
(add-to-list 'auto-mode-alist (cons "\\.clp$" 'clips-mode))
;; m -> octave
(add-to-list 'auto-mode-alist (cons "\\.m$" 'octave-mode))
;;sce ->Scilab
(add-to-list 'auto-mode-alist (cons "\\.sci$" 'scilab-mode))
(add-to-list 'auto-mode-alist (cons "\\.sce$" 'scilab-mode))
;;mode lisp sur le .emacs
(add-to-list 'auto-mode-alist (cons "emacs$" 'lisp-mode))
;; Maxima
(add-to-list 'auto-mode-alist (cons "\\.max$" 'maxima-mode))
(add-to-list 'auto-mode-alist (cons "\\.mac$" 'maxima-mode))
(add-to-list 'auto-mode-alist (cons "\\.wxm$" 'maxima-mode))
;; Pour les eclasses
(add-to-list 'auto-mode-alist (cons "\\.eclass$" 'sh-mode))
(add-to-list 'auto-mode-alist (cons "\\.ebuild$" 'sh-mode))
;; LUA
(add-to-list 'auto-mode-alist (cons "\\.lua$" 'lua-mode))
;; Gnuplot
(add-to-list 'auto-mode-alist (cons "\\.gp$" 'gnuplot-mode))
;; Makefile
(add-to-list 'auto-mode-alist (cons "\\.make$" 'make-mode))
;; Ogre scenes are xml files
(add-to-list 'auto-mode-alist (cons "\\.scene$" 'xml-mode))
;; nsi files
(add-to-list 'auto-mode-alist (cons "\\.nsi$" 'nsi-mode))
;; cs -> java
(add-to-list 'auto-mode-alist (cons "\\.cs$" 'csharp-mode))
;; .bat in batch mode
(add-to-list 'auto-mode-alist (cons "\\.bat$" 'batch-mode))
;; .wiki -> wikipedia
(add-to-list 'auto-mode-alist (cons "\\.wiki$" 'wikipedia-mode))
;; .dot -> graphviz-dot-mode
(add-to-list 'auto-mode-alist (cons "\\.dot$" 'graphviz-dot-mode))
;; .vb -> visual-basic-mode
(add-to-list 'auto-mode-alist (cons "\\.vb$" 'visual-basic-mode))
;; mutt files in mail mode
(add-to-list 'auto-mode-alist '("/mutt" . mail-mode))
(add-to-list 'auto-mode-alist '("/Mail/" . message-mode))
(add-to-list 'auto-mode-alist '(".+\.mail$" . message-mode))
;; elk
(add-to-list 'auto-mode-alist '("\\.elk\\'" . elk-test-mode))
;; full ack autoloads
(autoload 'ack-same "full-ack" nil t)
(autoload 'ack "full-ack" nil t)
(autoload 'ack-find-same-file "full-ack" nil t)
(autoload 'ack-find-file "full-ack" nil t)
;; grin
(autoload 'grin "grin" nil t)
(autoload 'hide/show-comments "hide-comnt" nil t)

;; ******************************************************************************************
;; Magic modes
;; ******************************************************************************************
;; COMMIT_MSG -> diff-mode
(setq magic-mode-alist '(
						 ((lambda ()
								  (string-equal (buffer-name) "COMMIT_EDITMSG")
								  ) . diff-mode)
						 )
	  )
