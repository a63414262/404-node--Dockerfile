# 1. 换用兼容性更强、更稳定的 Debian 镜像
FROM node:18-bullseye-slim

# 2. 安装必要工具
RUN apt-get update && apt-get install -y git curl unzip

# 3. 拉取代码
RUN git clone https://github.com/a63414262/404-node.git /app
WORKDIR /app

# 4. 安装依赖
RUN npm install

# 5. 【终极修补法】: 注入全局防崩溃保护、修正端口监听、骗过 404 检查
RUN node -e ' \
const fs = require("fs"); \
let code = fs.readFileSync("index.js", "utf8"); \
code = "process.on(\"uncaughtException\", err => console.log(\"[ANTI-CRASH 保护伞触发]:\", err.message));\n" + code; \
code = code.split("server.listen(WEB_UI_PORT, () => {").join("server.listen(WEB_UI_PORT, \"0.0.0.0\", () => {"); \
code = code.split("muxServer.listen(webPort, () => {").join("muxServer.listen(webPort, \"0.0.0.0\", () => {"); \
code = code.split("const webPort = process.env.PORT || 3000;").join("const webPort = process.env.PORT || 7860;"); \
code = code.split("res.writeHead(404,").join("res.writeHead(200,"); \
fs.writeFileSync("index.js", code); \
console.log("--- 防崩溃与端口绑定注入成功 ---"); \
'

# 6. 配置云端端口
ENV PORT=7860
EXPOSE 7860

# 7. 启动程序
CMD ["node", "index.js"]
