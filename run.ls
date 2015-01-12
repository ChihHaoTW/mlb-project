require! <[exec-sync fs]>

stocks = fs.readdir-sync \./stock

for let name in stocks
  dir = "./stock/#name"
  scale = "./svm-scale -s train_scale_model #{dir}/train_data"
  rvkde = "./rvkde --best --cv --classify -n 5 -v #{dir}/train_data.scale"
# fs.write-file-sync "#dir/train_data.scale", exec-sync(scale)
  fs.write-file-sync "#dir/train_result", exec-sync(rvkde)

# vi:et:sw=2:ts=2
