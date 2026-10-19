; extends

; Tailwind at-rule preludes are keyword_query nodes, which the CSS highlights
; never capture. One utility after @apply is a single keyword_query.
(at_rule
  (at_keyword) @_rule
  (keyword_query) @function
  (#any-of? @_rule
    "@apply" "@utility" "@custom-variant" "@variant" "@plugin" "@source" "@reference" "@config"
    "@tailwind" "@screen"))

(at_rule
  (at_keyword) @_rule
  (keyword_query) @keyword.modifier
  (#any-of? @_rule "@theme" "@layer"))

; `initial`, `solid`, and other property values have no capture, so a @theme
; block reads as plain text. Custom properties stay variables. The pattern
; is a character class because a bare "-" is a quantifier in a Lua pattern.
(plain_value) @string

((plain_value) @variable
  (#lua-match? @variable "^[-][-]"))

; After the plain-value captures, so a utility list stays a function call
; rather than a string of values.
(postcss_statement
  (at_keyword) @_apply
  (plain_value) @function
  (#eq? @_apply "@apply"))

; The hash of a hex color is punctuation in the base query, so only the digits
; take the string color.
(color_value
  "#" @string)
