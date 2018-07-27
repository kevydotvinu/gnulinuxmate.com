---
title: Pandoc - Simple Text to PDF Conversion
subtitle: Think about converting a simple text-file to mail-ready PDF document
share-img: /img/pandoc.png
tags: [Tools, Commands]
image: /img/pandoc.png
---

**Although we do have rich-text editors, we do not really need those, which comes heavy, to write a simple letter and save it as PDF file. Moreover, some people like to work in terminal to make their work distraction-free (Yes, The complete Game of Thrones book was written with VIM text editor). Here, I am using VIM and PANDOC to do that job.**  

Pandoc is a simple command-line interface (CLI) tool which converts text to PDF, not only `.txt` files, but also `.html`, `.md` and more. First of all, we are using VIM to write the content and `:wq!` to save it. Pandoc uses `-i` to source the file and `-o` to output the file.  
For example,

>pandoc -i file.txt -o file.pdf  

In addition, pandoc can read Markdown format to enhance output.

`Bold **text**`  
`Italics *text*`  
`Quote >text`  
`Image [imageName](path)`  
`Link [text](link)`  
`Title %text`

You must be wondering why do we need to learn all these to write a simple letter and why did I put the word simple in this blog title. But trust me, it'd worth learning. Markdown format will be very useful in many websites. Last but not least, I have added [here](/kevydotvinu.github.io/img/pandoc.pdf) the pdf copy of this post to get convinced.
