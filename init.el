;; <leaf-install-code>
(eval-and-compile
  (customize-set-variable
   'package-archives '(("org" . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu" . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    ;;(leaf hydra :ensure t)
    ;;(leaf el-get :ensure t)
    ;;(leaf blackout :ensure t)

    
    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))
;; </leaf-install-code>

;; Now you can use leaf!
(leaf leaf-tree :ensure t)
(leaf leaf-convert :ensure t)
(leaf transient-dwim
  :ensure t
  :bind (("M-=" . transient-dwim-dispatch)))

;; You can also configure builtin package via leaf!
(leaf cus-start
  :doc "define customization properties of builtins"
  :tag "builtin" "internal"
  :custom ((truncate-lines . t)
           (menu-bar-mode . nil)
           (tool-bar-mode . nil)
           (scroll-bar-mode . nil)
           (indent-tabs-mode . nil)
           ))
(global-set-key (kbd "C-c t") 'display-line-numbers-mode)
;; emacs の起動画面を消す
;; https://pcvogel.sarakura.net/2013/06/17/31151
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
;;カーソルの点滅を消す
(blink-cursor-mode 0)
;;括弧の自動補完
(electric-pair-mode 1)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'org-mode-hook 'display-line-numbers-mode)
(leaf org-journal
  :ensure t
  :config
  (setq work-directory "~/デスクトップ/org/")
(setq memofile (concat work-directory "memo.org"))
(setq todofile (concat work-directory "TODO.org"))
(setq org-agenda-files `(,todofile ))
(setq org-capture-templates
      '(
	    ("m" "メモ" entry (file+headline memofile "memo")
         "** %?\n*** 参考\n\nEntered on %U\n %i\n %a\n")

	    ("p" "プログラミングノート" entry (file+headline  memofile "Programming note")
	     "** %? \n\n*** カテゴリ\n\n*** 内容\n\n\nEntered on %U\n %i\n %a\n")

	    ("c" "チェックボックス" checkitem (file+headline   todofile "checkbox")
	     "[ ] %? %U\n")
	    ("t" "TODO" entry (file+headline todofile "ToDo")
         "*** TODO [/] %?\n- [ ] \nCAPTURED_AT: %U\n %i\n")

	    ("r" "調査内容" entry (file+headline memofile "Reserch")
	     "** %?\nEntered on %U\n %i\n %a\n")

	    ("S" "学習内容" entry (file+headline memofile "Study")
	     "** %?\nEntered on %U\n %i\n %a\n")

	    ("w" "単語帳" item (file+headline memofile "words")
	     "- %?\nEntered on %U\n %i\n %a\n")

	    ("W" "単語帳（複数語）" entry (file+headline memofile "words")
	     "** %?\n - \nEntered on %U\n %i\n %a\n")


        ("l" "記録" entry (file+headline memofile "Log")
         "** %?\nEntered on %U\n %i\n %a\n")

        ("s" "文章" entry (file+headline memofile "文章")
         "** %?\nEntered on %U\n %i\n %a\n")

	    ("i" "アイデア" entry (file+headline memofile "アイデア")
         "* %?\nEntered on %U\n %i\n %a\n")


	    ("b" "経済" entry (file+headline memofile "Business")
         "** %?\nEntered on %U\n %i\n %a\n")

        ("P" "Project" entry (file+headline memofile "Project")
         "** %?\nEntered on %U\n %i\n")
        )
      ))

  ;; ここに org-journal の設定を追加

(leaf my-custom-config
  :config
  (global-set-key (kbd "C-c C-j") 'org-journal-new-entry))


(global-set-key (kbd "C-c C-j") 'org-journal-new-entry)


;; org-capture
;; キーバインドの設定
(global-set-key (kbd "C-c c") 'org-capture)

(leaf autorevert
  :doc "revert buffers when files on disk change"
  :tag "builtin"
  :custom ((auto-revert-interval . 0.1))
  :global-minor-mode global-auto-revert-mode)


;; scratch buffer をorg-modeで作成するmy-scratch-buffer
;; https://emacs.stackexchange.com/questions/16492/is-it-possible-to-create-an-org-mode-scratch-buffer
;; lawlistさん作
(defun my-scratch-buffer ()
  "Create a new scratch buffer -- \*hello-world\*"
  (interactive)
  (let ((n 0)
        bufname buffer)
    (catch 'done
      (while t
        (setq bufname (concat "*my-scratch-org-mode"
                              (if (= n 0) "" (int-to-string n))
                              "*"))
        (setq n (1+ n))
        (when (not (get-buffer bufname))
          (setq buffer (get-buffer-create bufname))
          (with-current-buffer buffer
            (org-mode))
          ;; When called non-interactively, the `t` targets the other window (if it exists).
          (throw 'done (display-buffer buffer t))) ))))
;; 警告音もフラッシュも全て無効(警告音が完全に鳴らなくなるので注意)
(setq ring-bell-function 'ignore)
;; Nest package configurations
(leaf flycheck
  :doc "On-the-fly syntax checking"
  :emacs>= 24.3
  :ensure t
  :bind (("M-n" . flycheck-next-error)
         ("M-p" . flycheck-previous-error))
  :custom ((flycheck-emacs-lisp-initialize-packages . t))
  :hook (emacs-lisp-mode-hook lisp-interaction-mode-hook)
  :config
  (leaf flycheck-package
    :doc "A Flycheck checker for elisp package authors"
    :ensure t
    :config
    (flycheck-package-setup))

  (leaf flycheck-elsa
    :doc "Flycheck for Elsa."
    :emacs>= 25
    :ensure t
    :config
    (flycheck-elsa-setup))

  ;; ...
  )
(leaf ivy
  :doc "Incremental Vertical completYon"
  :req "emacs-24.5"
  :tag "matching" "emacs>=24.5"
  :url "https://github.com/abo-abo/swiper"
  :emacs>= 24.5
  :ensure t
  :blackout t
  :leaf-defer nil
  :custom ((ivy-initial-inputs-alist . nil)
           (ivy-use-selectable-prompt . t))
  :global-minor-mode t
  :config
  (leaf swiper
    :doc "Isearch with an overview. Oh, man!"
    :req "emacs-24.5" "ivy-0.13.0"
    :tag "matching" "emacs>=24.5"
    :url "https://github.com/abo-abo/swiper"
    :emacs>= 24.5
    :ensure t
    :bind (("C-s" . swiper)))

  (leaf counsel
    :doc "Various completion functions using Ivy"
    :req "emacs-24.5" "swiper-0.13.0"
    :tag "tools" "matching" "convenience" "emacs>=24.5"
    :url "https://github.com/abo-abo/swiper"
    :emacs>= 24.5
    :ensure t
    :blackout t
    :bind (("C-S-s" . counsel-imenu)
           ("C-x C-r" . counsel-recentf))
    :custom `((counsel-yank-pop-separator . "\n----------\n")
              (counsel-find-file-ignore-regexp . ,(rx-to-string '(or "./" "../") 'no-group)))
    :global-minor-mode t))

(leaf prescient
  :doc "Better sorting and filtering"
  :req "emacs-25.1"
  :tag "extensions" "emacs>=25.1"
  :url "https://github.com/raxod502/prescient.el"
  :emacs>= 25.1
  :ensure t
  :custom ((prescient-aggressive-file-save . t))
  :global-minor-mode prescient-persist-mode)
  
(leaf ivy-prescient
  :doc "prescient.el + Ivy"
  :req "emacs-25.1" "prescient-4.0" "ivy-0.11.0"
  :tag "extensions" "emacs>=25.1"
  :url "https://github.com/raxod502/prescient.el"
  :emacs>= 25.1
  :ensure t
  :after prescient ivy
  :custom ((ivy-prescient-retain-classic-highlighting . t))
  :global-minor-mode t)


;; ...
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(deeper-blue))
 '(package-selected-packages
   '(flycheck-elsa flycheck-package flycheck transient-dwim leaf-convert leaf-tree blackout el-get hydra leaf-keywords leaf)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
