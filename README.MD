## ANSI4PS 

This is my own implementation of the ANSI standard for PowerShell, it allows you to very conveniently print texts in PowerShell using up to 8 different colors for the text and background, as well as allowing you to add Italic, Bold, Underline and Strikethrough, and more... check out.

## How to add to my script?

To add it is simple, just include this file to your Powershell script, place this script in the same folder as your script and paste the following line into it:

> . .\ANSI4PS.ps1

It's done, now you can access the printText function in the ANSI4PS.ps1 file.

## How to use?

There is only one function in this file called printText, I chose this approach to not generate unnecessary complexity, below you can see which options this function accepts.

*printText* *-T* <any_string> *-FC* <foreground_color> *-BC* <background_color> *-FS* <font_style> *-TA* <text_animation> *-F* <flag_1, flag2, ...>

*-T* means (T)ext and accepts string values, example: *'foo_bar'* or *"foo_bar"*

*-FC* means (F)oreground (C)olor and accepts color names, example: *White*, *Red*, *Black*.

The possible values is:

- *Black*
- *Red*
- *Green*
- *Yellow*
- *Blue*
- *Magenta*
- *Cyan*
- *White*

*-BC* means (B)ackground (C)olor and accepts color names, example: *Cyan*, *Blue*, *Green*.

The possible values is:

- *Black*
- *Red*
- *Green*
- *Yellow*
- *Blue*
- *Magenta*
- *Cyan*
- *White*

*-FS* means (F)ont (S)tyle and accepts four letter flags enclosed by quotation marks, example: "bius", "i", "us".

You can use all values at same time or use single or two or three, in any order.

The possible values is:

- *"b"* - Bold font.
- *"i"* - Italic font.
- *"u"* - Underline font.
- *"s"* - Strikethrough font.

Any other value is not accepted.

*-TA* means (T)ext (A)nimation and accepts words enclosed by quotation marks, example: "blink", "fade".

For now the possible values is:

- *"blink"* - Blinks text.

*-F* means (F)lags and accepts words enclosed by quotation marks, example: "nnl", "rv", "rst".

For now the possible values is:

- *"rv"* - Reverse text, minor issues, experimental feature.
- *"rst"* - Resets ANSI parameters.
- *"nnl"* - No new line mode, subsequent text does not go to the next line.

### Changelog

[Link](https://github.com/ali90taz/ansi4ps/blob/master/CHANGELOG.TXT)

### License

[MIT](https://opensource.org/licenses/MIT) Copyright (C) 2023 ali90taz

