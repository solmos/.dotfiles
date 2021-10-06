;;; +ess.el -*- lexical-binding: t; -*-

;; Copyright (C) 2021 Atanas Janackovski

;; Author: Atanas Janackovski <atanas.atanas@gmail.com>

;; Note: the evil bindings are taken from the spacemacs, and the actual
;; configuration is taken from numerous others, including the spacesmacs one,
;; apologies that I cannot remember them all (if/when I do, I will be sure to
;; add).

;; spacemacs credit:

;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs

;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;

;;; Commentary:
;;
;; Emacs Package configurations template.
;;

;;; Code:

;; =============================================================================
;; R-IDE
;; =============================================================================

;; (set-popup-rule! "^\\*R" :ignore t)

(use-package! ess
  ;; :ensure t
  :demand t
  :init
  (require 'ess-site)
  :config
  (setq display-buffer-alist
        `(("*R Dired"
           (display-buffer-reuse-window display-buffer-in-side-window)
           (side . right)
           (slot . -1)
           (window-width . 0.33)
           (reusable-frames . nil))
          ("*R"
           (display-buffer-reuse-window display-buffer-in-side-window)
           (side . right)
           (window-width . 0.5)
           (reusable-frames . nil))
          ("*Help"
           (display-buffer-reuse-window display-buffer-below-selected)
           (side . left)
           (slot . 1)
           (window-width . 0.33)
           (reusable-frames . nil)))
        )
  (setq ess-style 'DEFAULT
        ;; auto-width
        ess-auto-width 'window
        ;; let lsp manage lintr
        ess-use-flymake nil
        ;; Stop R repl eval from blocking emacs.
        ess-eval-visibly 'nowait
        ess-use-eldoc t
        ess-eldoc-show-on-symbol nil
        ess-use-company t
        )

  (setq ess-ask-for-ess-directory t
        ess-local-process-name "R"
        ansi-color-for-comint-mode 'filter
        comint-scroll-to-bottom-on-input t
        comint-scroll-to-bottom-on-output t
        comint-move-point-for-output t)
  (setq tab-width 2)

  (setq ess-r-fetch-ESSR-on-remotes 'ess-remote)
  ;; insert pipes etc...
  (defun tide-insert-assign ()
    "Insert an assignment <-"
    (interactive)
    (insert " <- "))
  (defun tide-insert-pipe ()
    "Insert a %>% and newline"
    (interactive)
    (insert " %>%"))
  ;; set keybindings
  ;; insert pipe
  (define-key ess-r-mode-map (kbd "C-'") 'tide-insert-assign)
  (define-key inferior-ess-r-mode-map (kbd "C-'") 'tide-insert-assign)
  ;; insert assign
  (define-key ess-r-mode-map (kbd ";") 'tide-insert-pipe)
  (define-key inferior-ess-r-mode-map (kbd ";") 'tide-insert-pipe)
  )

(add-hook! inferior-ess-mode-hook
  (setq-local comint-use-prompt-regexp nil)
  (setq-local inhibit-field-text-motion nil))

;; ess-view
;; open a df in an external app
;; TODO need to find out how to display options vertically
(use-package! ess-view
  ;; :ensure t
  :after ess
  :diminish
  :config
  (setq ess-view--spreadsheet-program "open") ; open in system default on macos
  (setq ess-view-inspect-and-save-df t)
  ;; enable ess-view package to be triggered from the source doc
  ;; see: <https://github.com/GioBo/ess-view/issues/9>
  (defun ess-view-extract-R-process ()
    "Return the name of R running in current buffer."
    (let*
        ((proc (ess-get-process))         ; Modified from (proc (get-buffer-process (current-buffer)))
         (string-proc (prin1-to-string proc))
         (selected-proc (s-match "^#<process \\(R:?[0-9]*\\)>$" string-proc)))
      (nth 1 (-flatten selected-proc))
      )
    )
  :bind
  (
   ("C-c C-e C-v" . ess-view-inspect-df)
   ;; the below doesn't work on osx
   ;; see <https://github.com/GioBo/ess-view/issues/5>
   ;; ("C-x q" . ess-view-inspect-and-save-df)
   )
  )

(use-package! ess-view-data
  :after ess
  :init
  (require 'ess-view-data))

;; R helprs
(defun pos-paragraph ()
      (backward-paragraph)
      ;; (next-line 1)
      (forward-line 1)
      (beginning-of-line)
      (point))

(defun highlight-piped-region ()
  (let ((end (point))
        (beg (pos-paragraph)))
    (set-mark beg)
    (goto-char end)
    (end-of-line)
    (deactivate-mark)
    (setq last-point (point))
    (goto-char end)
    (buffer-substring-no-properties beg last-point)))

(defun ess-run-partial-pipe ()
  (interactive)
  (let ((string-to-execute (highlight-piped-region)))
    ;; https://stackoverflow.com/questions/65882345/replace-last-occurence-of-regexp-in-a-string-which-has-new-lines-replace-regexp/65882683#65882683
    (ess-eval-linewise
     (replace-regexp-in-string
      ".+<-" "" (replace-regexp-in-string
                 "\\(\\(.\\|\n\\)*\\)\\(%>%\\|\+\\) *\\'" "\\1" string-to-execute)))))

(define-key ess-mode-map (kbd "C-.") 'ess-run-partial-pipe)

;; keybindings
;; ==============================================================================
(map! (:localleader
       :map ess-r-mode-map
       :prefix-map ("c" . "ess")
       "v"      #'ess-view-inspect-df
       "c"       'ess-tide-insert-chunk
       "w"       'ess-eval-word
       "r"       'ess-run-partial-pipe)
      )

;; Interaction with REPL
(map! (:localleader
       :map ess-r-mode-map
       "w"       'ess-eval-word
       "e"       'ess-eval-paragraph-and-step
       "i"       'ess-interrupt
       "n"       'ess-debug-command-next
       "l"       'ess-eval-line-and-step)
      )

;; Graphics management
(map! (:localleader
       :map ess-r-mode-map
       :prefix-map ("g" . "Graphics")
       "o"      'ess-gdev-open-remote-pdf
       "g"      'ess-gdev-save-pdf))

;; Viewing objects
(map! (:localleader
       :map ess-r-mode-map
       :prefix-map ("d" . "Display")
       "d"      'ess-glimpse-df-at-point
       "s"      'ess-summary-at-point))

;; Targets/Drake projects
(map! (:localleader
       :map ess-r-mode-map
       :prefix-map ("t" . "targets")
       "l"      'ess-load-project-packages
       "t"      'ess-loadd-drake-target-at-point))

(map! :localleader
      :map (polymode-minor-mode-map markdown-mode-map ess-r-mode-map)
      "P" 'polymode-map
      )
(define-key ess-mode-map (kbd "<C-return>") 'ess-eval-line-and-step)

(global-set-key (kbd "C-c r") 'ess-switch-to-inferior-or-script-buffer)

;; ===========================================================
;; Polymode
;; ===========================================================

;; basic polymode
(use-package! polymode
  ;; :ensure t
  :config
  (use-package! poly-R)
  (use-package! poly-markdown)
  (use-package! poly-noweb)
  (add-to-list 'auto-mode-alist '("\\.md" . poly-markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.Snw" . poly-noweb+r-mode))
  (add-to-list 'auto-mode-alist '("\\.Rnw" . poly-noweb+r-mode))
  (add-to-list 'auto-mode-alist '("\\.Rmd" . poly-markdown+r-mode))
  ;; Export files with the same name as the main file
  (setq polymode-exporter-output-file-format "%s")
  )

;; for use in Rmarkdown documents
(use-package! markdown-mode
  :config
  (define-key markdown-mode-map (kbd "M-s-'") 'tide-insert-assign)
  (define-key markdown-mode-map (kbd "M-s-\"") 'tide-insert-pipe)
  )
;; ===========================================================
;; IDE Functions
;; ===========================================================

;; Bring up empty R script and R console for quick calculations
(defun ess-tide-scratch ()
  (interactive)
  (progn
    (delete-other-windows)
    (setq new-buf (get-buffer-create "scratch.R"))
    (switch-to-buffer new-buf)
    (R-mode)
    (setq w1 (selected-window))
    (setq w1name (buffer-name))
    (setq w2 (split-window w1 nil t))
    (if (not (member "*R*" (mapcar (function buffer-name) (buffer-list))))
        (R))
    (set-window-buffer w2 "*R*")
    (set-window-buffer w1 w1name)))

(global-set-key (kbd "C-x 9") 'ess-tide-R-scratch)

;; Not sure if need this as plymode has something similar
(defun ess-tide-shiny-run-app (&optional arg)
  "Interface for `shiny::runApp()'. With prefix ARG ask for extra args."
  (interactive)
  (inferior-ess-r-force)
  (ess-eval-linewise
   "shiny::runApp(\".\")\n" "Running app" arg
   '("" (read-string "Arguments: " "recompile = TRUE"))))

;; Graphics device management ===========================================
(defun ess-tide-new-gdev ()
  "create a new graphics device"
  (interactive)
  (ess-eval-linewise "dev.new()"))

(defun ess-gdev-save-png ()
  "Save current graphics as png"
  (interactive)
  (ess-eval-linewise "png(width = 800)")
  (ess-eval-paragraph t)
  (ess-eval-linewise "dev.off()"))

(defun ess-gdev-save-pdf ()
  "Save current graphics as png"
  (interactive)
  (ess-eval-linewise "pdf('~/scratch/Rplots.pdf')")
  (ess-eval-paragraph t)
  (ess-eval-linewise "dev.off()"))

(defun ess-gdev-open-remote-pdf ()
  "Open remote Rplots.pdf"
  (interactive)
  (let ((remote-root "/run/user/1001/gvfs/sftp:host=isgws06.isglobal.lan,user=solmos/home/isglobal.lan/solmos/scratch/Rplots.pdf")
        (default-directory temporary-file-directory))
    (async-shell-command (concat "evince " remote-root))))

;; Viewing data/objects =================================================
(defun ess-summary-at-point ()
  (interactive)
  (let ((x (ess-edit-word-at-point)))
    (ess-eval-linewise (concat "summary(" x ")"))))

(defun ess-glimpse-df-at-point ()
  "Show a glimpse of the data frame in the console"
  (interactive)
  (let ((x (ess-edit-word-at-point)))
    (ess-eval-linewise (concat "glimpse(" x ")"))))

;; drake/targets projects ==============================================
(defun drake-r-make ()
  "Make drake plan"
  (interactive)
  (ess-eval-linewise "drake::r_make()")
  )
(defun ess-eval-drake-r-outdated ()
  "Make drake plan"
  (interactive)
  (ess-eval-linewise "drake::r_outdated()")
  )
(defun ess-loadd-drake-target-at-point ()
  "Show a glimpse of the data frame in the console"
  (interactive)
  (let ((x (ess-edit-word-at-point)))
      (ess-eval-linewise (concat "drake::loadd(" x")"))))
(defun ess-load-project-packages ()
  "Load packages.R when current working directory is project root"
  (interactive)
  (ess-eval-linewise "source('R/packages.R')"))

;; Devtools
(defun ess-tide-devtools-setup ()
  "setup R package in current working directory"
  (interactive)
  (ess-eval-linewise "devtools::setup()"))

;;======================================================================
;; (R) markdown mode
;;======================================================================

;; Insert new chunk for Rmarkdown
(defun ess-tide-insert-chunk (header)
  "Insert an r-chunk in markdown mode."
  (interactive "sLabel: ")
  (insert (concat "```{r " header "}\n\n```"))
  (forward-line -1))

(global-set-key (kbd "C-c C-i") 'ess-tide-insert-chunk)

;; Mark a word at a point ==============================================
;; http://www.emacswiki.org/emacs/ess-edit.el
(defun ess-edit-word-at-point ()
  (save-excursion
    (buffer-substring
     (+ (point) (skip-chars-backward "a-zA-Z0-9._"))
     (+ (point) (skip-chars-forward "a-zA-Z0-9._")))))
;; eval any word where the cursor is (objects, functions, etc)
(defun ess-eval-word ()
  (interactive)
  (let ((x (ess-edit-word-at-point)))
    (ess-eval-linewise (concat x)))
  )
;; key binding
(define-key ess-mode-map (kbd "C-c r") 'ess-eval-word)

;; provide ess configuration
(provide '+ess)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; +ess.el ends here
