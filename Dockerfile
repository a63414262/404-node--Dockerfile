# 1. 换用标准 Debian 镜像，完美兼容 Xray 和 Argo 核心
FROM node:18

# 2. 安装必要工具 (Debian 系统使用 apt-get)
RUN apt-get update && apt-get install -y git curl unzip

# 3. 拉取代码
RUN git clone https://github.com/a63414262/404-node.git /app
WORKDIR /app

# 4. 安装依赖
RUN npm install

# 5. 【终极修补法】: 用 Node.js 脚本精准“动手术”，绝不出错
RUN node -e "\
const fs = require('fs'); \
let code = fs.readFileSync('index.js', 'utf8'); \
code = code.replace(/server\.listen\(\s*WEB_UI_PORT\s*,/, 'server.listen(WEB_UI_PORT, \"0.0.0.0\",'); \
code = code.replace(/muxServer\.listen\(\s*webPort\s*,/, 'muxServer.listen(webPort, \"0.0.0.0\",'); \
code = code.replace(/res\.writeHead\(\s*404\s*,/g, 'res.writeHead(200,'); \
fs.writeFileSync('index.js', code); \
console.log('--- 源码热补丁注入成功 ---'); \
"

# 6. 暴露云端指定端口
ENV PORT=7860
EXPOSE 7860

# 7. 启动程序
CMD ["node", "index.js"]
