;;; cycle-file-diff.el --- cycle through a file's changes since its last commit.

;; Copyright (C) 2015-2016 jack angers
;; Author: jack angers
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.3") (s "1.11.0") (dash "2.9.0"))
;; Keywords: programming

;; Cycle File Diff is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; Cycle File Diff is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
;; License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with Cycle File Diff.  If not, see http://www.gnu.org/licenses.

;;; Commentary:

;; Cycle File Diff makes it easy to move to different chunks of code that you've edited
;; since the last time you committed the file.

;;; Code:
(require 's)
(require 'dash)

(defvar cfd-git-cmd "git --no-pager -c diff.autorefreshindex=0 diff --no-color --no-ext-diff --relative -U0 %s")

(defun cfd-get-file-diff-line-starts ()
  "Get the line numbers of all the edited chunks for the current file."
  (let* ((cmd (format cfd-git-cmd (buffer-file-name)))
         (cur-line (line-number-at-pos))
         (rawresults (shell-command-to-string cmd))
         (regex "\+\\([0-9]+\\)[,0-9]*\s@@")
         (matches (s-match-strings-all regex rawresults))
         (lines (--map (string-to-number (nth 1 it)) matches)))
    (--filter (not (= it cur-line)) lines)))


(defun cfd-next ()
  "Go to do the next edited chunk of code."
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
  "Go to do the previous edited chunk of code."
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

(provide 'cycle-file-diff)
;;; cycle-file-diff.el ends here
