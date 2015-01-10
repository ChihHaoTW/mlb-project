require! <[fs async line-reader moment]>

stock-dir = \/home/mlb/stock/
stock = <[2615 2612 2603 2605 6702 2609 5608 2617 2613 2637 2606 2208 2607 2611 5607]>

orig-data = []

console.log(filter-date get-index \wti, \2010-01-01, \2014-12-31)
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

function get-index
  arr = []
  data = (fs.read-file-sync it, \utf8) / \\n
  for line in data
    word = line / \,
    arr.push {date: moment(word.0), index: parseFloat(word.1)}
  arr

function filter-date target, begin, end
  arr = []
  for day in target
    if day.date.is-date and day.date.is-between begin, end
      arr.push day
  arr

function parse-data
  for i in it
    for key, value of i
      #return if not isNaN value
      console.log key, value

    #for key, value of i
    #  return if not isNaN value
    #  console.log value

function A_D
#high, low, close, volume
  ((it[\close] - it[\low]) - (it[\high] - it[\close])) / (it[\high] - it[\low]) * it[\volume]

# vi:et:sw=2:ts=2
