require! <[fs async line-reader moment]>

stock-dir = \/home/mlb/stock/
stock = <[2615 2612 2603 2605 6702 2609 5608 2617 2613 2637 2606 2208 2607 2611 5607]>

orig-data = []
wti = filter-date (get-index \wti), \2010-01-01, \2015-12-31
bdi = filter-date (get-index \bdi), \2010-01-01, \2015-12-31

#console.log (combine bdi, wti, \wti)
#console.log(get-index \bdi)

function get-stock
  for let number in stock
    one-data = []
    lineReader.each-line stock-dir+number, !->
      # console.log line
      if /(.+?),(.+?),(.+?),(.+?),(.+?),(.+?),(.+)/ is it
        return if isNaN parseFloat that.2
        one-data.push {date: moment(that.1), open: parseFloat(that.2), high: parseFloat(that.3), low: parseFloat(that.4), close: parseFloat(that.5), volume: parseInt(that.6), adj: parseFloat(that.7)}
    .then ->
  #   parse-data one-data

function combine a, b, name
  [c, d] = if a.length > b.length then [a, b] else [b, a]
  n = 0
  tmp = d[n]
  for i from 0 til c.length
    if c[i].date.is-same d[n].date or c[i].date.is-after d[n].date then c[i]."#name" = d[n].index
    else
      if n < d.length-1 then c[i]."#name" = d[++n].index else break
  c

a = [1,2,3]
b = [1,4,3]

c = [a, b]
console.log(ml-format c)

function ml-format
  buf = ''
  count = 1
  for i from 0 til it.0.length
    count = 1
    buf += \0
    for feature in it then buf += "\t#{count++}:#{feature[i]}"
    buf += \\n
  buf

function get-index
  arr = []
  data = (fs.read-file-sync it, \utf8) / \\n
  for line in data
    word = line / \,
    if moment(word.0).is-valid! then arr.push {date: moment(word.0), index: parseFloat(word.1)}
  arr

function filter-date target, begin, end
  arr = []
  for day in target
    if day.date.is-between begin, end then arr.push day
  arr

function parse-data
  for i in it
    for key, value of i
      #return if not isNaN value
      console.log key, value

    #for key, value of i
    #  return if not isNaN value
    #  console.log value

#high, low, close, volume
function A_D then ((it[\close] - it[\low]) - (it[\high] - it[\close])) / (it[\high] - it[\low]) * it[\volume]

# vi:et:sw=2:ts=2
