;;; -*- lexical-binding: t -*-

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(display-line-numbers-type 'relative)
 '(org-agenda-dim-blocked-tasks nil)
 '(org-agenda-exporter-settings '((org-agenda-tag-filter-preset (list "+personal"))))
 '(org-cliplink-transport-implementation 'url-el)
 '(org-enforce-todo-dependencies nil)
 '(org-modules
   '(ol-bbdb ol-bibtex ol-docview ol-gnus org-habit ol-info ol-irc ol-mhe
             ol-rmail ol-w3m))
 '(org-refile-use-outline-path 'file)
 '(package-selected-packages
   '(ag clojure-mode cmake-mode company d-mode dash dockerfile-mode elpy
        glsl-mode go-mode graphviz-dot-mode gruber-darker-theme
        haskell-mode helm helm-org ido-completing-read+ jinja2-mode
        kotlin-mode magit markdown-mode move-text multiple-cursors
        nginx-mode nim-mode nix-mode org-cliplink paredit php-mode
        powershell proof-general purescript-mode qml-mode racket-mode
        rfc-mode rust-mode scala-mode smex sml-mode tide toml-mode
        tuareg typescript-mode uxntal-mode yaml-mode yasnippet))
 '(safe-local-variable-values
   '((eval progn (auto-revert-mode 1) (rc/autopull-changes)
           (add-hook 'after-save-hook 'rc/autocommit-changes nil
                     'make-it-local))))
 '(warning-minimum-level :error)
 '(whitespace-style
   '(face tabs spaces trailing space-before-tab newline indentation empty
          space-after-tab space-mark tab-mark)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
