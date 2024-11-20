# some_script
记录一些常用的脚本

# debian相关
## 1、修改源以及DNS变更
```shell
wget -O debian12_quick.sh https://raw.githubusercontent.com/ClearMind1/some_script/main/debian12/main.sh && bash debian12_quick.sh
```
or
```shell
curl -L -o s3cmd.sh https://raw.githubusercontent.com/ClearMind1/some_script/main/debian12/main.sh && bash debian12_quick.sh
```

# s3cmd快速脚本
```shell
wget -O s3cmd.sh https://raw.githubusercontent.com/ClearMind1/some_script/main/s3cmd.sh && bash s3cmd.sh
```
or
```shell
curl -L -o s3cmd.sh https://raw.githubusercontent.com/ClearMind1/some_script/main/s3cmd.sh && bash s3cmd.sh
```

# v2ray快速脚本
来源：bash <(wget -qO- -o- https://git.io/v2ray.sh)
将github链接添加上搭理，方便国内使用
```shell
curl -L -o v2ray_i.sh https://gh-proxy.com/raw.githubusercontent.com/ClearMind1/some_script/main/v2ray_i.sh && bash v2ray_i.sh
```