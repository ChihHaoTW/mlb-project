require! <[execSync fs]>

stocks = fs.readdir-sync \./stock

for let name in stocks
  dir = "./stock/#name"
  scale = "./svm-scale -s train_scale_model #{dir}/train_data"
  rvkde = "./rvkde --best --cv --classify -n 5 -v #{dir}/train_data.scale"
  predict-scale = "./svm-scale -s predict_scale_model #{dir}/predict_data"
  predict-rvkde = "./rvkde --best --predict --classify -v #{dir}/train_data.scale -V #{dir}/predict_data.scale"
  fs.write-file-sync "#dir/train_data.scale", exec-sync.exec(scale).stdout
# fs.write-file-sync "#dir/train_result", exec-sync.exec(rvkde).stdout
  fs.write-file-sync "#dir/predict_data.scale", exec-sync.exec(predict-scale).stdout
  fs.write-file-sync "#dir/predict_result", exec-sync.exec(predict-rvkde).stdout

# vi:et:sw=2:ts=2
