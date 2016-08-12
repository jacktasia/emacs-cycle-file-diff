(require 's)
(require 'dash)

(defvar cfd-git-cmd "git --no-pager -c diff.autorefreshindex=0 diff --no-color --no-ext-diff --relative -U0 %s")

(defun cfd-get-file-diff-line-starts ()
  (interactive)
  (let* ((cmd (format cfd-git-cmd (buffer-file-name)))
         (cur-line (line-number-at-pos))
         (rawresults (shell-command-to-string cmd))
         (regex "\+\\([0-9]+\\)[,0-9]*\s@@")
         (matches (s-match-strings-all regex rawresults))
         (lines (--map (string-to-number (nth 1 it)) matches)))
    (--filter (not (= it cur-line)) lines)))


(defun cfd-next ()
  (interactive)
  (let* ((lines (cfd-get-file-diff-line-starts))
        (cur-line (line-number-at-pos))
        (usable-lines (--filter (< cur-line it) lines)))
    (if lines
      (if (> (length usable-lines) 0)
          (goto-line (car usable-lines))
        (goto-line (car lines)))
      (message "%s" "Nowhere to cycle to."))))

(defun cfd-prev ()
  (interactive)
  (let* ((lines (cfd-get-file-diff-line-starts))
        (cur-line (line-number-at-pos))
        (usable-lines (--filter (> cur-line it) lines)))
    (if lines
      (if (> (length usable-lines) 0)
          (goto-line (car (last usable-lines)))
        (goto-line (car (last lines))))
      (message "%s" "Nowhere to cycle to."))))

(global-set-key (kbd "C-c 8") 'cfd-prev)
(global-set-key (kbd "C-c 9") 'cfd-next)
