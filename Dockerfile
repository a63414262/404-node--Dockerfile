# 使用轻量级的 Node.js 18 镜像
FROM node:18-alpine

# 安装 git, curl 和 unzip 这三个基础工具
RUN apk add --no-cache git curl unzip

# 克隆指定的 GitHub 仓库到容器的 /app 目录
RUN git clone https://github.com/a63414262/404-node.git /app

# 设置工作目录
WORKDIR /app

# 安装 Node.js 依赖
RUN npm install

# 关键修改 1：设置默认端口为 3000 或 7860。
# 这样在没有强行指定端口的平台（如本地测试）会使用默认值；
# 而在 Heroku、Render 等平台，它们会在启动容器时自动注入自带的 PORT 环境变量来覆盖这个值。
ENV PORT=7860

# 关键修改 2：使用变量进行 EXPOSE（注：EXPOSE 更多是作为文档和提示，云平台实际上是直接读取 PORT 变量）
EXPOSE 7860

# 运行 index.js
CMD ["node", "index.js"]
