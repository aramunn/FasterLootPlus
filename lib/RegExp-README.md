-- luaregex.lua  ver.130911
--    A true, python-like regular expression for Lua
--
-- Usage:
--  local re = dofile("luaregex.lua")
--  local regex = re.compile("\\w+")
--  for match in regex:finditer("Hello, World!") do
--      print(match:group(0))
--  end
--
-- If you find bugs, report them to omawarisan.bokudesu _AT_ live.jp.
--
-- The author releases this script in the public domain,
-- but he would appreciate your mercy if you remove or change the e-mail address above
-- when you publish some modified version of this script.

--[[
or-exp:
    pair-exp
    or-exp "|" pair-exp

pair-exp:
    repeat-exp_opt
    pair-exp repeat-exp

repeat-exp:
    primary-exp
    repeat-exp repeater
    repeat-exp repeater "?"

primary-exp:
    "(?:" or-exp ")"
    "(?P<" identifier ">" or-exp ")"
    "(?P=" name ")"
    "(?=" or-exp ")"
    "(?!" or-exp ")"
    "(?<=" or-exp ")"
    "(?<!" or-exp ")"
    "(?(" name ")" pair-exp "|" pair-exp ")"
    "(?(" name ")" pair-exp ")"
    "(" or-exp ")"
    char-class
    non-terminal
    terminal-str

repeater:
    "*"
    "+"
    "?"
    "{" number_opt "," number_opt "}"
    "{" number "}"

char-class:
    "[^" user-char-class "]"
    "[" user-char-class "]"

user-char-class:
    user-char-range
    user-char-class user-char-range

user-char-range:
    user-char "-" user-char_opt
    user-char

user-char:
    class-escape-sequence
    CHARACTER OTHER THAN
        \, ]

class-escape-sequence:
    term-escape-sequence
    "\b"

terminal-str:
    terminal
    terminal-str terminal

terminal:
    term-escape-sequence
    CHARACTER OTHER THAN
        ^, $, \, |, [, ], {, }, (, ), *, +, ?

term-escape-sequence:
    "\a"
    "\f"
    "\n"
    "\r"
    "\t"
    "\v"
    "\\"
    "\" ascii-puncuation-char
    "\x" hex-number

non-terminal:
    "^"
    "$"
    "."
    "\d"
    "\D"
    "\s"
    "\S"
    "\w"
    "\W"
    "\A"
    "\b"
    "\B"
    "\Z"
    "\" number

name:
    identifier
    number

number:
    STRING THAT MATCHES REGEX /[0-9]+/

identifier:
    STRING THAT MATCHES REGEX /[A-Za-z_][A-Za-z_0-9]*/

ascii-puncuation-char:
    CHAR THAT MATCHES REGEX /[!-~]/ and also /[^A-Za-z0-9]/

hex-number:
    STRING THAT MATCHES REGEX /[0-9A-Fa-f]{1,2}/
]]
