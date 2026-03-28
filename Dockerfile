FROM node:18-alpine

# 安装必要工具
RUN apk add --no-cache git curl unzip

# 克隆代码
RUN git clone https://github.com/a63414262/404-node.git /app
WORKDIR /app

# 安装依赖
RUN npm install

# 【关键修复核心】：使用 sed 命令动态修改 index.js 代码，强制绑定 0.0.0.0
RUN sed -i "s/server.listen(WEB_UI_PORT, () => {/server.listen(WEB_UI_PORT, '0.0.0.0', () => {/g" index.js
RUN sed -i "s/muxServer.listen(webPort, () => {/muxServer.listen(webPort, '0.0.0.0', () => {/g" index.js

# 设置云端要求的环境变量和端口
ENV PORT=7860
EXPOSE 7860

# 启动服务
CMD ["node", "index.js"]
