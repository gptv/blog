+++
date = "2025-04-10T20:33:00+08:00"
draft = false
title = "牆，內外兮上下"
slug = "wc"
layout = "single"
type = "blog"
+++

論壇上有學生發武漢大學“文科生女友”的微信公眾號文章，就想讓 AI 分析為什麼這篇文章把很多人寫噁心了。  
於是老問題來了，直接複製粘貼會被微信做域名限制，圖片不可見。  
純文字粘貼其實可以，但既然要粘，自然還是全貌好點。  

之前複製老課文的微信公號也一樣，其實多年來都這樣。  
滿世界都是牆，每一堵牆背後，都是人心。  

有點煩。
老課文那篇是就是一張張右鍵圖片，逐一複製過來。想想，更煩。  

判斷了下，一篇文章需要粘貼過來，大抵還是有點存個檔的意義的。不如一次做了。  
腳本下載 html 文本和圖片。之後，再一張張拖到論壇去。然後把文件夾隔一段自動扔雲盤。  
其實可以加把圖片自動轉存直接複製粘貼的效果，但念及也沒幾篇公號文章需要被轉，算了。


<details>
Okay, here is a blog post summarizing our entire journey, from identifying the problem to developing and refining the solution, aimed at a technical audience who might face similar challenges.

---

## Taming the Dragon: Copying WeChat Articles with Images Intact

WeChat Official Accounts are a massive source of information, news, and articles, especially in the Chinese-speaking world. However, anyone who's tried to simply copy an article's content and paste it elsewhere (like a personal knowledge base, a document, or another platform) has likely run into a frustrating issue: the text copies over, but all the images appear broken, often replaced by a placeholder saying "This image is from the WeChat Official Account platform and cannot be cited without permission."

Why does this happen? It's WeChat's hotlink protection (`Referer` checking) kicking in. The image URLs point to WeChat's servers (`mmbiz.qpic.cn`), and these servers refuse to serve the image if the request doesn't originate from an approved source (like WeChat itself).

This blog post chronicles the journey of building a robust solution to grab WeChat articles, including their images and formatting, for local use and potential sharing, focusing on a macOS environment.

### The Goal: A Clean, Portable Copy

Our objective was clear: create a way to take a WeChat article URL and generate a local copy that:

1.  Includes all text content.
2.  Displays all images correctly.
3.  Preserves the original formatting as much as possible.
4.  Is easy to use via the command line on macOS.

### Exploring Initial Solutions

We briefly considered several approaches:

1.  **Manual Download & Replace:** Copy text, manually save each image, then manually insert them back. Effective but incredibly tedious for image-heavy articles.
2.  **Browser Extensions:** Tools like SingleFile or note-taking web clippers can often grab full pages. Good option, but relies on third-party extensions working correctly and might not offer fine-grained control.
3.  **Online Tools:** Various web services claim to download WeChat articles. Concerns include reliability, privacy, potential costs, and ads.
4.  **Self-Hosted Script:** Building our own script offers the most control, flexibility, and avoids third-party dependencies (beyond standard libraries). This was the path we chose.

### The Local Script Approach: `getwc` on macOS

We decided to build a command-line tool, `getwc`, invoked like this:

```bash
getwc "https://mp.weixin.qq.com/s/SOME_ARTICLE_ID"
```

This tool would wrap a Python script responsible for the heavy lifting.

**Core Logic (Python):**

The Python script (`wechat_article_parser.py`) would perform the following steps:

1.  **Fetch HTML:** Use the `requests` library to download the article's full HTML source, mimicking a standard browser `User-Agent`.
2.  **Parse HTML:** Use `BeautifulSoup4` to parse the HTML structure.
3.  **Find Content:** Locate the main article content container (usually `<div id="js_content">`).
4.  **Find Images:** Identify all `<img>` tags within the content container. Prioritize the `data-src` attribute (often used for lazy loading) over `src`.
5.  **Fetch Images:** For each image URL pointing to WeChat's servers (`mmbiz.qpic.cn`), use `requests` again to download the actual image bytes. **Crucially, omit the `Referer` header** in this request to bypass hotlink protection. Determine the image's `Content-Type` (MIME type).
6.  **Process Images & Update HTML:** This is where our approach evolved.
7.  **Save Final HTML:** Write the modified HTML content to a local file.

**The Bash Wrapper (`getwc`):**

A simple Bash script was created at `/usr/local/bin/getwc` to:

1.  Take the URL as a command-line argument.
2.  Validate the URL format.
3.  Call the Python script using a specific Python interpreter (more on this later).
4.  Capture the output (the path to the saved HTML file) from the Python script.
5.  Report success or failure to the user.
6.  Optionally, automatically open the generated HTML file.

### First Attempt & Troubleshooting Round 1: Base64 and the Bloat Issue

Our initial Python script implementation aimed for a single, self-contained HTML file. The "Process Images" step involved:

*   Converting the downloaded image bytes into a Base64 Data URI string (`data:image/png;base64,...`).
*   Replacing the `<img>` tag's `src` attribute with this huge Base64 string.

**The Problem:** While this worked perfectly for small articles, processing an article with many high-resolution images resulted in a massive HTML file (e.g., 42.2 MB!). Browsers struggled immensely to open such a large file containing embedded resources. Loading would hang, pages remained blank, or the browser tab would crash due to excessive memory consumption. Base64 encoding also increases data size by ~33%, exacerbating the issue.

**The Fix:** We abandoned the Base64 approach for large articles.

### The Refined Solution: Local Image Files and Relative Paths

We modified the Python script's image processing logic:

1.  **Create Assets Directory:** For each processed article (`Article_Title_Timestamp.html`), create a corresponding folder named `Article_Title_Timestamp_files/`.
2.  **Save Images Locally:** Instead of Base64 encoding, save the raw downloaded image bytes directly into the `_files` directory, using a sequential filename (e.g., `image_0001.jpg`, `image_0002.png`). The correct file extension is determined from the `Content-Type` or URL.
3.  **Update `src` with Relative Path:** Modify the `<img>` tag's `src` attribute to use a relative path pointing to the saved image file (e.g., `src="Article_Title_Timestamp_files/image_0001.jpg"`).

This resulted in a much smaller HTML file (containing only text and tags) and a separate folder with the image assets. Browsers could now open the HTML file instantly.

### Troubleshooting Round 2: The Blank Page Mystery

Success! The HTML file opened quickly... but it was completely blank!

**Diagnosis:** Using the browser's Developer Tools (Inspect Element) was key. We examined the HTML structure (`Elements` tab) and found that the main content `div` (`#js_content`) had inherited inline CSS styles from the original WeChat page: `style="visibility: hidden; opacity: 0;"`. These styles were likely used by WeChat for loading animations but remained active in our static copy because the accompanying JavaScript was missing.

**The Fix:** We added a few lines to the Python script, right after finding the `content_div`, to explicitly remove the `style` attribute from that container before processing its contents:

```python
# Inside process_and_save function, after finding content_div
if content_div.has_attr('style'):
    del content_div['style'] # Remove the problematic inline style
```

With this change, the generated HTML finally rendered correctly in the browser, showing both text and locally referenced images.

### Handling Python Dependencies: Virtual Environments (PEP 668)

When trying to install the required Python libraries (`requests`, `beautifulsoup4`) using `pip3 install ...`, we encountered the `error: externally-managed-environment`. Modern Python distributions (especially on macOS managed by Homebrew) discourage installing packages globally with `pip` to avoid conflicts.

**The Solution:** Use a Python virtual environment.

1.  Create a dedicated directory for the script (e.g., `~/scripts`).
2.  Inside that directory, create a virtual environment: `python3 -m venv venv`
3.  Activate it: `source venv/bin/activate`
4.  Install dependencies *within* the activated environment: `pip install requests beautifulsoup4`
5.  Modify the `getwc` Bash script to explicitly call the Python interpreter *from the virtual environment*: `$HOME/scripts/venv/bin/python3` instead of just `python3`. This ensures the script always uses the environment with the correct dependencies installed, without needing manual activation each time.

### The Final Hurdle: Pasting into Discourse (or other Web Platforms)

We now had a working local HTML copy. The final goal was to easily copy this content into another platform, like the Discourse forum software. Simply selecting all (Cmd+A) in the browser and pasting (Cmd+V) into the Discourse editor led to a familiar problem: text appeared, but images were broken, shown as Markdown links like `![](Article_Title_Timestamp_files/image_0001.jpg)`.

**The Reason:** The pasted HTML contained relative image paths (`_files/...`). These paths are only meaningful *relative to the HTML file on the local machine*. The Discourse server has no access to these local files.

**The Recommended Solution (for Discourse): Manual Upload**

While less automated, the most reliable way to get the content into Discourse is:

1.  Open the local HTML file in your browser.
2.  Open the corresponding `_files` folder in Finder.
3.  Copy the **text portions** from the browser and paste them into the Discourse editor.
4.  For each image, **drag the image file** from the Finder (`_files` folder) directly into the Discourse editor at the desired location.
5.  Discourse's editor will typically handle the drag-and-drop, **uploading the image** to its own storage and inserting the correct image tag referencing the uploaded file.

This leverages Discourse's built-in upload mechanism, ensuring images are properly hosted and displayed within the platform. While manual, it's the most robust workflow for integrating local content with server-based platforms. (An alternative involving modifying the script to upload images to a public image host first was deemed too complex for this user's primary need).

### The Final Code

Here are the final, working versions of the scripts:

**1. Python Script (`~/scripts/wechat_article_parser.py`)**
*(Saves images locally, removes hiding styles)*

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
from bs4 import BeautifulSoup
# import base64 # No longer needed for main logic
import re
import sys
import os
import mimetypes
from urllib.parse import urlparse, unquote
from datetime import datetime
import time
# import uuid # Using counter for filenames

# --- Configuration ---
FETCH_HTML_HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'zh-cn,zh;q=0.9,en;q=0.8',
    'Connection': 'keep-alive',
}
FETCH_IMAGE_HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15',
    'Accept': 'image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
    # Critical: Omit 'Referer'
}
WECHAT_IMAGE_DOMAIN = 'mmbiz.qpic.cn'
OUTPUT_DIR = os.path.expanduser("~/Downloads/WeChat_Articles_Processed")
HTML_TIMEOUT = 25
IMAGE_TIMEOUT = 30
IMAGE_DOWNLOAD_DELAY = 0.05

# --- Helper Functions ---

def log_error(message): print(f"ERROR: {message}", file=sys.stderr)
def log_warning(message): print(f"WARNING: {message}", file=sys.stderr)
def log_info(message): print(message, file=sys.stdout)
def log_debug(message):
    DEBUG = False
    if DEBUG: print(f"DEBUG: {message}", file=sys.stderr)

def fetch_html(url):
    log_debug(f"Fetching HTML from {url}")
    try:
        response = requests.get(url, headers=FETCH_HTML_HEADERS, timeout=HTML_TIMEOUT)
        response.raise_for_status()
        response.encoding = response.apparent_encoding if response.apparent_encoding else 'utf-8'
        log_debug(f"HTML fetched successfully (Status: {response.status_code})")
        return response.text
    # ... (Error handling as before) ...
    except Exception as e:
        log_error(f"An unexpected error occurred fetching HTML: {e}")
        return None

def fetch_image_data(img_url):
    log_debug(f"Fetching image: {img_url[:100]}...")
    time.sleep(IMAGE_DOWNLOAD_DELAY)
    try:
        if not img_url.startswith(('http://', 'https://')):
             if img_url.startswith('//'): img_url = 'https:' + img_url
             else:
                 log_warning(f"Skipping image with invalid URL scheme: {img_url[:60]}..."); return None, None

        response = requests.get(img_url, headers=FETCH_IMAGE_HEADERS, timeout=IMAGE_TIMEOUT, stream=True)
        response.raise_for_status()
        content_type = response.headers.get('Content-Type', '').lower()
        img_data = response.content

        if not content_type.startswith('image/'):
            mime_type, _ = mimetypes.guess_type(img_url)
            if mime_type and mime_type.startswith('image/'): content_type = mime_type; log_debug(f"Guessed Content-Type: {content_type}...")
            else:
                ext = os.path.splitext(urlparse(img_url).path)[1].lower()
                mime_map = {'.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.png': 'image/png', '.gif': 'image/gif', '.webp': 'image/webp', '.svg': 'image/svg+xml'}
                if ext in mime_map: content_type = mime_map[ext]; log_debug(f"Guessed Content-Type from ext '{ext}': {content_type}...")
                else: log_warning(f"Could not determine valid image type for URL: {img_url[:60]}... Skipping."); return None, None

        log_debug(f"Image fetched ({len(img_data)} bytes, Type: {content_type})")
        return img_data, content_type
    # ... (Error handling as before) ...
    except Exception as e:
        log_warning(f"Unexpected error fetching image {img_url[:100]}...: {e}")
        return None, None

def sanitize_filename(name):
    if not isinstance(name, str): name = "Untitled"
    sanitized = re.sub(r'[\\/*?:"<>|\n\r\t\0]', '', name)
    sanitized = re.sub(r'\s+', '_', sanitized.strip())
    if not sanitized: sanitized = "Untitled"
    return sanitized[:120]

def get_main_content_area(soup):
     selectors = ['div#js_content', 'div.rich_media_content', 'div.article-content', 'section[data-role="outer"]']
     for selector in selectors:
        content_div = soup.select_one(selector)
        if content_div: log_debug(f"Found content area using selector: '{selector}'"); return content_div
     log_warning("Could not find standard content divs. Falling back to <body>."); return soup.body

def get_file_extension(content_type, url):
    ext = mimetypes.guess_extension(content_type)
    if ext:
        if ext == '.jpe': return '.jpg'
        return ext
    else:
        path = urlparse(url).path
        filename, url_ext = os.path.splitext(path)
        if url_ext and len(url_ext) < 6: return url_ext.lower()
    return '.img'

# --- Main Processing Function ---
def process_and_save(url):
    html_content = fetch_html(url)
    if not html_content: return None
    try: soup = BeautifulSoup(html_content, 'html.parser')
    except Exception as e: log_error(f"Failed to parse HTML: {e}"); return None

    title_tag = soup.select_one('h1#activity-name, h2.rich_media_title, title')
    page_title = title_tag.get_text(strip=True) if title_tag else "Untitled_WeChat_Article"
    safe_title = sanitize_filename(page_title)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    html_filename_base = f"{safe_title}_{timestamp}"
    html_filename = f"{html_filename_base}.html"
    assets_dirname = f"{html_filename_base}_files"

    try: os.makedirs(OUTPUT_DIR, exist_ok=True); log_debug(f"Output directory ensured: {OUTPUT_DIR}")
    except OSError as e: log_error(f"Cannot create output directory {OUTPUT_DIR}: {e}"); return None
    assets_fullpath = os.path.join(OUTPUT_DIR, assets_dirname)
    try: os.makedirs(assets_fullpath, exist_ok=True); log_debug(f"Assets directory created: {assets_fullpath}")
    except OSError as e: log_error(f"Cannot create assets directory {assets_fullpath}: {e}"); return None
    html_output_path = os.path.join(OUTPUT_DIR, html_filename)

    content_div = get_main_content_area(soup)
    if not content_div: log_error("Could not find content area. Aborting."); return None

    # <<< FIX: Remove hiding styles >>>
    if content_div.has_attr('style'):
        log_debug(f"Removing inline style from content_div: '{content_div['style']}'")
        del content_div['style']

    img_tags = content_div.find_all('img')
    total_imgs = len(img_tags)
    processed_count, failed_fetch_count, failed_save_count, skipped_count = 0, 0, 0, 0
    log_info(f"Found {total_imgs} images. Processing...")

    for i, img in enumerate(img_tags):
        original_src = img.get('data-src') or img.get('src')
        if not original_src or original_src.startswith('data:'): skipped_count += 1; continue
        try:
            parsed_url = urlparse(original_src)
            needs_processing = (parsed_url.netloc and parsed_url.netloc.endswith(WECHAT_IMAGE_DOMAIN)) or \
                               (not parsed_url.scheme and original_src.startswith(f'//{WECHAT_IMAGE_DOMAIN}'))
            if needs_processing:
                img_data, content_type = fetch_image_data(original_src)
                if img_data and content_type:
                    img_extension = get_file_extension(content_type, original_src)
                    img_filename = f"image_{i+1:04d}{img_extension}"
                    img_save_path = os.path.join(assets_fullpath, img_filename)
                    try:
                        with open(img_save_path, 'wb') as f_img: f_img.write(img_data)
                        relative_img_path = f"{assets_dirname}/{img_filename}"
                        img['src'] = relative_img_path
                        attrs_to_remove = ['data-src', 'data-type', 'data-w', 'data-ratio', 'style', 'class', '_width', 'wx_fmt', 'data-s', 'crossorigin', 'width', 'height', 'data-croporisrc', 'data-cropx1', 'data-cropx2', 'data-cropy1', 'data-cropy2']
                        for attr in attrs_to_remove:
                            if attr in img.attrs: del img[attr]
                        img['style'] = 'max-width: 100%; height: auto; display: block; margin: 1.2em auto; border-radius: 5px; box-shadow: 0 3px 8px rgba(0, 0, 0, 0.1); background-color: #eee;'
                        img['loading'] = 'lazy'
                        processed_count += 1
                    except IOError as e_save: log_warning(f"Failed to save image {i+1}: {e_save}"); failed_save_count += 1
                    except Exception as e_proc: log_warning(f"Error updating tag for image {i+1}: {e_proc}"); failed_save_count += 1
                else: failed_fetch_count += 1
            else: log_debug(f"Skipping non-WeChat image: {original_src[:60]}..."); skipped_count += 1
        except Exception as e_loop: log_warning(f"Error processing img tag {i+1}: {e_loop}"); skipped_count += 1

    log_info(f"Finished. {processed_count} images saved.")
    if failed_fetch_count > 0: log_warning(f"{failed_fetch_count} failed download.")
    if failed_save_count > 0: log_warning(f"{failed_save_count} failed save/update.")
    if skipped_count > 0: log_debug(f"{skipped_count} skipped.")

    final_html = f"""<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>{page_title}</title><style>body{{font-family:-apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji";line-height:1.7;padding:20px 25px;max-width:850px;margin:25px auto;background-color:#fdfdfd;color:#333;font-size:16px}}@media (max-width: 600px){{body{{padding:15px;margin:10px auto;font-size:15px}}}}img{{max-width:100%;height:auto;display:block;margin:1.5em auto;border-radius:5px;box-shadow:0 3px 8px rgba(0,0,0,.12);background-color:#eee}}p{{margin:1.2em 0}}h1, h2, h3, h4, h5, h6{{margin-top:2em;margin-bottom:.8em;line-height:1.3;font-weight:600}}h1{{font-size:1.8em}}h2{{font-size:1.5em}}h3{{font-size:1.3em}}a{{color:#007aff;text-decoration:none}}a:hover{{text-decoration:underline}}pre{{background-color:#f0f0f0;padding:10px;border-radius:4px;overflow-x:auto;white-space:pre-wrap;word-wrap:break-word}}blockquote{{border-left:3px solid #ccc;padding-left:15px;margin-left:0;color:#555;font-style:italic}}</style></head><body>{str(content_div)}</body></html>"""

    try:
        with open(html_output_path, 'w', encoding='utf-8') as f: f.write(final_html)
        print(html_output_path) # Print path last on success
        return html_output_path
    except IOError as e: log_error(f"Failed to write HTML file {html_output_path}: {e}"); return None
    except Exception as e: log_error(f"Unexpected error saving HTML: {e}"); return None

if __name__ == "__main__":
    if len(sys.argv) != 2: print(f"Usage: {os.path.basename(sys.argv[0])} <wechat_article_url>", file=sys.stderr); sys.exit(1)
    article_url = sys.argv[1]
    if not isinstance(article_url, str) or not article_url.startswith(('http://mp.weixin.qq.com/s/', 'https://mp.weixin.qq.com/s/')): log_error("Invalid WeChat URL."); sys.exit(1)
    print("Processing article (saving images locally)...", file=sys.stderr)
    result_path = process_and_save(article_url)
    if result_path: sys.exit(0)
    else: sys.exit(1)
```

**2. Bash Script (`/usr/local/bin/getwc`)**
*(Uses the venv Python, captures output correctly)*

```bash
#!/bin/bash
# Fetches WeChat article, saves HTML + local images via Python script in venv.

PYTHON_SCRIPT_PATH="$HOME/scripts/wechat_article_parser.py"
VENV_PYTHON_EXEC="$HOME/scripts/venv/bin/python3"
AUTO_OPEN_FILE=true

# --- Pre-flight Checks ---
if [ ! -f "$PYTHON_SCRIPT_PATH" ]; then echo "Error: Python script not found at $PYTHON_SCRIPT_PATH" >&2; exit 1; fi
if [ ! -x "$VENV_PYTHON_EXEC" ]; then echo "Error: Python interpreter not found at $VENV_PYTHON_EXEC. Set up venv." >&2; exit 1; fi
if [ $# -ne 1 ]; then echo "Usage: getwc \"<wechat_article_url>\"" >&2; exit 1; fi
ARTICLE_URL="$1"
if [[ ! "$ARTICLE_URL" =~ ^https?://mp\.weixin\.qq\.com/s[/?] ]]; then echo "Error: Invalid WeChat URL." >&2; exit 1; fi

# --- Execution ---
echo "🚀 Starting WeChat article download..."
echo "   URL: ${ARTICLE_URL:0:80}..."

PYTHON_OUTPUT=$("$VENV_PYTHON_EXEC" -u "$PYTHON_SCRIPT_PATH" "$ARTICLE_URL")
EXIT_CODE=$?

# --- Result Handling ---
SAVED_FILE_PATH=$(echo "$PYTHON_OUTPUT" | grep . | tail -n 1 | awk '{$1=$1};1') # Get last non-empty line, trim whitespace

if [ $EXIT_CODE -eq 0 ] && [[ "$SAVED_FILE_PATH" == /*.html ]] && [ -f "$SAVED_FILE_PATH" ]; then
  GREEN_SEP="-----------------------------------------------------"
  echo "$GREEN_SEP" | GREP_COLOR='01;32' grep --color=always . || echo "$GREEN_SEP"
  echo "✅ Success! Article saved to:"
  echo "   $SAVED_FILE_PATH"
  echo "$GREEN_SEP" | GREP_COLOR='01;32' grep --color=always . || echo "$GREEN_SEP"
  if [ "$AUTO_OPEN_FILE" = true ] ; then echo "   Opening file..."; open "$SAVED_FILE_PATH"; fi
  exit 0
else
  RED_SEP="-----------------------------------------------------"
  echo "$RED_SEP" | GREP_COLOR='01;31' grep --color=always . || echo "$RED_SEP"
  echo "❌ Error: Failed to process the article." >&2
  if [ $EXIT_CODE -ne 0 ]; then echo "   Python script error code: $EXIT_CODE." >&2; fi
  if [ $EXIT_CODE -eq 0 ]; then # If python didn't report error, find why bash failed
      if [[ ! "$SAVED_FILE_PATH" == /*.html ]]; then echo "   Could not get valid file path. Last output: '$SAVED_FILE_PATH'. Full output:\n$PYTHON_OUTPUT" >&2
      elif [ ! -f "$SAVED_FILE_PATH" ]; then echo "   File not found at reported path: $SAVED_FILE_PATH" >&2; fi
  fi
  echo "   Check Python script error messages above (stderr)." >&2
  echo "$RED_SEP" | GREP_COLOR='01;31' grep --color=always . || echo "$RED_SEP"
  exit 1
fi
```

**Setup Instructions:**

1.  Create directory: `mkdir -p ~/scripts && cd ~/scripts`
2.  Create venv: `python3 -m venv venv`
3.  Activate venv: `source venv/bin/activate`
4.  Install packages: `pip install requests beautifulsoup4`
5.  Deactivate (optional): `deactivate`
6.  Save the Python code above to `~/scripts/wechat_article_parser.py`.
7.  Save the Bash code above to `/usr/local/bin/getwc` (using `sudo nano ...`).
8.  Make Bash script executable: `sudo chmod +x /usr/local/bin/getwc`.

### Conclusion

Solving the WeChat copy-paste problem required a multi-step approach, evolving from simple ideas to a more complex but robust local script. We tackled Base64 bloat, CSS visibility issues, and Python packaging best practices. While the final step of integrating the *local* copy into a *web* platform like Discourse still requires a manual touch (dragging images), the core `getwc` tool now reliably archives WeChat articles locally, preserving content, images, and basic formatting for offline reading or further processing.

Remember to always respect copyright when handling content created by others. Happy archiving!

---

</details>    
    

發完召喚 Grok 3，沒被搭理。懷疑是因為剛剛放出來，和論壇數據格式還不兼容。  
拉 Gemini 2.5 深度分析是什麼寫法引發了問題，答案一般。  

其實，之所以跟這個帖子，提這個問題；還是因為教材，或者某些文學作品。  
這週在讀「荷花淀」，這個單元還有那篇反人性的「黨費」，論文筆清秀，孫犁筆墨確乎足夠；但把戰場寫成武俠風，要說和今天抗日神劇沒關係，也難。  
所以一直和學生說，該看看「鬼子來了」，這片子和這類片子不能上映一天，這民族下一次遭遇外敵入境，就依舊大概率還是被蹂躪多年。  
神劇不能成就真的愛國者，漢奸倒是一定可以培養出來很多。  
反思劇或文學，概率更大些；也許。  

其實，真正的點從來在於；可以荷花，也能武俠，但不能只有；教材，尤甚。

孫犁拼命咬牙克制自己痛罵教材編者瞎改自己文章，現在讀來，就更弔詭。  
沒錯，太多時刻，即便「荷花淀」的寫法，還是有當局者不滿意的；就這類當局主事的生物，但有國難，需要幾秒就可以搖身一變成為敗類新主事？  
放心，沒幾秒的。  
還記得前文的牆嗎，這類一直騎著呢。
嗯。