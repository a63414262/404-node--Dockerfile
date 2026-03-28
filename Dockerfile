FROM node:18-bullseye-slim

# 1. 安装基础环境
RUN apt-get update && apt-get install -y git curl unzip

# 2. 拉取你的源码
RUN git clone https://github.com/a63414262/404-node.git /app
WORKDIR /app

# 3. 安装依赖
RUN npm install

# 4. 【终极外挂】：创建一个完全独立的补丁文件，接管底层 API
RUN echo "const net = require('net');" > patch.js && \
    echo "const http = require('http');" >> patch.js && \
    echo "function patchListen(originalListen) {" >> patch.js && \
    echo "  return function(...args) {" >> patch.js && \
    echo "    if (typeof args[0] === 'number' || typeof args[0] === 'string') {" >> patch.js && \
    echo "      const cb = args.find(a => typeof a === 'function');" >> patch.js && \
    echo "      return originalListen.call(this, args[0], '0.0.0.0', cb);" >> patch.js && \
    echo "    }" >> patch.js && \
    echo "    return originalListen.apply(this, args);" >> patch.js && \
    echo "  };" >> patch.js && \
    echo "}" >> patch.js && \
    echo "net.Server.prototype.listen = patchListen(net.Server.prototype.listen);" >> patch.js && \
    echo "http.Server.prototype.listen = patchListen(http.Server.prototype.listen);" >> patch.js && \
    echo "const oldWriteHead = http.ServerResponse.prototype.writeHead;" >> patch.js && \
    echo "http.ServerResponse.prototype.writeHead = function(statusCode, ...args) {" >> patch.js && \
    echo "  if (statusCode === 404) statusCode = 200;" >> patch.js && \
    echo "  return oldWriteHead.call(this, statusCode, ...args);" >> patch.js && \
    echo "};" >> patch.js && \
    echo "process.on('uncaughtException', err => console.log('[Anti-Crash]', err.message));" >> patch.js

# 5. 配置云端要求的端口
ENV PORT=7860
EXPOSE 7860

# 6. 【关键】：使用 node -r 预加载我们的 patch.js 外挂，再运行你的代码
CMD ["node", "-r", "./patch.js", "index.js"]
