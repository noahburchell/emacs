;;; -*- lexical-binding: t -*-

(setq custom-file (locate-user-emacs-file "custom.el")
      load-prefer-newer t)

;;; packages

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(defvar rc/package-contents-refreshed nil)

(defun rc/require (&rest packages)
  (dolist (package packages)
    (unless (package-installed-p package)
      (unless rc/package-contents-refreshed
        (setq rc/package-contents-refreshed t)
        (package-refresh-contents))
      (package-install package))))

(rc/require 'gruber-darker-theme 'rainbow-delimiters 'smex 'ido-completing-read+
            'company 'yasnippet 'multiple-cursors 'move-text 'magit 'nasm-mode)

;;; ui

(column-number-mode 1)
(show-paren-mode 1)

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

(setq-default inhibit-splash-screen t
              make-backup-files nil
              indent-tabs-mode nil
              compilation-scroll-output t)

(setq warning-minimum-level :error
      confirm-kill-emacs 'y-or-n-p
      whitespace-style '(face tabs spaces trailing space-before-tab newline indentation
                         empty space-after-tab space-mark tab-mark))

;;; theme

(load-theme 'gruber-darker t)

(custom-theme-set-faces
 'gruber-darker
 ;; subtle current line, the theme only offers highlight at #282828
 '(hl-line ((t (:background "#1e1e1e" :extend t))))
 '(line-number-current-line ((t (:inherit line-number :foreground "#ffdd33" :background "#1e1e1e")))))
(enable-theme 'gruber-darker)

(global-hl-line-mode 1)

;;; minibuffer

(require 'ido-completing-read+)
(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)

(global-set-key (kbd "M-x") 'smex)

;;; editing

(electric-pair-mode 1)
(editorconfig-mode 1)
(windmove-default-keybindings)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

(setq xref-search-program 'ripgrep
      grep-command "rg -nH --no-heading -e ")

(require 'yasnippet)
(setq yas-triggers-in-field nil
      yas-snippet-dirs (list (locate-user-emacs-file "snippets/")))
(yas-global-mode 1)

(require 'company)
(setq company-show-quick-access t
      company-require-match nil)
(global-company-mode 1)
(dolist (key '("RET" "<return>" "C-n" "C-p" "<up>" "<down>" "C-w" "C-s"))
  (define-key company-active-map (kbd key) nil))
(define-key company-active-map (kbd "TAB") #'company-complete-selection)
(define-key company-active-map (kbd "<tab>") #'company-complete-selection)

(global-set-key (kbd "C-S-c")       'kill-ring-save)
(global-set-key (kbd "C-c e")       'mc/edit-lines)
(global-set-key (kbd "C->")         'mc/mark-next-like-this)
(global-set-key (kbd "C-<")         'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<")     'mc/mark-all-like-this)
(global-set-key (kbd "C-\"")        'mc/skip-to-next-like-this)
(global-set-key (kbd "C-:")         'mc/skip-to-previous-like-this)

(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)

(setq magit-auto-revert-mode nil)
(global-set-key (kbd "C-c m s") 'magit-status)
(global-set-key (kbd "C-c m l") 'magit-log)

(require 'dired-x)
(setq dired-listing-switches "-alh"
      dired-mouse-drag-files t)
(setq-default dired-dwim-target t)

(global-set-key (kbd "C-x C-g") 'find-file-at-point)
(global-set-key (kbd "C-c i m") 'imenu)
(global-set-key (kbd "C-S-v") 'yank)

(defun rc/kill-region-or-backward-word ()
  (interactive)
  (call-interactively (if (use-region-p) 'kill-region 'backward-kill-word)))

(global-set-key (kbd "C-w") 'rc/kill-region-or-backward-word)

(defun rc/kill-other-buffers ()
  (interactive)
  (let ((current (current-buffer)))
    (dolist (buffer (buffer-list))
      (let ((name (buffer-name buffer)))
        (unless (or (null name)
                    (eq buffer current)
                    (string-prefix-p " " name)
                    (member name '("*scratch*" "*Messages*")))
          (kill-buffer buffer))))))

(global-unset-key (kbd "M-k"))
(global-set-key (kbd "M-k M-k M-k") 'rc/kill-other-buffers)

;; used by the mit snippet
(defun rc/git-author ()
  (let ((get (lambda (key)
               (or (car (ignore-errors (process-lines "git" "config" "--get" key))) ""))))
    (format "%s <%s>" (funcall get "user.name") (funcall get "user.email"))))

;;; whitespace and tabs

(require 'whitespace)

(defun rc/set-up-whitespace ()
  (whitespace-mode 1)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

;; tabs are marked through the display table, a display string on a tab makes
;; current-column count its width and breaks the tab-width 1000 trick below
(defun rc/set-up-tabs ()
  (setq-local tab-width 8
              indent-tabs-mode t
              tab-always-indent nil
              fill-column 100
              backward-delete-char-untabify-method nil
              whitespace-style (seq-difference whitespace-style
                                               '(space-mark indentation
                                                 space-after-tab space-before-tab)))
  (rc/set-up-whitespace))

;;; tree-sitter

(setopt treesit-enabled-modes t
        treesit-auto-install-grammar 'always
        treesit-font-lock-level 4)

;;; c

(add-to-list 'auto-mode-alist '("\\.h\\'" . c-ts-mode))

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
          (closing (looking-at-p "}"))
          (case-label (looking-at-p (rx (or "case" "default") symbol-end))))
      (cond
       ((or (looking-at-p "#")
            (and (not closing) (not case-label)
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
   'c
   '((rc/c-ts-macro-continuation-p no-indent)
     (rc/c-ts-top-level-in-preproc-p column-0 0)
     (rc/c-ts-comment-star-p column-0 rc/c-ts-comment-star-offset)
     (rc/c-ts-broken-tree-p column-0 rc/c-ts-open-brace-offset)
     ((node-is "case_statement") standalone-parent c-ts-indent-offset)
     ((parent-is "case_statement") parent c-ts-indent-offset)
     ((parent-is "conditional_expression") parent 0))))

(defun rc/c-ts-line-comments ()
  (c-ts-mode-toggle-comment-style -1))

;; tab-width 1000 makes indent-to spend tabs on indent levels only, alignment stays spaces
(defun rc/c-ts-indent-with-smart-tabs (indent &rest args)
  (if indent-tabs-mode
      (let ((tab-width 1000)
            (c-ts-indent-offset 1000))
        (apply indent args))
    (apply indent args)))

(defun rc/c-ts-smart-tabs ()
  (add-function :around (local 'indent-line-function) #'rc/c-ts-indent-with-smart-tabs)
  (add-function :around (local 'indent-region-function) #'rc/c-ts-indent-with-smart-tabs))

(add-hook 'c-ts-mode-hook 'rc/c-ts-kernel-indent-rules)
(add-hook 'c-ts-mode-hook 'rc/c-ts-line-comments)
(add-hook 'c-ts-mode-hook 'rc/set-up-tabs)
(add-hook 'c-ts-mode-hook 'rc/c-ts-smart-tabs)
(add-hook 'c-ts-mode-hook 'eglot-ensure)

;;; python

(add-hook 'python-ts-mode-hook 'rc/set-up-whitespace)
(add-hook 'python-ts-mode-hook 'eglot-ensure)

;;; nasm

(add-to-list 'auto-mode-alist '("\\.asm\\'" . nasm-mode))

(with-eval-after-load 'nasm-mode
  (define-key nasm-mode-map (kbd ":") nil)
  (define-key nasm-mode-map (kbd ";") nil)
  (define-key nasm-mode-map [remap join-line] nil)
  (define-key nasm-mode-map (kbd "TAB") 'self-insert-command)
  (define-key nasm-mode-map (kbd "RET") 'rc/nasm-newline))

;; bound to RET rather than indent-line-function, so nothing ever reindents an existing line
(defun rc/nasm-newline ()
  (interactive)
  (let* ((end (point))
         (prefix (save-excursion
                   (beginning-of-line)
                   (skip-chars-forward " \t" end)
                   (buffer-substring-no-properties (line-beginning-position) (point)))))
    (newline)
    (insert prefix)))

(defun rc/nasm-comment-indent ()
  (let* ((code (save-excursion
                 (skip-chars-backward " \t")
                 (unless (bolp) (1+ (current-column)))))
         (col (max comment-column (or code 0)))
         (col (* tab-width (/ (+ col tab-width -1) tab-width))))
    (if code (cons col col) col)))

(defun rc/set-up-nasm ()
  (setq-local indent-line-function 'ignore
              comment-indent-function 'rc/nasm-comment-indent))

(add-hook 'nasm-mode-hook 'rc/set-up-nasm)
(add-hook 'nasm-mode-hook 'rc/set-up-tabs)

;;; org

;; a directory in org-agenda-files means every .org file directly inside it
(setq org-directory "~/Documents/Notes/Org/"
      org-agenda-files (list org-directory))

(global-set-key (kbd "C-c a") 'org-agenda)

;;; eglot

(defun rc/eglot-format ()
  (interactive)
  (if (and (derived-mode-p 'c-ts-mode)
           (not (locate-dominating-file default-directory ".clang-format")))
      (user-error "eglot-format: no .clang-format found, clangd falls back to llvm style")
    (call-interactively 'eglot-format)))

(defun rc/set-up-eglot ()
  (setq-local company-minimum-prefix-length 1
              company-idle-delay 0.1)
  (when (and (derived-mode-p 'c-ts-mode) (eglot-managed-p))
    (eglot-inlay-hints-mode -1)))

(add-hook 'eglot-managed-mode-hook 'rc/set-up-eglot)

(with-eval-after-load 'eglot
  (setq eglot-autoshutdown t
        eglot-events-buffer-config '(:size 0)
        ;; clangd reformats on newline in llvm style when no .clang-format exists
        eglot-ignored-server-capabilities '(:documentOnTypeFormattingProvider)
        eglot-semantic-token-types '("namespace" "type" "class" "enum" "interface"
                                     "struct" "typeParameter" "parameter" "variable"
                                     "property" "enumMember" "function" "method"
                                     "macro")
        eglot-semantic-token-modifiers '("readonly" "deprecated"))
  ;; emacs 31 gates flymake on trusted-content, eglot only relays server diagnostics
  (put 'eglot-flymake-backend 'flymake-always-safe t)
  ;; without -x clangd parses .h files as objective-c++
  (add-to-list 'eglot-server-programs
               '(c-ts-mode . ("clangd" :initializationOptions (:fallbackFlags ["-xc" "-std=gnu23"]))))
  (define-key eglot-mode-map (kbd "C-c l r") 'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c l a") 'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c l f") 'rc/eglot-format)
  (define-key eglot-mode-map (kbd "C-c l h") 'eglot-inlay-hints-mode)
  (define-key eglot-mode-map (kbd "C-c l n") 'flymake-goto-next-error)
  (define-key eglot-mode-map (kbd "C-c l p") 'flymake-goto-prev-error))

(load custom-file t t)

;;; org

(setq-default fill-column 100)
(setq sentence-end-double-space nil)

(defun rc/org-fill-buffer ()
  "fill every paragraph in the buffer, blocks and tables stay as they are"
  (interactive)
  (save-excursion
    (dolist (pos (nreverse (org-element-map (org-element-parse-buffer) 'paragraph
                             (lambda (p) (org-element-contents-begin p)))))
      (goto-char pos)
      (org-fill-element))))

(with-eval-after-load 'erc
  (add-to-list 'erc-modules 'sasl)
  (setopt erc-nick "flaregun")
  (setopt erc-sasl-user :nick)
  (setopt erc-sasl-mechanism 'plain)
  (setopt erc-sasl-auth-source-function #'erc-auth-source-search)
  (setopt erc-hide-list '("JOIN" "PART" "QUIT")))

(defun rc/libera ()
  "connect to libera over tls with sasl"
  (interactive)
  (require 'erc)
  (erc-tls :server "irc.libera.chat"
           :port 6697
           :nick "flaregun"
           :user "flaregun"))

(setopt epg-pinentry-mode 'loopback)
(setopt epa-file-encrypt-to '("noah@nburch.org"))
