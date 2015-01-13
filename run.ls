require! <[execSync fs]>

stocks = fs.readdir-sync \./stock

for let name in stocks
  dir = "./stock/#name"
  scale = "./svm-scale -s train_scale_model #{dir}/train_data"
  rvkde = "./rvkde --best --cv --classify -n 5 -v #{dir}/train_data.scale"
  predict-scale = "./svm-scale -s predict_scale_model #{dir}/predict_data"
  predict-rvkde = "./rvkde --best --predict --classify -v #{dir}/train_data.scale -V #{dir}/predict_data.scale"
  fs.write-file-sync "#dir/train_data.scale", exec-sync.exec(scale).stdout
#  fs.write-file-sync "#dir/train_result", exec-sync.exec(rvkde).stdout
  tune exec-sync.exec(rvkde).stdout, dir
#  fs.write-file-sync "#dir/predict_data.scale", exec-sync.exec(predict-scale).stdout
#  fs.write-file-sync "#dir/predict_result", exec-sync.exec(predict-rvkde).stdout

# input the rsult of train_result
function tune train-result, dir
  if train-result is /\[score\]\n([0-9.]+)\s([0-9.]+)\s([0-9.]+)\s([0-9.]+)\s([0-9.]+)/
  # result-line = train-result / "\n"
    #  [void, alpha, beta, ks, kt, score] = that
    beta = (parseInt that[2]) + 10
    ks   = (parseInt that[3]) + 10
    kt   = (parseInt that[4]) + 10

  loop
    check = false

    test-result = exec-sync.exec("./rvkde --best --cv --classify -b 1,#beta,1 --ks 1,#ks,1 --kt 1,#kt,1 -n 5 -v #{dir}/train_data.scale").stdout
    console.log "./rvkde --best --cv --classify -b 1,#beta,1 --ks 1,#ks,1 --kt 1,#kt,1 -n 5 -v #{dir}/train_data.scale"

    if test-result is /\[score\]\n([0-9.]+)\s([0-9.]+)\s([0-9.]+)\s([0-9.]+)\s([0-9.]+)/
      [r-beta, r-ks, r-kt] = [parseInt(that[2]), parseInt(that[3]), parseInt(that[4])]
      if r-beta is beta
        beta += 10
        check = true
      if r-ks is ks
        ks += 10
        check = true
      if r-kt is kt
        kt += 10
        check = true

    break if not check

  console.log  [r-beta, r-ks, r-kt]

  [r-beta, r-ks, r-kt]

# vi:et:sw=2:ts=2
