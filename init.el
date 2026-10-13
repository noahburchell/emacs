;;; -*- lexical-binding: t -*-

(setq custom-file (locate-user-emacs-file "custom.el"))
(setq load-prefer-newer t)

(add-to-list 'load-path (locate-user-emacs-file "local/"))

(load (locate-user-emacs-file "rc/rc") nil t)

(load (locate-user-emacs-file "rc/misc-rc") nil t)
(load (locate-user-emacs-file "rc/org-mode-rc") nil t)
(load (locate-user-emacs-file "rc/autocommit-rc") nil t)

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)

(rc/require-theme 'gruber-darker)
(set-face-attribute 'line-number nil :inherit 'default)

(rc/require 'smex 'ido-completing-read+)

(require 'ido-completing-read+)

(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

(setq-default c-basic-offset 4
              c-default-style '((java-mode . "java")
                                (awk-mode . "awk")
                                (other . "bsd")))

(add-hook 'c-mode-hook (lambda ()
                         (interactive)
                         (c-toggle-comment-style -1)))

(rc/require 'paredit)

(defun rc/turn-on-paredit ()
  (interactive)
  (paredit-mode 1))

(add-hook 'emacs-lisp-mode-hook  'rc/turn-on-paredit)
(add-hook 'clojure-mode-hook     'rc/turn-on-paredit)
(add-hook 'lisp-mode-hook        'rc/turn-on-paredit)
(add-hook 'common-lisp-mode-hook 'rc/turn-on-paredit)
(add-hook 'scheme-mode-hook      'rc/turn-on-paredit)
(add-hook 'racket-mode-hook      'rc/turn-on-paredit)

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-j")
                           (quote eval-print-last-sexp))))
(add-to-list 'auto-mode-alist '("Cask" . emacs-lisp-mode))

(rc/require 'uxntal-mode)

(rc/require 'haskell-mode)

(setq haskell-process-type 'cabal-new-repl)
(setq haskell-process-log t)

(add-hook 'haskell-mode-hook 'haskell-indent-mode)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(add-hook 'haskell-mode-hook 'haskell-doc-mode)

(require 'basm-mode)

(require 'fasm-mode)
(add-to-list 'auto-mode-alist '("\\.asm\\'" . fasm-mode))

(require 'porth-mode)

(require 'noq-mode)

(require 'jai-mode)

(require 'simpc-mode)
(add-to-list 'auto-mode-alist '("\\.[hc]\\(pp\\)?\\'" . simpc-mode))
(add-to-list 'auto-mode-alist '("\\.[b]\\'" . simpc-mode))

(require 'tatr)

(require 'umka-mode)

(require 'c3-mode)

(defun rc/set-up-whitespace-handling ()
  (interactive)
  (whitespace-mode 1)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

(add-hook 'tuareg-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'c++-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'c-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'simpc-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'java-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'lua-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'rust-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'scala-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'markdown-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'haskell-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'python-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'erlang-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'asm-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'fasm-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'go-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'nim-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'yaml-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'porth-mode-hook 'rc/set-up-whitespace-handling)

(global-display-line-numbers-mode)

(rc/require 'magit)

(setq magit-auto-revert-mode nil)

(global-set-key (kbd "C-c m s") 'magit-status)
(global-set-key (kbd "C-c m l") 'magit-log)

(rc/require 'multiple-cursors)

(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->")         'mc/mark-next-like-this)
(global-set-key (kbd "C-<")         'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<")     'mc/mark-all-like-this)
(global-set-key (kbd "C-\"")        'mc/skip-to-next-like-this)
(global-set-key (kbd "C-:")         'mc/skip-to-previous-like-this)

(require 'dired-x)
(setq dired-omit-files
      (concat dired-omit-files "\\|^\\..+$"))
(setq-default dired-dwim-target t)
(setq dired-listing-switches "-alh")
(setq dired-mouse-drag-files t)

(rc/require 'helm 'helm-org)

(setq helm-ff-transformer-show-only-basename nil)

(global-set-key (kbd "C-c h f") 'helm-find)
(global-set-key (kbd "C-c h a") 'helm-org-agenda-files-headings)
(global-set-key (kbd "C-c h r") 'helm-recentf)

(rc/require 'yasnippet)

(require 'yasnippet)

(setq yas-triggers-in-field nil)
(setq yas-snippet-dirs (list (locate-user-emacs-file "snippets/")))

(yas-global-mode 1)

(defun rc/enable-word-wrap ()
  (interactive)
  (toggle-word-wrap 1))

(add-hook 'markdown-mode-hook 'rc/enable-word-wrap)

(add-to-list 'auto-mode-alist '("\\.html\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.xsd\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.ant\\'" . nxml-mode))

(setq tramp-auto-save-directory "/tmp")

(rc/require 'powershell)
(add-to-list 'auto-mode-alist '("\\.ps1\\'" . powershell-mode))
(add-to-list 'auto-mode-alist '("\\.psm1\\'" . powershell-mode))

(defun rc/turn-on-eldoc-mode ()
  (interactive)
  (eldoc-mode 1))

(add-hook 'emacs-lisp-mode-hook 'rc/turn-on-eldoc-mode)

(rc/require 'company)
(require 'company)

(global-company-mode)

(add-hook 'tuareg-mode-hook
          (lambda ()
            (interactive)
            (company-mode 0)))

(rc/require 'typescript-mode)
(add-to-list 'auto-mode-alist '("\\.mts\\'" . typescript-mode))

(rc/require 'tide)

(defun rc/turn-on-tide-and-flycheck ()
  (interactive)
  (tide-setup)
  (flycheck-mode 1))

(add-hook 'typescript-mode-hook 'rc/turn-on-tide-and-flycheck)

(rc/require 'proof-general)
(add-hook 'coq-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-q C-n")
                           (quote proof-assert-until-point-interactive))))

(add-hook 'tex-mode-hook
          (lambda ()
            (interactive)
            (add-to-list 'tex-verbatim-environments "code")))

(setq font-latex-fontify-sectioning 'color)

(rc/require 'move-text)
(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)

(add-to-list 'auto-mode-alist '("\\.ebi\\'" . lisp-mode))

(rc/require
 'scala-mode
 'd-mode
 'yaml-mode
 'glsl-mode
 'tuareg
 'lua-mode
 'less-css-mode
 'graphviz-dot-mode
 'clojure-mode
 'cmake-mode
 'rust-mode
 'csharp-mode
 'nim-mode
 'jinja2-mode
 'markdown-mode
 'purescript-mode
 'nix-mode
 'dockerfile-mode
 'toml-mode
 'nginx-mode
 'kotlin-mode
 'go-mode
 'php-mode
 'racket-mode
 'qml-mode
 'ag
 'elpy
 'typescript-mode
 'rfc-mode
 'sml-mode)

(defun astyle-buffer (&optional justify)
  (interactive)
  (unless (executable-find "astyle")
    (user-error "astyle-buffer: astyle not found"))
  (let ((saved-line-number (line-number-at-pos)))
    (shell-command-on-region
     (point-min)
     (point-max)
     "astyle --style=kr"
     nil
     t)
    (goto-char (point-min))
    (forward-line (1- saved-line-number))))

(add-hook 'simpc-mode-hook
          (lambda ()
            (interactive)
            (setq-local fill-paragraph-function 'astyle-buffer)))

(require 'compile)

(add-to-list 'compilation-error-regexp-alist
             '("\\([a-zA-Z0-9\\.]+\\)(\\([0-9]+\\)\\(,\\([0-9]+\\)\\)?) \\(Warning:\\)?"
               1 2 (4) (5)))

(load custom-file t t)

(define-key key-translation-map [?\C-h] [?\C-?])
