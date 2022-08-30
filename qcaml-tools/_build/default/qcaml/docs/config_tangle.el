;; Thanks to Tobias's answer on Emacs Stack Exchange:
;; https://emacs.stackexchange.com/questions/38437/org-mode-batch-export-missing-syntax-highlighting

(package-initialize)
(add-to-list 'package-archives
             '("gnu" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(setq package-archive-priorities '(("melpa-stable" . 100)
                                   ("melpa" . 50)
                                   ("gnu" . 10)))
(require 'cl)
(let* ((required-packages
        '(dash
          htmlize
          ess
          evil
          gnuplot
          tuareg
        tramp
        bibtex-completion
        org-ref
        org-gnome
        org-evil
        org-bullets
        org-mime
        magit
        rustic
          auctex))

       (missing-packages (remove-if #'package-installed-p required-packages)))
  (when missing-packages
    (message "Missing packages: %s" missing-packages)
    (package-refresh-contents)
    (dolist (pkg missing-packages)
      (package-install pkg)
      (message "Package %s has been installed" pkg))))

(setq org-alphabetical-lists t)
(setq org-src-fontify-natively t)

(setq org-src-preserve-indentation t)
(setq org-confirm-babel-evaluate nil)

(org-babel-do-load-languages
 'org-babel-load-languages
 '(
   (emacs-lisp . t)
   (shell . t)
   (python . t)
   (C . t)
   (ocaml . t)
   (gnuplot . t)
   (latex . t)
   (ditaa . t)
   (dot . t)
   (org . t)
   (makefile . t)
   ))

(setq pwd (file-name-directory buffer-file-name))
(setq name (file-name-nondirectory (substring buffer-file-name 0 -4)))
(setq lib (concat pwd "lib/"))
(setq testdir (concat pwd "test/"))
(setq mli (concat lib name ".mli"))
(setq ml  (concat lib name ".ml"))
(setq c  (concat lib name ".c"))
(setq test-ml  (concat testdir name ".ml"))

