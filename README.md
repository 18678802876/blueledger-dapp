# BlueLedger 链上记账本 — 从这里开始

基于你提供的 Flask + ethers + MetaMask 示例扩展。新增按钱包保存的支出列表、金额统计、分类、备注、时间与分页。不是对 SimpleStorage 简单换名。

这是课堂演示应用：金额单位为 SGD，合约只记录以“分”为单位的数字，不转移 SGD 或 ETH；发送交易会消耗 Sepolia 测试 ETH。记录公开且无法通过此合约修改或删除，请只录入虚构样例。链上记录证明某钱包提交了什么，不证明真实消费发生。

## 1. 先部署新合约（电脑操作）

1. 打开 https://remix.ethereum.org 。
2. 在左侧文件区新建 `ExpenseLedger.sol`，把本项目同名文件内容全部复制进去。
3. 打开 Solidity Compiler，选择 `0.8.20` 或兼容的 0.8.x 编译器，点击 Compile ExpenseLedger.sol。若使用较新编译器，可在高级配置将 EVM Version 设为 Shanghai。
4. 在 MetaMask 选择 Sepolia 测试网络。钱包需要测试 ETH 作为 gas；不要购买或使用主网 ETH。若余额为零，可使用 https://cloud.google.com/application/web3/faucet/ethereum/sepolia 等测试水龙头，资格要求以服务为准。
5. 打开 Remix 的 Deploy & Run Transactions。在 Environment 中选连接浏览器钱包的 **Injected Provider / MetaMask** 选项，确认钱包网络是 Sepolia。不要用 Remix VM（它仅在 Remix 内部运行）。
6. Contract 选 ExpenseLedger。Value 保持 0。点击 Deploy，在 MetaMask 确认并等待成功。
7. 复制 Deployed Contracts 下面新合约的 `0x...` 地址。它不是你的钱包地址，也不是以前 SimpleStorage 的地址。

合约没有构造参数，也无需输入私钥或助记词。

## 2. 上传到 GitHub

1. 解压 blueledger-dapp.zip。
2. 新建一个 GitHub 仓库，比如 `blueledger-dapp`。
3. 选择 Add file → Upload files。
4. 上传 blueledger 文件夹**里面的所有文件和文件夹**，保留 templates 和 static 的目录结构；不要仅上传 zip。
5. 仓库首页应直接看到 app.py、requirements.txt、ExpenseLedger.sol、templates/、static/。
6. 提交（Commit changes）。

## 3. 部署网页到 Render

打开 https://dashboard.render.com ，选择 New → Web Service，连接刚才的 GitHub 仓库。

| Render 设置 | 填写内容 |
| --- | --- |
| Name | blueledger-dapp（或可用名称） |
| Language / Runtime | Python 3 |
| Branch | main（以实际分支为准） |
| Root Directory | 留空，前提是 app.py 在仓库根目录 |
| Build Command | pip install -r requirements.txt |
| Start Command | gunicorn app:app --bind 0.0.0.0:$PORT |
| Instance Type | 选择可用的 Free 选项（若提供） |
| Health Check Path | /health |

在 Environment Variables 添加：

- Key：`CONTRACT_ADDRESS`
- Value：第 1 步部署的新 ExpenseLedger 合约地址。

这一项很重要：老师打开网页就会自动看到正确的合约地址，不需要自己填写。它是公开地址，可以放在环境变量里。若暂未设置，也可以在网页输入地址；但浏览器保存的地址只在当前设备生效。

点击 Deploy Web Service，等待成功。Render 给出的 `https://某个名称.onrender.com` 才是你最后提交的网址。设置这些字段的官方参考：https://render.com/docs/deploy-flask 。免费实例可能在闲置后需要时间启动。

## 4. 实际测试（必须做）

电脑：在有 MetaMask 扩展的浏览器中打开 Render 链接。

手机：打开 MetaMask App → 内置浏览器，粘贴 Render 链接。也可先在普通浏览器打开网页，再点 Open in MetaMask。普通 Safari/Chrome 能显示页面，但本版本签名操作需要钱包提供的浏览器环境。

1. 确认页面已有新合约地址，点击 Connect MetaMask，连接 Sepolia。
2. 金额输入 `8.50`，分类选 Food & drinks，备注写 `Sample lunch`。
3. 点击 Save expense on blockchain。在 MetaMask 确认，等待页面显示 confirmed。
4. 总支出应增加 S$ 8.50，历史记录中出现新记录。
5. 点击交易链接，可以到 Sepolia Etherscan 查看交易。
6. 刷新网页，重新连接同一钱包，记录仍然存在。
7. 可换一个钱包验证：新钱包的统计和历史独立，从 0 开始。
8. 将通过以上测试的 Render HTTPS 网址发给老师。

## 遇到问题

- **No contract at this address**：地址不在 Sepolia、填了钱包地址，或使用了 Remix VM。请重新按第 1 部分部署。
- **This is not an ExpenseLedger contract**：你填了旧 SimpleStorage 或其他合约地址。
- **No wallet / Open this URL inside MetaMask**：手机请在 MetaMask 内置浏览器打开；电脑确认扩展已安装并解锁。
- **余额不足**：缺少 Sepolia 测试 ETH，不能靠给表单填金额解决。
- **切换网络失败**：在 MetaMask 开启测试网络显示，手动选 Sepolia，再连接。
- **Render 找不到 app**：app.py 不在所配置的 Root Directory，或文件夹多套了一层。
- **CDN/网络请求失败**：ethers.js 由 jsDelivr 加载，需要可访问该域名的网络；检查后刷新。
- **交易已提交但等待中**：先看交易链接，确认结果再决定是否重试，避免重复记账。

## 项目结构与原理

- `app.py`：Flask 提供网页与健康检查。
- `templates/index.html`：网页结构，自动填入配置的合约地址。
- `static/style.css`：蓝色界面及手机布局。
- `static/app.js`：连接钱包、调用合约、展示记录。
- `ExpenseLedger.sol`：链上保存记录的智能合约。
- `requirements.txt`：Render 安装的 Python 依赖。

用户打开 Render 网页 → 网页通过 MetaMask 请求签名 → Sepolia 执行合约 → 网页读取并显示链上记录。Flask 不存储支出数据库、不持有钱包私钥。每个人只能以自己的钱包身份新增记录，但所有人的链上记录都是公开可读的；Solidity 的 private 不等于加密。

## 本地运行（可选）

```bash
pip install -r requirements.txt
python app.py
```

电脑访问 http://localhost:5000 。正式提交用 Render HTTPS 地址。

## 给老师的英文说明

BlueLedger is a wallet-based expense journal on the Sepolia test network. Users can record an expense amount, category and note, view their total spending, and retrieve their transaction history. Each wallet has its own records. The smart contract stores the records, while Flask serves a mobile-friendly interface. This is an educational prototype: it records declared expenses, does not transfer money, and does not verify real purchases.

## 与原示例区别

| 原 SimpleStorage | BlueLedger |
| --- | --- |
| 所有人共用一个数字 | 每个钱包拥有独立记录列表 |
| 修改覆盖旧数字 | 只追加记录，保留历史 |
| 只存 uint256 | 金额、类别、备注和区块时间 |
| 读取单个数 | 总支出、记录数、每页 10 条历史 |

参考文档：https://docs.ethers.org/v6/ 、https://support.metamask.io/zh-cn/configure/wallet/how-to-use-the-metamask-mobile-browser/ 。
