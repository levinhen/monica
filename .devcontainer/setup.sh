#!/bin/bash
set -e  # 任何命令失败立即退出

echo "========================================"
echo "  Monica CRM - 开发环境初始化"
echo "========================================"

# ── 1. 安装系统依赖 ──────────────────────────
echo ""
echo "▶ [1/6] 安装系统依赖..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
  sqlite3 \
  php8.2-sqlite3 \
  php8.2-bcmath \
  php8.2-intl \
  php8.2-gd

# ── 2. 安装 Yarn ──────────────────────────────
echo ""
echo "▶ [2/6] 安装 Yarn..."
npm install -g yarn --silent

# ── 3. 安装 PHP 依赖（Composer）──────────────
echo ""
echo "▶ [3/6] 安装 PHP 依赖（composer install）..."
composer install \
  --no-progress \
  --no-interaction \
  --prefer-dist \
  --optimize-autoloader

# ── 4. 安装 JS 依赖（Yarn）───────────────────
echo ""
echo "▶ [4/6] 安装 JS 依赖（yarn install）..."
yarn install --frozen-lockfile

# ── 5. 配置环境变量 ───────────────────────────
echo ""
echo "▶ [5/6] 配置 .env 环境变量..."

# 只在 .env 不存在时才复制（防止重复初始化覆盖用户改动）
if [ ! -f ".env" ]; then
  cp .env.example .env
fi

# 生成 APP_KEY
php artisan key:generate --no-interaction

# 配置 SQLite：创建数据库文件，写入绝对路径
SQLITE_PATH="$(pwd)/monica.db"
touch "$SQLITE_PATH"

# 替换 .env 中的数据库配置
sed -i "s|^DB_CONNECTION=.*|DB_CONNECTION=sqlite|" .env
sed -i "s|^DB_HOST=|#DB_HOST=|" .env
sed -i "s|^DB_PORT=|#DB_PORT=|" .env
sed -i "s|^DB_DATABASE=.*|DB_DATABASE=${SQLITE_PATH}|" .env
sed -i "s|^DB_USERNAME=|#DB_USERNAME=|" .env
sed -i "s|^DB_PASSWORD=|#DB_PASSWORD=|" .env

# ── 6. 初始化数据库 + 填充演示数据 ───────────
echo ""
echo "▶ [6/6] 初始化数据库 + 填充演示数据..."
php artisan monica:setup --force -vvv
php artisan monica:dummy --force -vvv

echo ""
echo "========================================"
echo "  ✅ 初始化完成！"
echo ""
echo "  启动开发服务器："
echo "    yarn dev"
echo ""
echo "  默认登录账号："
echo "    邮箱: admin@admin.com"
echo "    密码: secret"
echo "========================================"