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
  result-line = train-result / "\n"
  [alpha, beta, ks, kt, score] = result-line[11] / " "
  beta += 10
  ks += 10
  kt += 10

  loop
    test-result = exec-sync.exec("./rvkde --best --cv --classify -b 1,#beta,1 --ks 1,#ks,1 --kt 1,#kt,1 -n 5 -v #{dir}/train_data.scale").stdout

    para = (test-result / "\n")[11] / " "
    if para[1] is beta
      beta += 10
      continue
    if para[2] is ks
      ks += 10
      continue
    if para[3] is kt
      kt += 10
      continue
    break

  [alpha, beta, ks, kt, score]

# vi:et:sw=2:ts=2
