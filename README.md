# aimigo 一个 ChatGpt App

## 下面是一些常用命令

Flutter 生成代码
```shell
flutter pub run build_runner build
```

Web运行在指定端口
```shell
flutter run -d chrome --web-port 8888  --web-hostname 0.0.0.0
```

Json to dart:
```shell
#生成后修改原json名为"_"开头可忽略此文件，避免下次生成时被覆盖
flutter pub run json5_model --src=lib/data/json  --dist=lib/data/model
```

```shell
#windows sdk路径
"C:\Program Files (x86)\Windows Kits\10\bin\<version>\x64"
```

windows msix 证书生成
```shell
#替换方括号中内容并去掉方括号
msixherocli.exe newcert --directory ./certs --name testname --password password --subject CN=testname --validUntil "2054/1/25 23:01:34"
```
windows构建 msix
```shell
#release
flutter pub run msix:create
#debug
flutter pub run msix:create --debug
#创建自签名msix安装程序
flutter pub run msix:create -c ./certs/testname.pfx -p password
```
生成 windows exe 格式安装包
```shell
choco install innosetup
iscc innosetup/setup.iss
```

windows 安装 choco 包管理器：
```shell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

签名 android apk
```shell
apksigner  sign  --v4-signing-enabled false --ks xxx.jks  --ks-key-alias alias  --out app-arm64-v8a-release-signed.apk app-arm64-v8a-release.apk
```

批量签名 apk
```shell
for file in ./*.apk; do
      filename="${file##*/}"
      echo "Signing ${filename}"
      apksigner sign --v4-signing-enabled false --ks xxx.jks  --ks-pass env:ANDROID_KS_PASS --ks-key-alias alias  --out ${file} ${file}
    done
```

macos 安装 brew
```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```
