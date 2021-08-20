# How to Translate Khronos

## First Things First

* Fork the repository here on github with the Fork button at the top-right
* Clone this repository by opening the terminal in a folder of your choice and typing `git clone https://github.com/<you_username>/khronos`

## Basics

* You'll need to know your language's code (ex. en = English).
* Add that code to the LINGUAS file, in a new line, after the last line.
* Translate the .pot file using the PO editor of your choice (I recommend POEdit).
* Save it as <language_code>.po in this folder.

## Not so Basics

* Next, in the folder you've cloned this repo in, open a terminal and type: ```git checkout -b "Translation <language code>```
* Then, type ```git add *```
* Finally, ```git commit -m "Translated your app for <Language Name>" && git push```, follow the instructions in the terminal if need be, then type your github username and password.

And that's it! You've successfully translated Khronos for your language!
