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

(setopt treesit-enabled-modes t
        treesit-auto-install-grammar 'always)

(defun c-lineup-arglist-tabs-only (ignored)
  "Line up argument lists by tabs, not spaces"
  (let* ((anchor (c-langelem-pos c-syntactic-element))
         (column (c-langelem-2nd-pos c-syntactic-element))
         (offset (- (1+ column) anchor))
         (steps (floor offset c-basic-offset)))
    (* (max steps 1)
       c-basic-offset)))

(with-eval-after-load 'cc-mode
  (c-add-style "linux-kernel"
               '("linux"
                 (c-basic-offset . 8)
                 (c-label-minimum-indentation . 0)
                 (c-offsets-alist
                  (arglist-close         . c-lineup-close-paren)
                  (arglist-cont-nonempty .
                   (c-lineup-gcc-asm-reg c-lineup-arglist))
                  (arglist-intro         . +)
                  (brace-list-intro      . +)
                  (c                     . c-lineup-C-comments)
                  (case-label            . 0)
                  (comment-intro         . c-lineup-comment)
                  (cpp-define-intro      . +)
                  (cpp-macro             . -1000)
                  (cpp-macro-cont        . +)
                  (defun-block-intro     . +)
                  (else-clause           . 0)
                  (func-decl-cont        . +)
                  (inclass               . +)
                  (inher-cont            . c-lineup-multi-inher)
                  (knr-argdecl-intro     . 0)
                  (label                 . -1000)
                  (statement             . 0)
                  (statement-block-intro . +)
                  (statement-case-intro  . +)
                  (statement-cont        . +)
                  (substatement          . +)))))

(setq-default c-default-style '((java-mode . "java")
                                (awk-mode . "awk")
                                (other . "linux-kernel")))

(setq c-ts-mode-indent-style 'linux
      c-ts-indent-offset 8)

(defun rc/c-ts-macro-continuation-p (_node _parent bol &rest _)
  (save-excursion
    (goto-char bol)
    (and (zerop (forward-line -1))
         (progn (end-of-line) (eq (char-before) ?\\)))))

(defun rc/c-ts-top-level-in-preproc-p (_node parent &rest _)
  (let ((p parent))
    (while (and p (treesit-node-match-p
                   p (rx bos "preproc_" (or "if" "ifdef" "elif" "elifdef" "else") eos)))
      (setq p (treesit-node-parent p)))
    (and p (not (equal p parent))
         (treesit-node-match-p p "translation_unit"))))

(defun rc/c-ts-broken-tree-p (_node parent bol &rest _)
  (let ((ppss (save-excursion (syntax-ppss bol))))
    (and (> (car ppss) 0)
         (not (nth 8 ppss))
         parent
         (treesit-node-check (treesit-buffer-root-node) 'has-error)
         (or (treesit-node-match-p parent (rx bos (or "translation_unit" "ERROR") eos))
             (save-excursion (goto-char bol) (looking-at-p "}"))))))

(defun rc/c-ts-open-brace-offset (_node _parent bol &rest _)
  (save-excursion
    (goto-char bol)
    (let ((open (nth 1 (syntax-ppss)))
          (closing (looking-at-p
                    (rx (or "}" (seq (or "case" "default" "public" "private" "protected")
                                     symbol-end))))))
      (cond
       ((or (looking-at-p "#")
            (and (not closing)
                 (looking-at-p (rx (+ (any alnum "_")) (* blank) ":" (not ":")))))
        0)
       ((memq (char-after open) '(?\( ?\[))
        (goto-char (1+ open))
        (current-column))
       (t
        (goto-char open)
        (back-to-indentation)
        (let (paren)
          (while (and (setq paren (nth 1 (syntax-ppss)))
                      (eq (char-after paren) ?\())
            (goto-char paren)
            (back-to-indentation)))
        (+ (current-column) (if closing 0 c-ts-indent-offset)))))))

(defun rc/c-ts-comment-star-p (_node _parent bol &rest _)
  (and (nth 4 (save-excursion (syntax-ppss bol)))
       (save-excursion (goto-char bol) (looking-at-p (rx "*")))))

(defun rc/c-ts-comment-star-offset (_node _parent bol &rest _)
  (save-excursion
    (goto-char (nth 8 (syntax-ppss bol)))
    (1+ (current-column))))

(defun rc/c-ts-kernel-indent-rules ()
  (treesit-simple-indent-add-rules
   (if (derived-mode-p 'c++-ts-mode) 'cpp 'c)
   '((rc/c-ts-macro-continuation-p no-indent)
     (rc/c-ts-top-level-in-preproc-p column-0 0)
     (rc/c-ts-comment-star-p column-0 rc/c-ts-comment-star-offset)
     (rc/c-ts-broken-tree-p column-0 rc/c-ts-open-brace-offset))))

(add-hook 'c-ts-mode-hook 'rc/c-ts-kernel-indent-rules)
(add-hook 'c++-ts-mode-hook 'rc/c-ts-kernel-indent-rules)

(add-hook 'c-mode-hook (lambda ()
                         (interactive)
                         (c-toggle-comment-style -1)))
(add-hook 'c-ts-mode-hook (lambda ()
                            (interactive)
                            (c-ts-mode-toggle-comment-style -1)))

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
(add-to-list 'auto-mode-alist '("\\.[b]\\'" . simpc-mode))

(require 'tatr)

(require 'umka-mode)

(require 'c3-mode)

(rc/require 'zig-mode)

(defun rc/set-up-whitespace-handling ()
  (interactive)
  (whitespace-mode 1)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

(add-hook 'tuareg-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'c++-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'c++-ts-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'c-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'c-ts-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'simpc-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'java-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'java-ts-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'lua-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'lua-ts-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'rust-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'rust-ts-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'zig-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'scala-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'markdown-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'haskell-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'python-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'python-ts-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'erlang-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'asm-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'fasm-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'go-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'go-ts-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'nim-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'yaml-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'yaml-ts-mode-hook 'rc/set-up-whitespace-handling)
(add-hook 'porth-mode-hook 'rc/set-up-whitespace-handling)

(defun rc/tab-display ()
  (let ((width (- tab-width
                  (% (save-excursion
                       (goto-char (match-beginning 0))
                       (current-column))
                     tab-width))))
    `(face nil display ,(propertize (concat "»" (make-string (1- width) ?\s))
                                    'face 'whitespace-tab))))

(defun rc/set-up-c-tabs ()
  (interactive)
  (require 'whitespace)
  (setq-local tab-width 8
              indent-tabs-mode t
              c-basic-offset 8
              c-tab-always-indent nil
              tab-always-indent nil
              fill-column 100
              backward-delete-char-untabify-method nil
              whitespace-style (seq-difference whitespace-style
                                               '(tab-mark space-mark indentation space-after-tab space-before-tab)))
  (add-to-list (make-local-variable 'font-lock-extra-managed-props) 'display)
  (font-lock-add-keywords nil '(("\t" 0 (rc/tab-display))) t))

(add-hook 'c++-mode-hook 'rc/set-up-c-tabs)
(add-hook 'c-mode-hook 'rc/set-up-c-tabs)
(add-hook 'c-ts-mode-hook 'rc/set-up-c-tabs)
(add-hook 'c++-ts-mode-hook 'rc/set-up-c-tabs)
(add-hook 'simpc-mode-hook 'rc/set-up-c-tabs)
(add-hook 'simpc-mode-hook
          (lambda ()
            (local-set-key (kbd "TAB") 'self-insert-command)))

(editorconfig-mode 1)

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

(setq company-show-quick-access t
      company-require-match nil)

(dolist (key '("RET" "<return>" "C-n" "C-p" "<up>" "<down>" "C-w" "C-s"))
  (define-key company-active-map (kbd key) nil))
(define-key company-active-map (kbd "TAB") #'company-complete-selection)
(define-key company-active-map (kbd "<tab>") #'company-complete-selection)

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
(add-hook 'typescript-ts-mode-hook 'rc/turn-on-tide-and-flycheck)

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
     "astyle --indent=force-tab=8 --min-conditional-indent=0 --max-continuation-indent=120 --keep-one-line-blocks"
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

(global-set-key (kbd "C-S-v") 'yank)
