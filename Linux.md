# Linux
* How to delete lines with specific words  
`sed -i '/specific_words/d' file_name`
* How to replace words in file  
`sed -i 's/old_words/new_words/g' file_name`
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
* How to select:  
  * all:  
  `ggVG`
  * all below:  
  `VG`
  * all above:  
  `Vgg`
* How to convert case of selected words:
  * to upper case:  
  `gU`
  * to lower case:  
  `gu`
* How to replace:  
`:%s/old_words/new_words/g`
