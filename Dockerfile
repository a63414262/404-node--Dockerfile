# 使用轻量级的 Node.js 18 镜像
FROM node:18-alpine

# 安装必要工具
RUN apk add --no-cache git curl unzip

# 克隆仓库
RUN git clone https://github.com/a63414262/404-node.git /app

# 设置工作目录
WORKDIR /app

# 安装依赖
RUN npm install

# Fly.io 专用设置：
# 虽然你之前提到了 3000，但在你的日志里：
# Web UI 监听 3001，多路复用器监听 7860。
# 我们这里统一使用 7860 作为主入口（或者根据你 fly.toml 的设置改为 3000）
ENV PORT=7860

# 明确写出数字，方便 Fly.io 扫描
EXPOSE 7860

# 运行
CMD ["node", "index.js"]
