require! <[fs async line-reader]>

stock-dir = \/home/mlb/stock/
stock = <[2615 2612 2603 2605 6702 2609 5608 2617 2613 2637 2606 2208 2607 2611 5607]>

orig-data = []

for let number in stock
  lineReader.eachLine stock-dir+number, (line) !->
    # console.log line
    if /(.+?),(.+?),(.+?),(.+?),(.+?),(.+?),(.+)/ is line
      orig-data.push {date:parseInt(that.1), open:parseInt(that.2), high:parseInt(that.3), low:parseInt(that.4), close:parseInt(that.5), volume:parseInt(that.6), adj:parseInt(that.7)}
      console.log orig-data
  # .then parse_data

function A_D high, low, close, volume
  ((close - low) - (high - close)) / (high - low) * volume

# vi:et:sw=2:ts=2
