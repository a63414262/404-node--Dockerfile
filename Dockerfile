FROM node:18-alpine

# 1. 安装基础工具
RUN apk add --no-cache git curl unzip

# 2. 拉取代码并进入目录
RUN git clone https://github.com/a63414262/404-node.git /app
WORKDIR /app

# 3. 安装依赖
RUN npm install

# 4. 【终极无敌修补法】: 避开空格和换行符陷阱，直接精准注入 0.0.0.0 和 200 状态码
RUN sed -i "s/server.listen(WEB_UI_PORT/server.listen(WEB_UI_PORT, '0.0.0.0'/g" index.js
RUN sed -i "s/muxServer.listen(webPort/muxServer.listen(webPort, '0.0.0.0'/g" index.js
RUN sed -i "s/res.writeHead(404/res.writeHead(200/g" index.js

# 5. 暴露云端指定端口
ENV PORT=7860
EXPOSE 7860

# 6. 启动程序
CMD ["node", "index.js"]
