require! <[fs async line-reader moment]>

stock-dir = \/home/mlb/stock/
stock = <[2615 2612 2603 2605 6702 2609 5608 2617 2613 2637 2606 2208 2607 2611 5607]>

orig-data = []
wti = filter-date (get-index \wti), \2010-01-01, \2015-12-31
bdi = filter-date (get-index \bdi), \2010-01-01, \2015-12-31

#console.log (combine bdi, wti, \wti)
#console.log(get-index \bdi)

get-stock!

function get-stock
  for let number in stock
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
      change = close-diff one-data
      weather = season one-data
      fs.write-file-sync \train_data, (ml-format [weather], change)
      #parse-data one-data

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
  for i from 0 til c.length
    if c[i].date.is-same d[n].date or c[i].date.is-after d[n].date then _.push d[n].index
    else
      if n < d.length-1	then _.push d[++n].index else _.push d[n].index
  _

#a = [1,2,3]
#b = [1,4,3]

#d = close-diff [{close: 1}, {close: 4}, {close: 3}]
#c = [a, b]
#console.log(ml-format c, d)


function close-diff
  _ = []
  for i from 0 til it.length
    unless it[i + 1] then _.push 0
    else
      if (it[i].close - it[i + 1].close) > 0 then _.push 1 else _.push 0
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
  _ = []
  for day in target
    if day.date.is-between begin, end then _.push day
  _

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
  ary = it.reverse!
  # [low, high] = [ary[0][\low], ary[0][\high]]

  for i from 15 til ary.length
    [low, high] = find-lowest-highest(for j from i - 15 til i then ary[j])[\low, \high]
    result.push((ary[i][\close] - low) / (high - low) * 100)

  result

  #cur-obj = it.shift!
  #last-obj = it.pop!

  #[low, high] = [last-obj[\low], last-obj[\high]]

  #for obj in it
  #  if obj[\low]  < low  then low  = obj[\low]
  #  if obj[\high] > high then high = obj[\high]

  #(cur-obj[\close] - low) / (high - low) * 100

# input the result of %K
function percent-D
  sma it, 3

# input : a array of obj which has its own propertys "low" & "high"
function find-lowest-highest
  [low, high] = it.pop![\low, \high]
  for obj in it
    if obj[\low]  < low  then low  = obj[\low]
    if obj[\high] > high then high = obj[\high]

  {low: low, high: high}

function sma ary, n
  result = []
  for i from n til ary.length
    result.push close-avg(for j from i - n til i then ary[j])

  result

# count the average of the input array's own property "close"
function close-avg
  (it.reduce (a, b) -> (a[\close] + b[\close]), 0) / it.length


# vi:et:sw=2:ts=2
