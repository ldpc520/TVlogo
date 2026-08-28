# 永久更换 pip / npm 镜像源 (中文数字菜单)
# 用法(本机已保存时):  powershell -File change_source.ps1
# 用法(远程一行):      iex (irm https://你的地址/change_source.ps1)
# 说明: 写用户级配置，无需管理员权限，重启/重开终端依然生效。

# ---- 中文输出不乱码 (关键!) ----
# PowerShell 5.1 的蓝色 conhost 窗口控制台代码页是 936 (GBK)，
# 但 [Console]::OutputEncoding 默认却是 UTF-8，两者不一致 -> 乱码。
# 解决: 把 OutputEncoding 设成系统默认编码 (中文 Windows = GBK)，
# 让 Write-Host 输出的字节与控制台代码页一致。绝不去改 chcp ，
# 否则会把蓝色宿主搞坏 (chcp 65001 + conhost 是有名的 PS5.1 兼容坑)。
$OutputEncoding = [System.Text.Encoding]::Default
[Console]::OutputEncoding = [System.Text.Encoding]::Default

Write-Host '============================================================'
Write-Host '          永久更换 pip 与 npm 镜像源  (中文菜单)'
Write-Host '============================================================'
Write-Host ''

# ---------- pip 镜像源表 ----------
$pipSources = @{
    '1' = 'https://pypi.tuna.tsinghua.edu.cn/simple'
    '2' = 'https://mirrors.aliyun.com/pypi/simple/'
    '3' = 'https://mirrors.cloud.tencent.com/pypi/simple'
    '4' = 'https://repo.huaweicloud.com/repository/pypi/simple'
    '5' = 'https://pypi.mirrors.ustc.edu.cn/simple/'
    '6' = 'https://pypi.org/simple'
}

# ---------- npm 镜像源表 ----------
$npmSources = @{
    '1' = 'https://registry.npmmirror.com'
    '2' = 'https://mirrors.cloud.tencent.com/npm/'
    '3' = 'https://repo.huaweicloud.com/repository/npm/'
    '4' = 'https://registry.npmjs.org'
}

# ---------- 检测 pip ----------
$pipOk = $false
$pipCur = '(未设置)'
Write-Host '[检测] 正在检查 pip ...'
if (Get-Command pip -ErrorAction SilentlyContinue) {
    $pipOk = $true
    $raw = (pip config list 2>$null) -join ' ; '
    if ($raw) { $pipCur = $raw }
    Write-Host "  pip 已安装，当前源: $pipCur"
} else {
    Write-Host '  [警告] 未检测到 pip，将跳过 pip 配置。'
}
Write-Host ''

# ---------- 检测 npm ----------
$npmOk = $false
$npmCur = '(未设置)'
Write-Host '[检测] 正在检查 npm ...'
if (Get-Command npm -ErrorAction SilentlyContinue) {
    $npmOk = $true
    $raw = (npm config get registry 2>$null)
    if ($raw) { $npmCur = $raw.Trim() }
    Write-Host "  npm 已安装，当前源: $npmCur"
} else {
    Write-Host '  [警告] 未检测到 npm，将跳过 npm 配置。'
}
Write-Host ''

# ---------- pip 镜像选择 ----------
$pipUrl = ''
if ($pipOk) {
    Write-Host '============================================================'
    Write-Host '                  请选择 pip 镜像源'
    Write-Host '============================================================'
    Write-Host '  [1] 清华大学   https://pypi.tuna.tsinghua.edu.cn/simple'
    Write-Host '  [2] 阿里云     https://mirrors.aliyun.com/pypi/simple/'
    Write-Host '  [3] 腾讯云     https://mirrors.cloud.tencent.com/pypi/simple'
    Write-Host '  [4] 华为云     https://repo.huaweicloud.com/repository/pypi/simple'
    Write-Host '  [5] 中科大     https://pypi.mirrors.ustc.edu.cn/simple/'
    Write-Host '  [6] 官方源     https://pypi.org/simple'
    Write-Host '  [0] 跳过(保留当前源)'
    Write-Host '  [c] 自定义输入 URL'
    Write-Host ''
    $c = Read-Host '请输入 pip 选择(默认 1)'
    if (-not $c) { $c = '1' }

    if ($c -eq '0') {
        $pipUrl = ''
    } elseif ($c -eq 'c') {
        $pipUrl = Read-Host '请粘贴你的 pip 源 URL'
    } elseif ($pipSources.ContainsKey($c)) {
        $pipUrl = $pipSources[$c]
    } else {
        Write-Host '  [警告] 无效选择，默认使用清华大学源。'
        $pipUrl = $pipSources['1']
    }

    if ($pipUrl) {
        Write-Host "  [信息] 选定 pip 源: $pipUrl"
    } else {
        Write-Host '  [信息] 已跳过 pip 源设置。'
    }
    Write-Host ''
}

# ---------- npm 镜像选择 ----------
$npmUrl = ''
if ($npmOk) {
    Write-Host '============================================================'
    Write-Host '                  请选择 npm 镜像源'
    Write-Host '============================================================'
    Write-Host '  [1] 淘宝 npmmirror  https://registry.npmmirror.com'
    Write-Host '  [2] 腾讯云          https://mirrors.cloud.tencent.com/npm/'
    Write-Host '  [3] 华为云          https://repo.huaweicloud.com/repository/npm/'
    Write-Host '  [4] 官方源          https://registry.npmjs.org'
    Write-Host '  [0] 跳过(保留当前源)'
    Write-Host '  [c] 自定义输入 URL'
    Write-Host ''
    $c = Read-Host '请输入 npm 选择(默认 1)'
    if (-not $c) { $c = '1' }

    if ($c -eq '0') {
        $npmUrl = ''
    } elseif ($c -eq 'c') {
        $npmUrl = Read-Host '请粘贴你的 npm 源 URL'
    } elseif ($npmSources.ContainsKey($c)) {
        $npmUrl = $npmSources[$c]
    } else {
        Write-Host '  [警告] 无效选择，默认使用淘宝 npmmirror 源。'
        $npmUrl = $npmSources['1']
    }

    if ($npmUrl) {
        Write-Host "  [信息] 选定 npm 源: $npmUrl"
    } else {
        Write-Host '  [信息] 已跳过 npm 源设置。'
    }
    Write-Host ''
}

# ---------- 应用配置 ----------
Write-Host '============================================================'
Write-Host '                    正在应用配置'
Write-Host '============================================================'
if ($pipOk -and $pipUrl) {
    Write-Host "[应用] 设置 pip 源: $pipUrl"
    pip config set global.index-url $pipUrl
}
if ($npmOk -and $npmUrl) {
    Write-Host "[应用] 设置 npm 源: $npmUrl"
    npm config set registry $npmUrl
}
Write-Host ''

# ---------- 验证结果 ----------
Write-Host '============================================================'
Write-Host '                    配置结果'
Write-Host '============================================================'
if ($pipOk) {
    Write-Host 'pip 当前源:'
    pip config list 2>$null
    Write-Host ''
}
if ($npmOk) {
    Write-Host 'npm 当前源:'
    (npm config get registry 2>$null)
    Write-Host ''
}

Write-Host '完成！以上配置已永久写入用户目录，重开终端依然生效。'
Write-Host '如需恢复官方源，可再次运行本脚本并选择对应的 [6]/[4] 官方源。'
Write-Host ''
