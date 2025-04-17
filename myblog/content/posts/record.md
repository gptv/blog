+++
date = "2025-04-12T11:02:00+08:00"
draft = false
title = "狂飆、黑鏡"
slug = "re"
layout = "single"
type = "blog"
+++

黑鏡第七季，前兩天出來就想週末看完。現在是周六上午11點，還沒開看。  
因為這週 Google 和 Cloudflare 整出了太多新功能，要知道和要看的都明顯超負載。  
不得不先更新下 GPT 日常任務的指令：

![Screenshot 2025-04-11 at 18.04.52.png (20250411001)](https://img.bdfz.net/20250411001.webp)

說到底，靠日常刷 X，實在看不過來了；也相信愈後來，愈跟不住。  
這不是壞消息。  

把 AI 說成 A1 是笑點，但就算 A1 是牛排，也就是個段子，教育領域缺笑話嗎？哪國也不缺。  
所以，論壇裡發 Linda McMahon 帖子就是玩。

但前幾天發 Andrej Karpathy 的新文章「Power to the people: How LLMs flip the script on technology diffusion」，看他樂觀且開心地說： 
 > Remember that William Gibson quote “The future is already here, it’s just not evenly distributed”? Surprise - the future is already here, and it is shockingly distributed. Power to the people. Personally, I love it.

這真不是玩，其時腦子裡一直想的，是「A Sound of Thunder」裡一波一波浪潮，改換地球樣貌的情節。  

上午把一眼看到就確定必讀的「Welcome to the Era of Experience」看完，AI 翻譯給學生，論壇置頂。  
關鍵語句，是：
> if an agent had been trained to reason using
human thoughts and expert answers from 5,000 years ago it may have reasoned about a physical problem in
terms of animism; 1,000 years ago it may have reasoned in theistic terms; 300 years ago it may have reasoned
in terms of Newtonian mechanics; and 50 years ago in terms of quantum mechanics.

人類語言的邊界，這個例子足夠透徹了。  
而從 The Era of Human Data 到 The Era of Experience，少數人類，還必須更用心用力。  
反正，人類一直都在顛覆自己。 

置頂後，突然想，怎麼讓更多學生看呢？  
那當然是加功利了。  
畢竟，再席捲文明的浪潮，人也可以不感興趣。  

所以，開玩。  
* 核對翻譯好的中文作為數據
* 提取近三年高考非連文本作為命題模式，讓 gemini-2.5-pro-preview-03-25 直接給出一道高仿高考非連題
* 將題目數據導入| <a href="https://gk.bdfz.net" target="_blank">AI高考</a> 🦁 |網站
* 發希悅通知學生來做9999年題：

![Screenshot 2025-04-11 at 19.10.10.png (20250411002)](https://img.bdfz.net/20250411002.webp)

這個模式跑通，作業這種事情，就徹底升級了。  
雖然，我依舊不認為語文是一個需要作業的學科。  

確保學生看通知的遊戲怎麼玩？當然是希悅直接發全部默寫分數了。😉 

更新了希悅考勤腳本中一個關閉窗口的錯誤代碼，一眼不細就要多一次重審，合理。把考勤結果加入了 tele 通知；現在可以徹底放手了。  
更新了論壇備份數據腳本，數據越來越大，加斷點續傳，加 vps 和本機，本機和雲盤之間 md5 校驗；此後，從下載到上傳，只要 tele 不出特殊報錯，也可以放手了。  
更新了幾個教學網站後端 worker 代碼，運行一周正常，加入幾個教學網站域名限制，可以放手一段了，也。

還是沒想好怎麼處理 <a href="https://mx.bdfz.net" target="_blank">AI默寫</a> 🐽 ，從數據到流程的邏輯都需要更多時間一點點考量清楚。
先放。  

萬物狂飆，偶爾駐足。  
12:02，黑鏡下完，開始。  






