# 1. 依然使用高兼容性的 Debian 镜像
FROM node:18-bullseye-slim

# 2. 安装必要工具
RUN apt-get update && apt-get install -y git curl unzip

# 3. 拉取代码
RUN git clone https://github.com/a63414262/404-node.git /app
WORKDIR /app

# 4. 安装依赖
RUN npm install

# 5. 【终极魔法：底层 API 拦截器】完全无视代码格式，强行接管 Node.js 核心库！
RUN node -e "const fs=require('fs');const patch=\"const http=require('http');const net=require('net');const oL=http.Server.prototype.listen;http.Server.prototype.listen=function(...a){if(typeof a[0]==='number'&&typeof a[1]==='function'){return oL.call(this,a[0],'0.0.0.0',a[1]);}return oL.apply(this,a);};const oN=net.Server.prototype.listen;net.Server.prototype.listen=function(...a){if(typeof a[0]==='number'&&typeof a[1]==='function'){return oN.call(this,a[0],'0.0.0.0',a[1]);}return oN.apply(this,a);};const oW=http.ServerResponse.prototype.writeHead;http.ServerResponse.prototype.writeHead=function(s,...a){if(s===404)s=200;return oW.call(this,s,...a);};process.on('uncaughtException',e=>console.log('Anti-crash:',e.message));\";fs.writeFileSync('index.js', patch + '\n' + fs.readFileSync('index.js','utf8'));"

# 6. 设置端口
ENV PORT=7860
EXPOSE 7860

# 7. 启动程序
CMD ["node", "index.js"]
