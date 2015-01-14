require! <[fs async line-reader moment execSync]>


stock-dir = \/home/mlb/stock/
stock = <[2615 2612 2603 2605 6702 2609 5608 2617 2613 2637 2606 2208 2607 2611 5607]>
all-stock = fs.readdir-sync \/home/mlb/stock/

[min, max] = [\2014-02-01, \2015-01-01]
wti = filter-date (get-index \wti), min, max
bdi = filter-date (get-index \bdi), min, max
ship = JSON.parse(fs.read-file-sync \shipping, \utf8)
ship = for x in ship then {date: moment(x.date), index: x.index}
ship = filter-date ship, min, max

#wti = stretch wti, bdi
#for i from 0 til wti.length then console.log wti[i].date.format!, bdi[i].date.format!

#console.log (combine bdi, wti, \wti)
#console.log(get-index \bdi)

get-stock!

function get-stock
  for let number in stock
    mkdir "./stock/#number/"
    one-data = []
    lineReader.each-line stock-dir + number, !->
      # console.log line
      if /(.+?),(.+?),(.+?),(.+?),(.+?),(.+?),(.+)/ is it
        return if isNaN parseFloat that.2
        one-data.push {
          date: moment(that.1),
          open: parseFloat(that.2),
          high: parseFloat(that.3),
          low: parseFloat(that.4),
          close: parseFloat(that.5),
          volume: parseInt(that.6),
          adj: parseFloat(that.7)
        }
    .then ->
      data = filter-date one-data, min, max
#     bdi = stretch bdi, data
#     wti = stretch wti, bdi
#     for i from 0 til wti.length then console.log "#{data[i].date.format!}, #{wti[i].date.format!}, #{bdi[i].date.format!}"
#     return
      change = close-diff data
      features = trim(get-features data)
      raw-data = ml-format features, change
#     console.log(get-data(raw-data, \train, [0.25, 1]))
      fs.write-file-sync "stock/#number/predict_data", get-data(raw-data, \predict, [0, 0.25])
      fs.write-file-sync "stock/#number/train_data", get-data(raw-data, \train, [0.25, 0.9])
      #parse-data one-data

trim = ->
  min-length = it.0.length
  for feature in it then min-length = min-length <? feature.length
  for feature in it then feature.slice 0, min-length

get-features = ->
  b = for x in (stretch bdi, it) then x.index
  w = for x in (stretch wti, it) then x.index
  s = for x in it
        for y in ship
          if y.date.is-same x.date
            if y.index > 0 then y.index
            else 0
  for x in s
    if x is 0 then console.log \hi
  console.log s
  [
    b,
    w,
    (season it),
    (percent-K it),
    (percent-R it),
    (percent-D it),
    (for x in it then A_D x),
#   (slow-precent-D it),
    (ROC it, 14),
    (momentum it),
    (disparity it, 5),
    (disparity it, 10),
    (OSCP it)
  ]

function get-data data, type, range
  buf = ''
  lines = data / \\n
  length = lines.length
  for i from parse-int(length * range.0) til parse-int(length * range.1) then buf += "#{lines[i]}\n"
  # if type is \predict
  #   for i from parse-int(length * range.0) til parse-int(length * range.1) then buf += "#{lines[i]}\n"
  #     if /(\d?)\t(.+)/ is lines[i] then buf += "0\t#{that.2}\n"
  # else
  #   for i from parse-int(length * range.0) til parse-int(length * range.1) then buf += "#{lines[i]}\n"
  buf


function combine a, b, name
  [c, d] = if a.length > b.length then [a, b] else [b, a]
  n = 0
  tmp = d[n]
  for i from 0 til c.length
    if c[i].date.is-same d[n].date or c[i].date.is-after d[n].date then c[i]."#name" = d[n].index
    else
      if n < d.length-1 then c[i]."#name" = d[++n].index else arr.push d[n].index
  c

#console.log bdi.length
#console.log(stretch wti, bdi .length)

function stretch a, b
  [c, d] = if a.length > b.length then [a, b] else [b, a]
  n = 0
  _ = []
# for i from 0 til c.length
#   if c[i].date.is-after d[n].date
#     _.push {date: d[n].date, index: d[n].index}
#   else
#     _.push {date: d[n+1].date, index: d[n+1].index}
  for i from 0 til c.length
    if c[i].date.is-after d[n].date then _.push {date: d[n].date, index: d[n].index}
    else
      if n < d.length-1
        n++
        _.push {date: d[n].date, index: d[n].index}
      else _.push {date: d[n].date, index: d[n].index}
  _

#a = [1,2,3]
#b = [1,4,3]

#d = close-diff [{close: 1}, {close: 4}, {close: 3}]
#c = [a, b]
#console.log(ml-format c, d)


function close-diff
  _ = []
  for i from 0 til it.length
    unless it[i - 1] then _.push 0
    else
      if (it[i - 1].close - it[i].close) > 0 then _.push 1 else _.push 0
  _

function ml-format features, diff
  buf = ''
  count = 1
  for i from 0 til features.0.length
    count = 1
    buf += diff[i]
    for feature in features then buf += "\t#{count++}:#{feature[i]}"
    buf += \\n
  buf

#test = [{date: moment \2012-03-21}, {date: moment \2012-06-01}]
#console.log(season test)

function season
  _ = []
  for day in it then _.push switch day.date.month! + 1
                            | 3, 4, 5 => 1
                            | 6, 7, 8 => 2
                            | 9, 10, 11 => 3
                            | 12, 1, 2 => 4
  _


function get-index
  _ = []
  data = (fs.read-file-sync it, \utf8) / \\n
  for line in data
    word = line / \,
    if moment(word.0).is-valid! then _.push {date: moment(word.0), index: parseFloat(word.1)}
  _

function filter-date target, begin, end
  for day in target
    if day.date.is-between begin, end then day

function parse-data
 console.log percent-K it
  # for i in it
  #   for key, value of i
  #     #return if not isNaN value
  #     console.log key, value

    #for key, value of i
    #  return if not isNaN value
    #  console.log value

#high, low, close, volume
function A_D then ((it[\close] - it[\low]) - (it[\high] - it[\close])) / (it[\high] - it[\low]) * it[\volume]

# %K need to input a array of last 15 days stock object including current day at the first index
function percent-K
  result = []
  # ary = it.reverse!
  # [low, high] = [ary[0][\low], ary[0][\high]]

  for i from 0 til it.length - 14
    [low, high] = find-lowest-highest(for j from i til i + 14 then it[j])[\low, \high]
    result.push (it[i][\close] - low) / (high - low) * 100

  result

  #cur-obj = it.shift!
  #last-obj = it.pop!

  #[low, high] = [last-obj[\low], last-obj[\high]]

  #for obj in it
  #  if obj[\low]  < low  then low  = obj[\low]
  #  if obj[\high] > high then high = obj[\high]

  #(cur-obj[\close] - low) / (high - low) * 100

function percent-R
  result = []
  for i from 0 til it.length - 14
    [low, high] = find-lowest-highest(for j from i til i + 14 then it[j])[\low, \high]
    result.push((high - it[i][\close]) / (high - low) * 100)

  result

# input the result of %K
function percent-D then sma it, 3

# input the result of %K
# OR can input the result of %D to %D
function slow-precent-D then sma (percent-D it), 3

# input : a array of obj which has its own propertys "low" & "high"
function find-lowest-highest
  [low, high] = it.pop![\low, \high]
  for obj in it
    if obj[\low]  < low  then low  = obj[\low]
    if obj[\high] > high then high = obj[\high]

  {low: low, high: high}

function sma ary, n then for i from 0 til ary.length - n then close-avg(for j from i til i + n then ary[j])

# count the average of the input array's own property "close"
function close-avg
  it = it.map -> it.close
  (it.reduce (a, b) -> (a + b), 0) / it.length

# need to input a number n
function ROC ary, n then for i from 0 til ary.length - n then (ary[i][\close] - ary[i + n][\close]) / ary[i + n][\close] * 100

function momentum then for i from 0 til it.length - 4 then (it[i][\close] - it[i + 4][\close]) / it[i + 4][\close]

# need to input 5 ro 10
function disparity ary, n
  result = []
  sma-n = sma ary, n
  for i from 0 til sma-n.length
    result.push (ary[i][\close] / sma-n[i] * 100)

  result

function OSCP
  result = []
  sma_5  = sma it, 5
  sma_10 = sma it, 10
  for i from 0 til sma_5.length
    result.push (sma_5[i] - sma_10[i]) / sma_5[i]

  result

# input the string of date e.g. 104/01/14
function date-shipping
  total = exec-sync.exec("curl --data 'download=csv&qdate=#it&selectType=MS' http://www.twse.com.tw/ch/trading/exchange/MI_INDEX/MI_INDEX.php | iconv -f BIG-5 -t UTF-8").stdout
  if total is /航運類指數,(.+),(\+|-),(.+),(.+)/
    [index, change, change-num, change-percent] = [parseFloat(that[1]), that[2], parseFloat(that[3]), parseFloat(that[4])]

  [index, change, change-num, change-percent]

!function mkdir
  if !fs.exists-sync it then fs.mkdir-sync it
  else if !fs.stat-sync it .is-directory then fs.mkdir-sync it

# vi:et:sw=2:ts=2
