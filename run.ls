require! <[execSync fs]>

stocks = fs.readdir-sync \./stock

for let name in stocks
  dir = "./stock/#name"
  scale = "./svm-scale -s train_scale_model #{dir}/train_data"
  rvkde = "./rvkde --best --cv --classify -n 5 -v #{dir}/train_data.scale"
  fs.write-file-sync "#dir/train_data.scale", exec-sync.exec(scale).stdout
  fs.write-file-sync "#dir/train_result", exec-sync.exec(rvkde).stdout

# vi:et:sw=2:ts=2
