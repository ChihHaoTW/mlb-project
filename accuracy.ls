require! <[fs]>

finals = fs.readdir-sync \./stock
dir = "./stock"

for let name in finals
  correct = 0
  total = 0
  if fs.read-file-sync("#dir/#name/predict_result") is /\[DV .\]\n([\S\s]+)/
    final = that[1] / "\n"
    for line in final
      continue if line.length is 0
      correct++ if line[0] is line[2]
      total++
    console.log "#name: #{correct/total}"
  else
    console.log name

# vi:et:sw=2:ts=2
