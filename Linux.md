# Linux

# Vim
* How to delete odd or even lines
  * delete odd lines:
`:g/^/d|m.`
  * delete even lines:
`:g/^/+d`
* How to add a word at the begin/end of every line
  * at the begin:
`:%s/^/[string]`
  * at the end:
`:%s/$/[string]`
