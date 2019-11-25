
;; NOTE: Some of the go modes and commands require external Go
;; programs; remember to `go get github.com/nsf/gocode` and
;; `go get github.com/kisielk/errcheck`

(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file)

(require 'site-gentoo nil t)

(require 'package)
(dolist (package-archive '(("melpa" . "http://melpa.milkbox.net/packages/")))
  (add-to-list 'package-archives package-archive t))
(package-initialize)

(defun package-ensure-installed (PACKAGE &optional MIN-VERSION)
  (unless (package-installed-p PACKAGE MIN-VERSION) (package-install PACKAGE)))

;; We install zenburn-theme last; if it isn't installed, it's possible
;; we don't have up-to-date package lists (which would cause EVERY
;; installation to fail), so we refresh them first.
(unless (package-installed-p 'zenburn-theme) (package-refresh-contents))

(dolist (pkg '(auctex
               auto-complete
               auto-complete-clang-async
               auto-indent-mode
               cmake-mode
               coffee-mode
               cperl-mode
               ;crontab-mode
               csharp-mode
               csv-mode
               enh-ruby-mode
               flycheck
               flycheck-color-mode-line
               gitconfig-mode
               gitignore-mode
               ;git-commit-mode
               git-gutter+
               go-mode
               go-autocomplete
               go-eldoc
               ;go-play
               haml-mode
               haste
               highlight-escape-sequences
               httpcode
               markdown-mode
               moe-theme
               init-loader
               lua-mode
               nginx-mode
               nsis-mode
               ;ntcmd
               page-break-lines
               pandoc-mode
               pcre2el
               projectile
               rainbow-delimiters
               rainbow-mode
               slime
               ;starter-kit
               ;tabkey2
               undo-tree
               web-mode
               ;xclip
               yaml-mode))
  (package-ensure-installed pkg))

(require 'moe-theme)
(require 'auto-indent-mode)

;(load-theme 'moe-dark t)
(moe-dark)

;; And now we finally install zenburn-theme
(package-ensure-installed 'zenburn-theme)

;; Monkey-patch for starter-kit: emacs' regexp engine isn't greedy
;; enough: FIX coming before the FIXME in the match makes only the
;; "FIX" portion match
(defun esk-add-watchwords ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIXME\\|TODO\\|FIX\\|HACK\\|REFACTOR\\|NOCOMMIT\\)"
          1 font-lock-warning-face t))))

(defun idle-highlight-mode ())

(dolist (prog-mode '(rainbow-delimiters-mode
                     auto-indent-mode))
  (add-hook 'prog-mode-hook prog-mode))

(setq auto-indent-assign-indent-level 4)

(defalias 'ruby-mode 'enh-ruby-mode)
(defalias 'perl-mode 'cperl-mode)
(dolist (auto-mode '(("\\(.sshd?_\\|.ssh/\\)config$" . conf-space-mode)
                     ("\\.\\([Pp][Llm]\\|al\\|xs\\)$" . cperl-mode)
                     ("\\.cs$" . csharp-mode)
                     ("\\.lua$" . lua-mode)
                     ("\\.\\(\\(p|dj\\)?html\\|tpl\\|php\\|[gj]sp\\|as[cp]x\\|erb\\|mustache\\)$" . web-mode)))
  (add-to-list 'auto-mode-alist auto-mode))

;(xclip-mode 1)
(global-undo-tree-mode)

(eval-after-load "flycheck"
    '(add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))

;; go-mode customization
(add-hook 'go-mode-hook 'go-eldoc-setup)
(add-hook 'before-save-hook #'gofmt-before-save) ; only runs in go-mode

(setq git-gutter+-separator-sign " ")
(setq git-gutter+-hide-gutter t)
(global-git-gutter+-mode t)

;; Recommended keybindings from https://github.com/nonsequitur/git-gutter-plus#get-started
;;; Jump between hunks
(global-set-key (kbd "C-x n") 'git-gutter+-next-hunk)
(global-set-key (kbd "C-x p") 'git-gutter+-previous-hunk)

;;; Act on hunks
(global-set-key (kbd "C-x v =") 'git-gutter+-popup-hunk) ; Show detailed diff
(global-set-key (kbd "C-x r") 'git-gutter+-revert-hunk)
;; Stage hunk at point.
;; If region is active, stage all hunk lines within the region.
(global-set-key (kbd "C-x t") 'git-gutter+-stage-hunks)
(global-set-key (kbd "C-x c") 'git-gutter+-commit) ; Commit with Magit
(global-set-key (kbd "C-x C") 'git-gutter+-stage-and-commit)

(global-set-key (kbd "C-x g") 'git-gutter+-mode) ; Turn on/off in the current buffer
(global-set-key (kbd "C-x G") 'global-git-gutter+-mode) ; Turn on/off globally

;;;;

(projectile-global-mode)
