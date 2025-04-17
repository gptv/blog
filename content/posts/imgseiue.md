+++
date = "2025-04-07T13:25:00+08:00"
draft = false
title = "最值得，與不值"
slug = "imgseiue"
layout = "single"
type = "blog"
+++

這是第十一篇博文。  
看了下之前十篇中，用了兩張圖。這就⋯⋯有點尬，因為開這個新平台時是想純文字的，所以沒想圖床的事情，不想想。  
但1/5的比例，就還是，得想想。  

多年來走了多個平台，都匯總在日常使用的 <a href="https://i.rdfzer.com" target="_blank">導航頁</a> 了。因為真正必須圖的不多，之前的幾個，都直接默認用了自帶。這帶來的問題是，原平台沒了或需要遷移或各種各種時，圖就不好處理，爬下來再折騰，也多不值得。  
互聯網每天在生長，也每天在死亡。說的，就是這些圖文。  

那麼，不如一次解決之。  
梳理了下邏輯。本質上，圖放在哪裡，既不是關鍵問題，也不是問題關鍵。  
我們一直真正需要的，是固定的，可以訪問的鏈接。存儲空間可以隨便死生遷移，只要鏈接固定且可以一直活著或隨時轉世。  

那，就簡單了。  
本機設置好專門博客圖片文件夾。  
敲 R2門，配置空間，拿 API，設置最關鍵的自定義域名一步。確定固定鏈接模式為： 
```
https://img.bdfz.net/20250406001.webp
```
正式開始： 

```
#!/bin/bash

# 啟用更嚴格的錯誤檢查
set -euo pipefail

# --- 配置 ---
RCLONE_REMOTE_NAME="r2"
R2_BUCKET_NAME="blog-images"
R2_ENDPOINT="name.r2.cloudflarestorage.com"

# 從環境變數讀取 Access Key ID 和 Secret Access Key
R2_ACCESS_KEY_ID="${R2_ACCESS_KEY_ID:-}"
R2_SECRET_ACCESS_KEY="${R2_SECRET_ACCESS_KEY:-}"

# 檢查兩個變數是否都已設置 (保留這個檢查是個好習慣)
if [[ -z "$R2_ACCESS_KEY_ID" || -z "$R2_SECRET_ACCESS_KEY" ]]; then
  echo "錯誤：環境變數 R2_ACCESS_KEY_ID 或 R2_SECRET_ACCESS_KEY 未設置。" >&2
  echo "請在運行腳本前設置這兩個變數:" >&2
  echo "export R2_ACCESS_KEY_ID='<你的AccessKeyID>'" >&2
  echo "export R2_SECRET_ACCESS_KEY='<你的SecretAccessKey>'" >&2
  echo "(建議將 export 命令添加到 ~/.zshrc 或 ~/.bash_profile)" >&2
  exit 1
fi

SRC_DIR="/Users/ylsuen/Pictures/blog-images"
PUBLIC_IMG_BASE_URL="https://img.bdfz.net"
MD_FILE="$SRC_DIR/index.md"
PROCESSED_DIR="$SRC_DIR/processed"
IMG_QUALITY=85
PREVIEW_WIDTH=60 # 預覽圖寬度

# --- 輔助函數 ---
check_dependencies() {
  local missing=0
  for cmd in rclone cwebp; do
    if ! command -v "$cmd" &> /dev/null; then
      echo "錯誤：找不到必要的命令 '$cmd'。" >&2; missing=1
    fi
  done
  if ! command -v viu &> /dev/null; then
      echo "提示：未找到 'viu' 命令。圖片預覽功能將不可用。 (brew install viu)" >&2
  fi
  if [[ "$missing" -eq 1 ]]; then exit 1; fi
}
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"; }
error_exit() { log "錯誤：$1" >&2; exit 1; }

# --- 腳本主體 ---
check_dependencies
mkdir -p "$PROCESSED_DIR" || error_exit "無法創建已處理文件夾：$PROCESSED_DIR"

# --- Rclone 配置 ---
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
RCLONE_CONFIG_FILE="${SCRIPT_DIR}/.rclone.conf"
log "將使用 rclone 配置文件: $RCLONE_CONFIG_FILE"
log "檢查並配置 rclone remote '$RCLONE_REMOTE_NAME'..."
RCLONE_CONFIG_CONTENT=$(cat <<EOF
[${RCLONE_REMOTE_NAME}]
type = s3
provider = Cloudflare
access_key_id = ${R2_ACCESS_KEY_ID}
secret_access_key = ${R2_SECRET_ACCESS_KEY}
endpoint = ${R2_ENDPOINT}
EOF
)
log "警告：將在 '$RCLONE_CONFIG_FILE' 中強制更新/創建 rclone remote '$RCLONE_REMOTE_NAME'。"
echo "$RCLONE_CONFIG_CONTENT" > "$RCLONE_CONFIG_FILE"
if [[ $? -ne 0 ]]; then error_exit "無法寫入 rclone 配置文件: $RCLONE_CONFIG_FILE"; fi
log "rclone remote '$RCLONE_REMOTE_NAME' 配置已寫入 '$RCLONE_CONFIG_FILE'。"

# --- 圖片處理和上傳 ---
DATE_SUFFIX=$(date +%F)
DATE_COMPACT=$(date +%Y%m%d)
DEST_RCLONE_PATH="${RCLONE_REMOTE_NAME}:${R2_BUCKET_NAME}/"
OUT_DIR=$(mktemp -d -t converted_images_XXXXXX)
trap 'log "清理臨時目錄 $OUT_DIR..."; rm -rf "$OUT_DIR"' EXIT
log "使用臨時目錄：$OUT_DIR"; log "源圖片目錄：$SRC_DIR"; log "已處理圖片將移至：$PROCESSED_DIR"
log "圖片將上傳到 R2 Bucket 根目錄：$DEST_RCLONE_PATH"; log "Markdown 文件：$MD_FILE"

# 處理 Markdown 文件
MD_NEEDS_UPDATE=0
if [[ ! -f "$MD_FILE" ]]; then
  log "創建 Markdown 文件：$MD_FILE"; echo -e "\n### $DATE_SUFFIX\n" > "$MD_FILE"; MD_NEEDS_UPDATE=1
else
  if ! grep -q "^### $DATE_SUFFIX" "$MD_FILE"; then
      log "向 Markdown 文件 $MD_FILE 添加日期標題..."; echo -e "\n### $DATE_SUFFIX\n" >> "$MD_FILE"; MD_NEEDS_UPDATE=1
  fi
fi

# 獲取起始 COUNT
log "正在檢查 R2 Bucket 中今天 (${DATE_COMPACT}) 已存在的最大文件序號..."
max_num_str=$(rclone --config "$RCLONE_CONFIG_FILE" lsf "$DEST_RCLONE_PATH" --format p | \
                grep -E "^${DATE_COMPACT}[0-9]{3}\.webp$" | \
                sed -E 's/.*([0-9]{3})\.webp/\1/' | \
                sort -nr | head -n 1 || true)
if [[ -z "$max_num_str" ]]; then
    COUNT=1; log "今天還沒有文件，從 001 開始編號。"
else
    max_num=$((10#$max_num_str)); COUNT=$((max_num + 1))
    log "今天已存在最大序號: $(printf "%03d" "$max_num")。新文件將從 $(printf "%03d" "$COUNT") 開始編號。"
fi

# 處理圖片
shopt -s nullglob nocaseglob
IMAGE_FILES=("$SRC_DIR"/*.{jpg,jpeg,png,gif,bmp})
shopt -u nullglob nocaseglob

if [[ ${#IMAGE_FILES[@]} -eq 0 ]]; then log "在 $SRC_DIR 中未找到需要處理的圖片文件。"; exit 0; fi
log "找到 ${#IMAGE_FILES[@]} 個需要處理的圖片文件，開始處理..."
UPLOADED_COUNT=0
declare -a MD_LINKS_ARRAY=()
declare -a PREVIEW_FILES_ARRAY=()

for IMG in "${IMAGE_FILES[@]}"; do
  if [[ ! -f "$IMG" ]] || [[ "$(dirname "$IMG")" == "$PROCESSED_DIR" ]]; then continue; fi
  ORIG_FILENAME=$(basename "$IMG")
  BASE_NAME="${DATE_COMPACT}$(printf "%03d" "$COUNT")"
  NEW_IMG_WEBP="$OUT_DIR/$BASE_NAME.webp"
  log "[$COUNT] 處理: $ORIG_FILENAME -> $BASE_NAME.webp"
  if ! cwebp -q "$IMG_QUALITY" "$IMG" -o "$NEW_IMG_WEBP"; then
    log "警告：轉換圖片 '$ORIG_FILENAME' 失敗。"; continue
  fi
  log "[$COUNT] 上傳: $NEW_IMG_WEBP -> $DEST_RCLONE_PATH"
  if ! rclone --config "$RCLONE_CONFIG_FILE" copy "$NEW_IMG_WEBP" "$DEST_RCLONE_PATH" --progress; then
     log "警告：上傳圖片 '$BASE_NAME.webp' 失敗。"; continue
  fi
  PUBLIC_URL="${PUBLIC_IMG_BASE_URL}/${BASE_NAME}.webp"
  MARKDOWN_LINK="![${ORIG_FILENAME} (${BASE_NAME})](${PUBLIC_URL})"
  MD_LINKS_ARRAY+=("$MARKDOWN_LINK")
  PREVIEW_FILES_ARRAY+=("$NEW_IMG_WEBP")
  log "[$COUNT] ✅ 準備添加 Markdown 鏈接：$MD_FILE"
  log "[$COUNT] 移動原圖 '$ORIG_FILENAME' 到 '$PROCESSED_DIR/'"
  if ! mv "$IMG" "$PROCESSED_DIR/"; then log "警告：移動原圖 '$ORIG_FILENAME' 失敗。"; fi
  ((COUNT++)); ((UPLOADED_COUNT++)); MD_NEEDS_UPDATE=1
done

# 寫入 Markdown 文件
if [[ "$UPLOADED_COUNT" -gt 0 ]]; then
    log "將 $UPLOADED_COUNT 個新鏈接寫入 $MD_FILE"
    printf "%s\n" "${MD_LINKS_ARRAY[@]}" >> "$MD_FILE"
    echo "" >> "$MD_FILE"
fi

# 輸出總結日誌
log "✅ 處理完成。總共找到 ${#IMAGE_FILES[@]} 個待處理文件，成功處理並上傳 $UPLOADED_COUNT 張圖片。"
if [[ "$MD_NEEDS_UPDATE" -eq 1 ]]; then log "Markdown 文件已更新：$MD_FILE"; else log "Markdown 文件無需更新。"; fi

# 輸出鏈接和預覽
if [[ "$UPLOADED_COUNT" -gt 0 ]]; then
    echo; echo "--- 本次成功上傳的鏈接與預覽 ---"
    if command -v viu &> /dev/null; then
        for (( i=0; i<${#MD_LINKS_ARRAY[@]}; i++ )); do
            # *** 移除 local ***
            link="${MD_LINKS_ARRAY[i]}"
            preview_path="${PREVIEW_FILES_ARRAY[i]}"
            echo; printf "%s\n" "$link"
            viu -w $PREVIEW_WIDTH "$preview_path"
            echo "--------------------"
        done
    else
        printf "%s\n" "${MD_LINKS_ARRAY[@]}"
    fi
fi

exit 0
```

此後，遷不遷移，圖鏈接算寫死了；當然，前提是域名要一直了。  
好消息是，之前不翻牆看不到圖的這個博客，更新成上述後，圖可見了。

一個多小時跑通上述，算很短，但其實最值得。  

還有一個最不值得事情，拖到今天，也做完了。  
事情很簡單：上課考勤。  

要說最無用甚至最副作用但各種原因一直運行且影響全校師生每一個人的事情，就這個了。  
當年為什麼要考勤⋯⋯不說了。  

不考勤要每次扣 50，一直；年度都考了的老師，年初還出現了學院點名表揚。  
沒錯，每天課上課前耽誤1-2分鐘做一件可以讓自己不扣錢但對學生毫無意義的事情的老師，才是優秀好老師。  
作為兩年來沒真耽誤時間點名的老師，我從來不優秀，因為擔心被點名表揚我還故意在下課後考勤時去除了幾節。  

為什麼毫無意義了？因為不再是書院，因為已固定教室，因為其實已經有了班主任。  
那麼，毫無意義的事情，還不想天天記掛還要控制被扣錢數，自然，還是花點時間，腳本起來。  

於是，用643行代碼，北京時間12點與21點自動靜默運行兩遍，完成：
* 自動登錄
* 自動提交所有課程考勤
* 自動核查
* 本機通知結果

![Screenshot 2025-04-06 at 22.15.59.png (20250406003)](https://img.bdfz.net/20250406003.webp)

一個多小時跑通上述，算很短，但其實，即便一分鐘，都不值得。  