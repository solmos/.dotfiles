;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Sergio Olmos"
      user-mail-address "s.olmos.pardo@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
;;
(setq doom-font (font-spec :family "Fira Code Retina" :size 15)
      doom-variable-pitch-font (font-spec :family "Merriweather" :size 15))

(setq fancy-splash-image "~/Downloads/emacs-e.svg")
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-flatwhite)

;; Make REPL buffer appear in switch-buffer list
(setq persp-add-buffer-on-after-change-major-mode t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!

(setq org-directory "~/org/"
      org-agenda-files '("~/org/todo.org"
                         "~/org/projects.org")
      org-log-done 'time)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((ditaa . t)))

;; Org roam
(setq org-roam-directory "~/org/roam/")
(setq +org-roam-open-buffer-on-find-file nil)

;; Open pdf links in org mode with default emacs app (pdf-tools)
(after! org
  (setq org-file-apps
        '((auto-mode . emacs)
          (directory . emacs)
          ("\\.mm\\'" . default)
          ("\\.x?html?\\'" . default)
          ("\\.pdf\\'" . emacs))))

(after! org
  (add-to-list 'org-capture-templates
               '("d" "ToDo [inbox]" entry
                 (file+headline "~/org/todo.org" "Inbox")
                 "* TODO %i%?")
               ))

(add-hook! 'org-mode-hook
           #'+org-pretty-mode
           #'mixed-pitch-mode
           (lambda () (display-line-numbers-mode -1)))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Display major mode icon in the modeline
(setq doom-modeline-major-mode-icon t)

;; Elfeed
(add-hook! 'elfeed-show-mode-hook
           (lambda () (buffer-face-set 'doom-variable-pitch-font)))

;; Let TRAMP know where to find programs on remote machines
(after! tramp
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

;; Display output buffer only when command generates output
(setq async-shell-command-display-buffer nil)

;; Make sure recentf doesn't try to open remote files when it shouldn't
(after! recentf
  (add-to-list 'recentf-keep `remote-file-p))

;; Load personal ESS config
(load! "+ess")

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
