; extends

; Inject JavaScript in script tags
((script_element
  (start_tag)
  (raw_text) @injection.content)
  (#set! injection.language "javascript"))

; Inject CSS in style tags  
((style_element
  (start_tag)
  (raw_text) @injection.content)
  (#set! injection.language "css"))
