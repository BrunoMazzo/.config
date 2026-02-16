; extends

; Inject HTML into text nodes
((text) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined))
