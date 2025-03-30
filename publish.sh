#!/bin/bash
# publish.sh
# 这个脚本自动化执行以下操作：
# 1. 进入 myblog 子模块，对修改进行 git add、commit、push
# 2. 返回主仓库，更新 myblog 子模块引用，再 git add、commit、push

# 确保传入了一个提交信息
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 \"Commit message for blog update\""
  exit 1
fi

COMMIT_MSG="$1"

echo "Step 1: 进入 myblog 子模块..."
cd myblog || { echo "Error: myblog 目录不存在"; exit 1; }

echo "Step 2: 添加所有更改..."
git add .

echo "Step 3: 在 myblog 中提交更改，提交信息：$COMMIT_MSG"
git commit -m "$COMMIT_MSG"

echo "Step 4: 推送 myblog 子模块到远程仓库..."
git push origin main

echo "Step 5: 返回主仓库..."
cd ..

echo "Step 6: 更新 myblog 子模块引用..."
git add myblog

echo "Step 7: 在主仓库中提交子模块引用更新..."
git commit -m "Update myblog submodule: $COMMIT_MSG"

echo "Step 8: 推送主仓库更新到远程..."
git push origin main

echo "Publish process complete!"