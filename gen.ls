require! <[execSync moment fs]>

date = moment \2010-01-01, \YYYY-MM-DD
cur-date = moment!

result = []

loop
  break if (date.format \YYYY/MM/DD) is (cur-date.format \YYYY/MM/DD)
  date.add 1, \days
  ary = date-shipping date.format \YYYY/MM/DD
  console.log date.format \YYYY/MM/DD
  continue if ary.length is 0
  console.log ary
  result.push {date: (date.format \YYYY-MM-DD), index: ary[0]}

fs.write-file-sync "./shipping", JSON.stringify result, null, 2

function date-shipping
  console.log it
  if it is /(\d{4})\/(\d{2})\/(\d{2})/
    it = "#{parseInt that[1] - 1911}/#{that[2]}/#{that[3]}"

  total = exec-sync.exec("curl --data 'download=csv&qdate=#it&selectType=MS' http://www.twse.com.tw/ch/trading/exchange/MI_INDEX/MI_INDEX.php | iconv -f BIG-5 -t UTF-8").stdout
  if total is /航運類指數,(.+),(\+|-),(.+),(.+)/
    [index, change, change-num, change-percent] = [parseFloat(that[1]), that[2], parseFloat(that[3]), parseFloat(that[4])]
    return [index, change, change-num, change-percent]
  else return []

# vi:et:sw=2:ts=2
