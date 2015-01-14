require! <[fs]>

finals = fs.readdir-sync \./stock
dir = "./stock"
count = 0
tp = 0
tn = 0
fp = 0
fn = 0
[accuracy, precision, sensitivity] = [0 0 0]

for let name in finals
  count++
  correct = 0
  total = 0
  if fs.read-file-sync("#dir/#name/predict_result") is /\[DV .\]\n([\S\s]+)/
    final = that[1] / "\n"
    for line in final
      continue if line.length is 0
      tp++ if line[0] is line[2] and line[0] is \1
      tn++ if line[0] is line[2] and line[0] is \0
      fp++ if line[0] is \0 and line[2] is \1
      fn++ if line[0] is \1 and line[2] is \0
    accuracy += Math.round(100*((tp + tn)/(tp+tn+fp+fn)))
    precision += Math.round(100*(tp/(tp + fp)))
    sensitivity += Math.round(100*(tp/(tp + fn)))

    console.log "#name:"
    console.log "accuracy: #{Math.round(100*((tp + tn)/(tp+tn+fp+fn)))}%"
    console.log "precision: #{Math.round(100*(tp/(tp + fp)))}%"
    console.log "sensitivity: #{Math.round(100*(tp/(tp + fn)))}%"
    console.log "f1-score: #{Math.round(100*(2*tp/(2*tp+fp+fn)))}%"
    console.log "negative-precision: #{Math.round(100*(tn/(tn+fn)))}%"
    console.log "-------------------------------------------------------"
  else
    console.log name
console.log count
console.log \---average---
console.log "accuracy: #{Math.round((accuracy/count))}%"
console.log "precision: #{Math.round((precision/count))}%"
console.log "sensitivity: #{Math.round((sensitivity/count))}%"
console.log "-------------------------------------------------------"

# vi:et:sw=2:ts=2
