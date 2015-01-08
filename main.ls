require! <[fs async line-reader]>

stock-dir = \/home/mlb/stock/
stock = <[2615 2612 2603 2605 6702 2609 5608 2617 2613 2637 2606 2208 2607 2611 5607]>

orig-data = []

for let number in stock
  lineReader.eachLine stock-dir+number, (line) !->
    # console.log line
    if /(.+?),(.+?),(.+?),(.+?),(.+?),(.+?),(.+)/ is line
      return if isNaN parseFloat that.1
      orig-data.push {date:parseFloat(that.1), open:parseFloat(that.2), high:parseFloat(that.3), low:parseFloat(that.4), close:parseFloat(that.5), volume:parseInt(that.6), adj:parseFloat(that.7)}
  .then parse-data

function parse-data
  #console.log orig-data
  for i in orig-data
    for key, value of i
      return if not isNaN value
      console.log \!!!!

function A_D high, low, close, volume
  ((close - low) - (high - close)) / (high - low) * volume

# vi:et:sw=2:ts=2
