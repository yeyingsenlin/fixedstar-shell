# fixedstar-shell

一个linux命令行工具，管理WEB服务器相关配置和发布。

先要上传工具代码，进入工具目录
```shell
cd fixedstar-shell
```

需要在 common.sh 中修改对应的conf目标 conf_target
```shell
vi ./lib/common.sh
```

将go文件设置为可执行
```shell
sudo chmod 777 ./go.sh
```

然后执行go，根据菜单提示操作即可
```shell
./go.sh
```

如果要在指定运行目录或本地(build/debug)模式中切换，请在创建项目后修改项目配置文件 server_local

