(defun konix/load-env-file (&optional file)
  (interactive)
  (with-temp-buffer
	(call-process  python-bin nil (list t nil) nil (expand-file-name
													 "~/init_bin/konix_get_env.py"
													 )
				  (if file file "")
				  )
	(goto-char (point-min))
	(while (re-search-forward "^\\([^=]+\\)=\"\\(.+\\)\"$" nil t)
	  (setenv (match-string 1) (match-string 2))
	  )
	)
  )
