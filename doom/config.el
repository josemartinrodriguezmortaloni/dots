;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "José Rodriguez"
      user-mail-address "jmrodriguezm13@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
(setq doom-font (font-spec :family "iAWriterQuattroV" :size 16)
      doom-variable-pitch-font (font-spec :family "iAWriterQuattroV" :size 18)
      doom-big-font (font-spec :family "iAWriterQuattroV" :size 22)
      doom-symbol-font (font-spec :family "GeistMono Nerd Font" :size 16))

(defun my/setup-nerd-font-fallback ()
  "Map Nerd Font PUA ranges to GeistMono Nerd Font."
  (let ((nerd-font (font-spec :family "GeistMono Nerd Font")))
    (set-fontset-font t '(#xe000 . #xf8ff) nerd-font)
    (set-fontset-font t '(#xf0001 . #xf1af0) nerd-font)
    (set-fontset-font t '(#xea60 . #xebe9) nerd-font)
    (set-fontset-font t '(#xe0a0 . #xe0d4) nerd-font)))

(add-hook 'after-setting-font-hook #'my/setup-nerd-font-fallback)

;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-gruvbox-light)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; ORG
;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "/home/m4s1t4/Documents/Notes/OrgNotes/")
(setq org-roam-directory (file-truename "/home/m4s1t4/Documents/Notes/OrgNotes/roam/"))
(setq org-modern-table-vertical 1)
(setq org-modern-table t)
(add-hook 'org-mode-hook #'hl-todo-mode)
(add-hook 'org-mode-hook #'org-indent-mode)
(after! diminish
  (diminish 'org-indent-mode))
(setq org-roam-file-extensions '("org"))
(setq org-roam-node-display-template
      (concat "${type:15} ${title:*} " (propertize "${tags:10}" 'face 'org-tag)))

;; ============================================================================
;; FACULTAD CAPTURE — Helpers para template interactivo
;; ============================================================================

(defvar my/fac-año nil "Año de cursado seleccionado durante capture.")
(defvar my/fac-materia nil "Materia seleccionada durante capture.")
(defvar my/fac-tipo nil "Tipo (teoría/práctica) seleccionado durante capture.")
(defvar my/fac-unidad nil "Unidad/TP seleccionado durante capture.")

(defun my/fac-slugify (str)
  "Convierte STR a slug: minúsculas, espacios→guiones."
  (downcase (string-replace " " "-" str)))

(defun my/fac-list-subdirs (dir)
  "Lista subcarpetas directas de DIR, excluyendo dotfiles."
  (when (file-directory-p dir)
    (cl-remove-if
     (lambda (f) (string-prefix-p "." f))
     (directory-files dir nil directory-files-no-dot-files-regexp))))

(defun my/fac-capture-dir ()
  "Promptea año, materia, tipo y unidad. Retorna el directorio relativo (con / final)."
  (setq my/fac-año (completing-read "Año: " '("primero" "segundo" "tercero" "cuarto") nil t))
  (let* ((materias-dir (expand-file-name (concat "facultad/" my/fac-año) org-roam-directory)))
    (setq my/fac-materia (completing-read "Materia: " (my/fac-list-subdirs materias-dir))))
  (setq my/fac-tipo (completing-read "Tipo: " '("teoría" "práctica") nil t))
  (let* ((tipo-dir (expand-file-name
                    (format "facultad/%s/%s/%s"
                            my/fac-año (my/fac-slugify my/fac-materia) my/fac-tipo)
                    org-roam-directory))
         (existing (my/fac-list-subdirs tipo-dir))
         (prompt (if (string= my/fac-tipo "teoría") "Unidad: " "TP: ")))
    (setq my/fac-unidad (completing-read prompt (or existing '()) nil nil)))
  (format "facultad/%s/%s/%s/%s/"
          my/fac-año
          (my/fac-slugify my/fac-materia)
          my/fac-tipo
          my/fac-unidad))

(defun my/fac-tags ()
  "Retorna el string de filetags para la captura de facultad actual."
  (format ":facultad:%s:%s:%s:"
          (my/fac-slugify my/fac-materia)
          my/fac-tipo
          (my/fac-slugify my/fac-unidad)))

(setq org-roam-capture-templates
      `(;; General
        ("d" "default" plain "%?"
         :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+title: ${title}\n#+filetags: \n")
         :unnarrowed t)
        ("m" "main" plain "%?"
         :if-new (file+head "main/${slug}.org"
                            "#+title: ${title}\n")
         :immediate-finish t
         :unnarrowed t)

        ;; Facultad — promptea año, materia, tipo y unidad interactivamente
        ("f" "facultad" plain
         "* Contenido\n%?\n\n* Preguntas\n- [ ] \n\n* Conexiones\n"
         :if-new (file+head
                  "%(my/fac-capture-dir)${slug}.org"
                  "#+title: ${title}\n#+filetags: %(my/fac-tags)\n#+date: %U\n")
         :unnarrowed t)

        ;; Lectura — Notas de capítulo
        ("l" "lectura - capítulo" plain
         "* Resumen\n%?\n\n* Datos Importantes\n- \n\n* Citas Textuales\n#+begin_quote\n\n#+end_quote\n\n* Preguntas Abiertas\n- [ ] \n\n* Insights Personales\n- \n\n* Patrones Identificados\n- "
         :if-new (file+head "lectura/${slug}.org"
                            "#+title: ${title}\n#+filetags: :lectura:capitulo:\n#+date: %U\n")
         :unnarrowed t)

        ;; Patrón
        ("p" "patrón" plain
         "* Definición\n%?\n\n* Cuándo Aplica\n\n\n* Ejemplos\n- Dominio 1: \n- Dominio 2: \n\n* Contraejemplos\n\n\n* Insights\n\n\n* Conexiones\n- \n\n* Fuente\n- Libro: \n- Página: "
         :if-new (file+head "patrones/${slug}.org"
                            "#+title: ${title}\n#+filetags: :patron:\n#+date: %U\n")
         :unnarrowed t)

        ;; Proyecto
        ("P" "proyecto" plain
         "* Descripción\n%?\n\n* Objetivos\n- [ ] \n\n* Tareas\n** TODO \n\n* Notas\n"
         :if-new (file+head "proyectos/${slug}.org"
                            "#+title: ${title}\n#+filetags: :proyecto:\n#+date: %U\n")
         :unnarrowed t)

        ;; Blog
        ("b" "blog" plain
         "* Borrador\n%?\n\n* Referencias\n"
         :if-new (file+head "blog/${slug}.org"
                            "#+title: ${title}\n#+filetags: :blog:\n#+date: %U\n")
         :unnarrowed t)

        ;; Referencia
        ("r" "reference" plain "%?"
         :if-new (file+head "reference/${title}.org"
                            "#+title: ${title}\n#+filetags: :reference:\n")
         :immediate-finish t
         :unnarrowed t)

        ;; Artículos
        ("a" "article" plain "%?"
         :if-new (file+head "articles/${title}.org"
                            "#+title: ${title}\n#+filetags: :article:\n")
         :immediate-finish t
         :unnarrowed t)
        ))

(use-package! org-roam
  :custom
  (org-roam-directory (file-truename "/home/m4s1t4/Documents/Notes/OrgNotes/roam/"))
  :config
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  (require 'org-roam-protocol))

(use-package! org-roam-ui
  :after org-roam
  :hook (org-roam-mode . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

;; KEYMAPS
(map! :leader
      :desc "Comment Line" "-" #'comment-line)

(map! :leader
      (:prefix ("t" . "toggle")
       :desc "Toggle eshell split"            "e" #'eshell
       :desc "Toggle line highlight in frame" "h" #'hl-line-mode
       :desc "Toggle line highlight globally" "H" #'global-hl-line-mode
       :desc "Toggle line numbers"            "l" #'doom/toggle-line-numbers
       :desc "Toggle markdown-view-mode"      "m" #'dt/toggle-markdown-view-mode
       :desc "Toggle truncate lines"          "t" #'toggle-truncate-lines
       :desc "Toggle treemacs"                "T" #'treemacs))

(map! :leader
      (:prefix ("o" . "open")
       :desc "Open eshell here"    "e" #'eshell
       :desc "Journal"             "j" (lambda () (interactive)
                                         (find-file (concat org-directory "journal.org")))
       :desc "Notes"               "n" (lambda () (interactive)
                                         (find-file (concat org-directory "notes.org")))
       :desc "Tasks"               "t" (lambda () (interactive)
                                         (find-file (concat org-directory "tasks.org")))))

;; Org leader bindings
(map! :leader
      (:prefix ("m" . "org/local")
       :desc "Org agenda"        "a" #'org-agenda
       :desc "Org capture"       "c" #'org-capture
       :desc "Org export"        "e" #'org-export-dispatch
       :desc "Org toggle item"   "i" #'org-toggle-item
       :desc "Org babel tangle"  "B" #'org-babel-tangle
       :desc "Org todo"          "T" #'org-todo
       :desc "Org time stamp"    "d" #'org-time-stamp))

;; Search bindings
(map! :leader
      (:prefix ("s" . "search")
       :desc "Dictionary search"  "d" #'dictionary-search
       :desc "TLDR docs"          "T" #'tldr
       :desc "PDF occur"          "o" #'pdf-occur))

;; Org-roam shortcuts — SPC n directo (sin pasar por r)
(map! :leader
      (:prefix ("n" . "notes")
       :desc "Find node"          "f" #'org-roam-node-find
       :desc "Insert link"        "i" #'org-roam-node-insert
       :desc "Capture"            "c" #'org-roam-capture
       :desc "Dailies today"      "j" #'org-roam-dailies-capture-today
       :desc "Toggle roam buffer" "l" #'org-roam-buffer-toggle
       :desc "Roam graph"         "g" #'org-roam-graph
       :desc "Roam UI"            "u" #'org-roam-ui-open))

;; Quick config access
(map! :leader
      (:prefix ("f" . "file")
       :desc "Open doom config"   "c" (lambda () (interactive)
                                        (find-file (concat doom-user-dir "config.el")))
       :desc "Open doom dir"      "C" (lambda () (interactive)
                                        (dired doom-user-dir))))



;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
(setq confirm-kill-emacs nil)
(setq ispell-dictionary "es_AR")

;; ============================================================================
;; TEXT SCALING — Zoom global con C-= / C-- y mouse wheel
;; ============================================================================

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

;; ============================================================================
;; ORG-MODE: Agenda, Habit, y configuración general
;; ============================================================================

(after! org
  ;; Archivos que alimentan la agenda
  (setq org-agenda-files (list org-directory
                               org-roam-directory))

  ;; TODO keywords
  (setq org-todo-keywords
        '((sequence "TODO(t)" "IN-PROGRESS(i)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))

  ;; org-habit — tracking de hábitos recurrentes
  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60
        org-habit-show-all-today t)

  ;; org-tempo — < s TAB expande a #+begin_src, etc.
  (require 'org-tempo)

  ;; Preservar indentación al tanglear con org-babel
  (setq org-src-preserve-indentation t))

;; ============================================================================
;; ORG-SUPER-AGENDA — Agenda agrupada por categorías
;; ============================================================================

(use-package! org-super-agenda
  :after org-agenda
  :config
  (org-super-agenda-mode)
  (setq org-super-agenda-groups
        '((:name "Hoy"
           :time-grid t
           :deadline today
           :scheduled today)
          (:name "Vencido"
           :deadline past
           :scheduled past)
          (:name "Facultad"
           :tag "facultad")
          (:name "Proyectos"
           :tag "proyecto")
          (:name "Lectura"
           :tag ("lectura" "article"))
          (:name "Hábitos"
           :habit t)
          (:name "Prioridad Alta"
           :priority "A")
          (:name "Pendientes"
           :todo "TODO")
          (:name "En Progreso"
           :todo "IN-PROGRESS")
          (:name "Esperando"
           :todo "WAITING"))))

;; ============================================================================
;; VULPEA — Metadata mejorada para org-roam
;; ============================================================================

(use-package! vulpea
  :after org-roam
  :config
  (vulpea-db-autosync-mode 1))

;; ============================================================================
;; ORG-NOTER — Anotaciones sobre PDFs
;; ============================================================================

(use-package! org-noter
  :after (:any org pdf-view)
  :config
  (setq org-noter-notes-search-path (list org-roam-directory)
        org-noter-auto-save-last-location t
        org-noter-separate-notes-from-heading t))

;; ============================================================================
;; PDF-TOOLS — Evil keybindings + display limpio
;; ============================================================================

(after! pdf-tools
  (add-hook 'pdf-view-mode-hook
            (lambda ()
              (display-line-numbers-mode -1)
              (blink-cursor-mode -1)))
  (map! :map pdf-view-mode-map
        :n "j" #'pdf-view-next-line-or-next-page
        :n "k" #'pdf-view-previous-line-or-previous-page
        :n "C-=" #'pdf-view-enlarge
        :n "C--" #'pdf-view-shrink))

;; ============================================================================
;; ORG-POMODORO — Timer Pomodoro + time tracking
;; ============================================================================

(use-package! org-pomodoro
  :after org
  :config
  (setq org-pomodoro-length 25
        org-pomodoro-short-break-length 5
        org-pomodoro-long-break-length 15
        org-pomodoro-long-break-frequency 4))

(map! :leader
      :desc "Pomodoro" "m p" #'org-pomodoro)

;; ============================================================================
;; ORG-DOWNLOAD — Drag & drop de imágenes
;; ============================================================================

(use-package! org-download
  :after org
  :config
  (setq org-download-method 'directory
        org-download-image-dir (concat org-directory "images/")
        org-download-heading-lvl nil
        org-download-timestamp "%Y%m%d-"))

;; ============================================================================
;; ORG-GCAL — Sincronización con Google Calendar
;; ============================================================================
;; Para configurar:
;; 1. Crear un proyecto en https://console.cloud.google.com/
;; 2. Habilitar Google Calendar API
;; 3. Crear credenciales OAuth 2.0
;; 4. Completar client-id y client-secret en ~/.config/doom/secrets.el
(load! "secrets" doom-user-dir t) ; carga secrets.el si existe (no falla si no está)
(use-package! org-gcal
  :after org)
;; Run ‘org-gcal-sync’ regularly not at startup, but at 8 AM every day,
;; starting the next time 8 AM arrives.
(run-at-time
 (let* ((now-decoded (decode-time))
        (today-8am-decoded
         (append '(0 0 8) (nthcdr 3 now-decoded)))
        (now (encode-time now-decoded))
        (today-8am (encode-time today-8am-decoded)))
   (if (time-less-p now today-8am)
       today-8am
     (time-add today-8am (* 24 60 60))))
 (* 24 60 60)
 (defun my-org-gcal-sync-clear-token ()
   "Sync calendar, clearing tokens first."
   (interactive)
   (require 'org-gcal)
   (when org-gcal--sync-lock
     (warn "%s" "‘my-org-gcal-sync-clear-token’: ‘org-gcal--sync-lock’ not nil - calling ‘org-gcal--sync-unlock’.")
     (org-gcal--sync-unlock))
   (org-gcal-sync-tokens-clear)
   (org-gcal-sync)
   nil))
;; ============================================================================
;; GIT-AUTO-COMMIT-MODE — Auto-commit al guardar notas
;; ============================================================================

(use-package! git-auto-commit-mode
  :config
  (setq gac-automatically-push-p nil          ; no push automático
        gac-automatically-add-new-files-p t))  ; sí agregar archivos nuevos

;; Activar solo en el directorio de notas
(add-hook 'org-mode-hook
          (lambda ()
            (when (and buffer-file-name
                       (string-prefix-p (expand-file-name org-directory)
                                        (expand-file-name buffer-file-name)))
              (git-auto-commit-mode 1))))
(use-package! org-modern
  :hook (org-mode . org-modern-mode)
  :config
  (setq org-modern-star '("◉" "○" "✸" "✿" "✿")))

;; ============================================================================
;; TOC-ORG — Table of Contents automática en archivos Org
;; ============================================================================

(use-package! toc-org
  :hook (org-mode . toc-org-enable))

;; MARKDOWN
(custom-set-faces
 '(markdown-header-face ((t (:inherit font-lock-function-name-face :weight bold :family "variable-pitch"))))
 '(markdown-header-face-1 ((t (:inherit markdown-header-face :height 1.6))))
 '(markdown-header-face-2 ((t (:inherit markdown-header-face :height 1.5))))
 '(markdown-header-face-3 ((t (:inherit markdown-header-face :height 1.4))))
 '(markdown-header-face-4 ((t (:inherit markdown-header-face :height 1.3))))
 '(markdown-header-face-5 ((t (:inherit markdown-header-face :height 1.2))))
 '(markdown-header-face-6 ((t (:inherit markdown-header-face :height 1.1)))))

;; Toggle Markdown View
(defun dt/toggle-markdown-view-mode ()
  "Toggle between `markdown-mode' and `markdown-view-mode'."
  (interactive)
  (if (eq major-mode 'markdown-view-mode)
      (markdown-mode)
    (markdown-view-mode)))
