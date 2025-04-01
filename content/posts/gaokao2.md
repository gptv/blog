+++
date = "2025-03-27T00:30:00+08:00"
draft = false
title = "AI高考2.0"
slug = "aigaokao"
layout = "single"
type = "blog"
link = "aigaokao"
tags = ["AI", "真題","高考"]
+++

昨天在 <a href="https://bdfz.net/posts/gaokao/" target="_blank">AI高考</a>  一文說：  
>“整理數據這事，估計要等到今年九月才可能完成。  
> 畢竟，一個人，有限。”

然後，今天完成！  

X上我發文說了：
>啊啊啊啊啊啊啊啊啊啊啊啊啊！  
>因為模型效果不好，我昨天手動清洗這個數據中的一部分，一小時清洗完非連⋯⋯  
>今天，Gemini 2.5 Pro Experimental 03-25 模型，用 10 幾分鐘，把我計劃到今年九月才可能整理完的數據，清洗完了！

這就很⋯⋯神！  
一直盯著屏幕上每年的數據審閱，整個處理過程，比我自己要周密。  
當然，也是因為這次我以2024年為範例，徹底重構了各題目 JSON 化的基本邏輯，然後，寫了一個超級複雜的指令。  

![](https://pbs.twimg.com/media/Gm92y_LbkAAHFJJ?format=jpg&name=4096x4096)

原本擔心模型會做不出，還想拆分任務；但又轉念，雖然過於複雜又何妨一試，做不出來再簡化任務就好。結果⋯⋯低估模型了，效果是真的嚇人。  
中間斷開三次，要求繼續，就直接繼續了。  
Token count ： 333,554/1,048,576。

那，精進之！上傳新 data 數據，改代碼邏輯，將微寫作大作文指令一併寫入。替換下之前 <a href="https://kz.bdfz.net" target="_blank">AI論語</a> / <a href="https://hlm.bdfz.net" target="_blank">AI紅樓夢</a> 。哦，還有默寫網站：<a href="https://mf.bdfz.net" target="_blank">高考默寫</a>  。  
這兩個高考訓練網頁原本就是備考用，本該獨立。  
那麼。完工。

現在的效果是，每一年的所有題目，都已經錄入可見。  
任何一個北京考生，都可以隨時：  
* 刷歷年真題的各類型歷年全部題目。
* 寫作文給 AI 批閱。
* 和 AI 深度對談每一道題目。 

後續完善人類參考答案進去，就是純體力活了。  
嗯。  

---

更新匯聚：

><a href="https://bdfz.net/posts/gaokao" target="_blank">AI高考1.0</a>   
><a href="https://bdfz.net/posts/aigaokao" target="_blank">AI高考2.0</a>   
><a href="https://bdfz.net/posts/aigaokao2" target="_blank">AI高考3.0</a> 