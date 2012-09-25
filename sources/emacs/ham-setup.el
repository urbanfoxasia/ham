;;
;; Usage, in your .emacs:
;;  (setenv "HAM_HOME" "/path/to/ham/root/")
;;  (add-to-list 'load-path (concat (getenv "HAM_HOME") "/sources/emacs"))
;;  (require 'ham-setup)
;;
(provide 'ham-setup)

;;;======================================================================
;;; Environment setup
;;;======================================================================
(defun ham-getenv (str)
  (let ((envValue (getenv str)))
    (if envValue
        (replace-regexp-in-string "\\\\" "/" envValue)
      nil)))

(if (not (getenv "HAM_HOME"))
    (setenv "HAM_HOME" (concat (ham-getenv "WORK") "/ham")))

(defconst HAM_HOME (ham-getenv "HAM_HOME"))

;;;======================================================================
;;; Flymake
;;;======================================================================
(require 'flymake)

(defun ham-flymake-get-ham-cmdline (source base-dir)
  (string-match "src/\\(.*\\)\\." source)
  (list (concat (getenv "HAM_HOME") "/bin/hamj")
	    (list "FLYMAKE=1"
              (concat "CHK_SOURCES=" source)
              (concat "FLYMAKE_BASEDIR=" base-dir)
              "check-syntax")))

; Set flymake to start only when saving the buffer
(setq flymake-no-changes-timeout 999999
      flymake-start-syntax-check-on-newline nil)

; Error pattern matching :
;   regexp file-idx line-idx col-idx (optional) text-idx(optional), match-end to end of string is error text

(defun ham-flymake-goto-prev-error-disp ()
 "Flymake, goto the previous error and display it in the minibuffer."
  (interactive)
  (flymake-goto-prev-error)
  (ham-flymake-display-err-minibuf)
)

(defun ham-flymake-goto-next-error-disp ()
 "Flymake, goto the next error and display it in the minibuffer."
  (interactive)
  (flymake-goto-next-error)
  (ham-flymake-display-err-minibuf)
)

(defun ham-flymake-display-err-minibuf ()
  "Displays the error/warning for the current line in the minibuffer"
  (interactive)
  (let* ((line-no             (flymake-current-line-no))
         (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
         (count               (length line-err-info-list))
         )
    (while (> count 0)
      (when line-err-info-list
        (let* ((file       (flymake-ler-file (nth (1- count) line-err-info-list)))
               (full-file  (flymake-ler-full-file (nth (1- count) line-err-info-list)))
               (text (flymake-ler-text (nth (1- count) line-err-info-list)))
               (line       (flymake-ler-line (nth (1- count) line-err-info-list))))
          (message "%s:%s: %s" full-file line text)
          )
        )
      (setq count (1- count)))))

(defun ham-flymake-follow-err ()
  "Open the file/line in which the error is described."
  (interactive)
  (let* ((line-no             (flymake-current-line-no))
         (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
         (count               (length line-err-info-list))
         )
    (while (> count 0)
      (when line-err-info-list
        (let* ((file       (flymake-ler-file (nth (1- count) line-err-info-list)))
               (full-file  (flymake-ler-full-file (nth (1- count) line-err-info-list)))
               (text (flymake-ler-text (nth (1- count) line-err-info-list)))
               (line       (flymake-ler-line (nth (1- count) line-err-info-list))))
           ;;(message "%s:%s: %s" full-file line text)
		   (find-file full-file)
		   (goto-line line)
          )
        )
      (setq count (1- count)))))

(defun ham-flymake-goto-prev-error-disp ()
 "Flymake, goto the previous error and display it in the minibuffer."
  (interactive)
  (flymake-goto-prev-error)
  (ham-flymake-display-err-minibuf)
)

(defun ham-flymake-goto-next-error-disp ()
 "Flymake, goto the next error and display it in the minibuffer."
  (interactive)
  (flymake-goto-next-error)
  (ham-flymake-display-err-minibuf)
)


;; Return the filename directly, ignore the prefixe
;; Ex: (ham-flymake-create-passthrough "c:/machin/roger.java" "xxx") -> "c:/machin/roger.java"
(defun ham-flymake-create-temp-passthrough (file-name prefix)
  file-name)

;; Generates a tempfile in the temp folder
;; Ex: (ham-flymake-create-temp-intmp "c:/machin/roger.java" "xxx") -> "c:/.tmp/78979879/roger.java"
(defun ham-flymake-create-temp-intmp (file-name prefix)
  (file-truename (expand-file-name (file-name-nondirectory file-name)
                                   (expand-file-name (int-to-string (abs (random))) (flymake-get-temp-dir)))))

;; Generates a _FILENAME_.EXT tempfile (adds a _ in front so that the Glob of Ham skips it always)
;; Ex: (ham-flymake-create-temp-inplace "c:/machin/roger.java" "xxx") -> "c:/machin/_roger_xxx.java"
(defun ham-flymake-create-temp-inplace (file-name prefix)
  (unless (stringp file-name)
    (error "Invalid file-name"))
  (or prefix
      (setq prefix "flymake"))
  (let* ((temp-name (concat (file-name-directory file-name)
                            "_"
                            (file-name-sans-extension (file-name-nondirectory  file-name))
                            "_" prefix
                            (and (file-name-extension file-name)
                                 (concat "." (file-name-extension file-name))))))
    (flymake-log 3 "create-temp-inplace: file=%s temp=%s" file-name temp-name)
    temp-name))

;;**********************************************************************
;; Flymake - C++
;;**********************************************************************

 (defun ham-flymake-cpp-make-init ()
   (flymake-simple-make-init-impl 'ham-flymake-create-temp-inplace t t "_build.ham" 'ham-flymake-get-ham-cmdline))

 (push '(".+\\.c$" ham-flymake-cpp-make-init) flymake-allowed-file-name-masks)
 (push '(".+\\.cc$" ham-flymake-cpp-make-init) flymake-allowed-file-name-masks)
 (push '(".+\\.cpp$" ham-flymake-cpp-make-init) flymake-allowed-file-name-masks)
 (push '(".+\\.cxx$" ham-flymake-cpp-make-init) flymake-allowed-file-name-masks)
 (push '(".+\\.acc$" ham-flymake-cpp-make-init) flymake-allowed-file-name-masks)
 (push '(".+\\.hpp$" ham-flymake-cpp-make-init-tocpp) flymake-allowed-file-name-masks)
 (push '(".+\\.inl$" ham-flymake-cpp-make-init-tocpp) flymake-allowed-file-name-masks)
 (push '(".+\\.m$" ham-flymake-cpp-make-init) flymake-allowed-file-name-masks)
 (push '(".+\\.mm$" ham-flymake-cpp-make-init) flymake-allowed-file-name-masks)

;;**********************************************************************
;; Flymake - Java & Scala
;;**********************************************************************

(defun ham-flymake-make-inplace-init (use-relative-base-dir use-relative-source build-file-name get-cmdline-f)
  "Create syntax check command line for a directly checked source file."
  (let* ((args nil)
         (buildfile-dir      (flymake-init-find-buildfile-dir buffer-file-name build-file-name)))
    (if buildfile-dir
          (setq args (flymake-get-syntax-check-program-args buffer-file-name buildfile-dir
                                                            use-relative-base-dir use-relative-source
                                                            get-cmdline-f)))
    args))

(defun ham-flymake-java-init ()
  (ham-flymake-make-inplace-init t t "_build.ham" 'ham-flymake-get-ham-cmdline))

;; do nothing because we compile inplace
(defun ham-flymake-java-cleanup () t)

(push '("\\(.*?\\):\\([0-9]+\\): error: \\(.*?\\)\n" 1 2 nil 2 3 (6 compilation-error-face)) flymake-err-line-patterns)
(push '("\\(.*?\\):\\([0-9]+\\): warning: \\(.*?\\)\n" 1 2 nil 2 3 (6 compilation-warning-face)) flymake-err-line-patterns)
(push '(".+\\.java$" ham-flymake-java-init ham-flymake-java-cleanup) flymake-allowed-file-name-masks)
(push '(".+\\.scala$" ham-flymake-java-init ham-flymake-java-cleanup) flymake-allowed-file-name-masks)

;;;======================================================================
;;; Ham shell
;;;======================================================================
(require 'ham-shell)

(Windows
 (setq explicit-ham-shell-file-name (concat HAM_HOME "/bin/nt-x86/bash.exe")))
(Linux
 (setq explicit-ham-shell-file-name "/bin/bash"))
(OSX
 (setq explicit-ham-shell-file-name "/bin/bash"))

(defmacro PrognInHamShell (&rest x)
  (setq prev-shell-file-name shell-file-name)
  (setq shell-file-name explicit-ham-shell-file-name)
  (let ((result (cons 'progn x)))
    (setq shell-file-name prev-shell-file-name)
    result))

(setq shell-file-name explicit-ham-shell-file-name)

;; (setq explicit-bash-ham-startfile "")

(setq explicit-bash-ham-args
      (list
       "--rcfile"
       (concat HAM_HOME "/bin/ham-bash-start.sh")
       "-i"))

;; (setq shell-file-name explicit-ham-shell-file-name)

(add-hook 'comint-output-filter-functions 'ham-shell-strip-ctrl-m nil t)
(add-hook 'comint-output-filter-functions 'comint-watch-for-password-prompt nil t)

(defun ham-previous-input ()
  "Console previous input"
  (interactive)
  (goto-char (point-max))
  (comint-previous-input 1))

(defun ham-next-input ()
  "Console previous input"
  (interactive)
  (goto-char (point-max))
  (comint-next-input 1))

(add-hook 'ham-shell-mode-hook 'n-ham-shell-mode-hook)
(defun n-ham-shell-mode-hook ()
  "shell mode customizations."
  (local-set-key "\M-p" 'ham-previous-input)
  (local-set-key "\M-n" 'ham-next-input)
  (local-set-key "\C-cl" 'ham-ido-shell)
  (local-set-key '[(shift tab)] 'comint-next-matching-input-from-input)
  (setq comint-input-sender 'n-ham-shell-simple-send)
  )

(defun n-ham-shell-simple-send (proc command)
  "Various commands pre-processing before sending to shell."
  (cond
   ;; Checking for clear command and execute it.
   ((string-match "^[ \t]*:?clear[ \t]*$" command)
    (comint-send-string proc "\n")
    (erase-buffer)
    )
   ;; Checking for clear command and execute it.
   ((string-match "^[ \t]*:?clear[        ;& \t]*.*$" command)
    (erase-buffer)
    (comint-simple-send proc command))
   ;; Checking for man command and execute it.
   ((string-match "^[ \t]*man[ \t]*" command)
    (comint-send-string proc "\n")
    (setq command (replace-regexp-in-string "^[ \t]*man[ \t]*" "" command))
    (setq command (replace-regexp-in-string "[ \t]+$" "" command))
    ;;(message (format "command %s command" command))
    (funcall 'man command)
    )
   ;; Send other commands to the default handler.
   (t (comint-simple-send proc command))
   )
  )

(defun ham-shell-unique ()
  (interactive)
  (ham-shell)
  (rename-uniquely))

;;;======================================================================
;;; Hamfile mode
;;;======================================================================
(autoload 'ham-mode "hamfile" nil t)

(add-to-list 'auto-mode-alist '("\\.ham\\'" . ham-mode))
(add-to-list 'auto-mode-alist '("\\Jamfile\\'" . ham-mode))
(add-to-list 'auto-mode-alist '("\\Jamrules\\'" . ham-mode))
(add-to-list 'auto-mode-alist '("\\Jambase\\'" . ham-mode))
(add-to-list 'auto-mode-alist '("\\Hamfile\\'" . ham-mode))
(add-to-list 'auto-mode-alist '("\\Hamrules\\'" . ham-mode))
(add-to-list 'auto-mode-alist '("\\Hambase\\'" . ham-mode))

;;;======================================================================
;;; -ham-shell command line argument
;;;======================================================================
(defun argument-ham-shell-fn (switch)
  (ham-shell))

(add-to-list 'command-switch-alist '("-ham-shell" . argument-ham-shell-fn))
