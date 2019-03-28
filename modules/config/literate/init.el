;;; config/literate/init.el -*- lexical-binding: t; -*-

(defvar +literate-config-file
  (expand-file-name "config.org" doom-private-dir)
  "The file path of your literate config file.")

(defvar +literate-config-cache-file
  (expand-file-name "literate-last-compile" doom-cache-dir)
  "The file path that `+literate-config-file' will be tangled to, then
byte-compiled from.")


;;
(defun +literate-tangle (&optional force-p)
  "Tangles `+literate-config-file' if it has changed."
  (let ((default-directory doom-private-dir)
        (org +literate-config-file))
    (when (or force-p (file-newer-than-file-p org +literate-config-cache-file))
      (message "Compiling your literate config...")

      ;; We tangle in a separate, blank process because loading it here would
      ;; load all of :lang org (very expensive!).
      (or (and (zerop (call-process
                       "emacs" nil nil nil
                       "-q" "--batch" "-l" "ob-tangle" "--eval"
                       (format "(org-babel-tangle-file %S nil \"emacs-lisp\")"
                               org)))
               ;; Write the cache file to serve as our mtime cache
               (with-temp-file +literate-config-cache-file t))
          (warn "There was a problem tangling your literate config!"))

      (message "Done!"))))

;; Let 'er rip!
(+literate-tangle doom-reloading-p)
;; No need to load the resulting file. Doom will do this for us after all
;; modules have finished loading.


;; Recompile our literate config if we modify it
(after! org
  (add-hook 'after-save-hook #'+literate|recompile-maybe))
