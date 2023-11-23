
# ANSI4PS by Alisson dos Santos - Version 1.2.4b

$Global:refBuffer = @{}

function printText {

    <#
        .SYNOPSIS 
            Prints the text in PowerShell console using the ANSI engine.
        .PARAMETER T
            Specifies the text string.
        .PARAMETER URT
            Specifies the new text for reference.
        .PARAMETER RF
            Specifies the reference name.
        .PARAMETER FC
            Specifies the foreground color, valid for the text and reference text.
        .PARAMETER BC
            Specifies the background color, valid for the text and reference text.
        .PARAMETER FS
            Specifies the font style, valid for the text and reference text.
        .PARAMETER TA
            Specifies the animation, valid for the text and reference text.
        .PARAMETER F
            Specifies the flags.        
    #>

    Param (
        [Parameter()][Alias("Text", "String")][string] $T,
        [Parameter()][Alias("UpdateReferenceText", "ReferenceText")][string] $URT,
        [Parameter()][Alias("ReferenceName")][string] $RF,
        [Parameter()][Alias("ForegroundColor", "Color")] $FC,
        [Parameter()][Alias("BackgroundColor")] $BC,
        [Parameter()][Alias("FontStyle")][string] $FS,
        [Parameter()][Alias("TextAnimation", "Animation")][string] $TA,
        [Parameter()][Alias("Flags")][string[]] $F
    )
  
    enum Flags {

        RESET_ANSI
        REVERSE_VIDEO
        NO_NEW_LINE
        DEBUG
        CLEAR_BUFFER
        WITH_REFERENCES
    }

    function getFlag ($flag) {
        switch ($flag) {
            ([Flags]::RESET_ANSI) { return "rst" }
            ([Flags]::REVERSE_VIDEO) { return "rv" }
            ([Flags]::NO_NEW_LINE) { return "nnl" }
            ([Flags]::DEBUG) { return "dbg" }
            ([Flags]::CLEAR_BUFFER) { return "clb" }
            ([Flags]::WITH_REFERENCES) { return "wr" }
        }
    }

    [string] $debugHeader = "ANSI4PS DEBUG MODE"
    [string] $Global:ansiCode = ''
    $Global:validExpressions = New-Object System.Collections.Generic.List[System.Object]
    $Global:validExpressionsIndex = New-Object System.Collections.Generic.List[System.Object]
    [bool] $Global:allExpressionsMatch = $false
    $Global:validExpressionsLength = New-Object System.Collections.Generic.List[System.Object]
    $errorLog = New-Object System.Collections.Generic.List[System.Object]
    $warningLog = New-Object System.Collections.Generic.List[System.Object]
    $messageLog = New-Object System.Collections.Generic.List[System.Object]
    [string] $refName = "refName"
    [string] $refValue = "refValue"
    [string] $refIndex = "refIndex"
    [string] $refLength = "refLength"
    [string] $ansiEscape = "$([char]27)" + "["
    [bool] $Global:referencesReady = $false

    function addError ($err) {

    }

    function addWarning ($warn) {

    }

    function addMessage ($msg) {

    }

    function showError ([string[]] $err) {
        if (parseFlags (getFlag ([Flags]::DEBUG))) {
            Write-Host -ForegroundColor Red ("Error: " + $err)
        }
    }

    function showWarning ([string[]] $warn) {
        if (parseFlags (getFlag ([Flags]::DEBUG))) {
            Write-Host -ForegroundColor Yellow ("Warning: " + $warn)
        }
    }

    function showMessage ([string[]] $msg) {
        if (parseFlags (getFlag ([Flags]::DEBUG))) {
            Write-Host -ForegroundColor White ("Message: " + $msg)
        }
    }

    function psColorToAnsiColor ($psColor) {
       
        switch ($psColor) {
            Black   { return "0" }
            Red     { return "1" }
            Green   { return "2" }
            Yellow  { return "3" }
            Blue    { return "4" }
            Magenta { return "5" }
            Cyan    { return "6" }
            White   { return "7" }
            default { return "9" }
        }
    }

    function parseFlags ([string[]] $flags) { 

        function checkFlag ([string] $flag) {
            
            $i = 0
            $match = $false

            [Enum]::GetValues('Flags').ForEach({
                if ((getFlag ([Flags].GetEnumName($i))) -eq $flag) {
                    $match  = $true
                }
                ++$i
            })
            if ($match) {
                return $true
            } else {
                return $false
            } 
        }
        
        if ($F.Count -eq 0) {
            return $false
        }

        if ($F.Count -gt 1) {
            
            $i = 0

            $F.ForEach({
                if (checkFlag $F[$i]) {
                    ++$i
                }
                return $false
            })

            $i = 0
            $match = 0

            $flags.ForEach({
                if ($F -contains $flags[$i]) {
                    ++$match
                }
                ++$i
            })

            if ($match -eq $flags.Count) {
                return $true
            } else {
                return $false
            }
        }

        if (checkFlag $F[0]) {
            if ($flags -contains $F[0]) {
                return $true
            } else {
                return $false
            }
        }
    }

    function applyTextAnimation ([string] $aniFlags) {
        $Global:ansiCode += "5"
    }

    function applyForegroundColor ($color) {
        if ($Global:ansiCode -match "[\[]{1}$") {
            $Global:ansiCode += "3" + (psColorToAnsiColor $color)
        } else {
            $Global:ansiCode += ";3" + (psColorToAnsiColor $color)
        }
    }

    function applyBackgroundColor ($color) {
        if ($Global:ansiCode -match "[\[]{1}$") {
            $Global:ansiCode += "4" + (psColorToAnsiColor $color)
        } else {
            $Global:ansiCode += ";4" + (psColorToAnsiColor $color)
        }
    }

    function applyFontStyle ([string] $styleFlags) {
        
        $bold = '1'
        $italic = '3'
        $underline = '4'
        $reverse = '7'
        $strikethrough = '9'

        if ($styleFlags -match "b") {
            if ($Global:ansiCode -match "[\[]{1}$") {
                $Global:ansiCode += $bold
            } else {
                $Global:ansiCode += ";" + $bold
            }
        }

        if ($styleFlags -match "i") {
            if ($global:ansiCode -match "[\[]{1}$") {
                $global:ansiCode += $italic
            } else {
                $global:ansiCode += ";" + $italic
            }
        }

        if ($styleFlags -match "u") {
            if ($global:ansiCode -match "[\[]{1}$") {
                $global:ansiCode += $underline
            } else {
                $global:ansiCode += ";" + $underline
            }
        }

        if ($styleFlags -match "s") {
            if ($global:ansiCode -match "[\[]{1}$") {
                $global:ansiCode += $strikethrough
            } else {
                $global:ansiCode += ";" + $strikethrough
            }
        }

        if (parseFlags (getFlag ([Flags]::REVERSE_VIDEO))) {
            if ($global:ansiCode -match "[\[]{1}$") {
                $global:ansiCode += $reverse
            } else {
                $global:ansiCode += ";" + $reverse
            }
        }
    }

    function applyText ([string] $text, [ref][string] $global:ansiCode) {

        if ($referencesReady) {

            $expressionPattern = "(?:(%\()([^\d][\s|\w]+),([\s|\d]+)(\)))"
            $expressionsMatches = [regex]::Matches($T, $expressionPattern)
            $i = 0

            $expressionsMatches.ForEach({
                
            })
        } else {
            $global:ansiCode += 'm' + $text
        }

        if (parseFlags (getFlag ([Flags]::RESET_ANSI))) {
            $global:ansiCode += $ansiEscape + "m"
        }

        if (parseFlags (getFlag ([Flags]::NO_NEW_LINE))) {
            Write-Host -NoNewline $Global:ansiCode
        } else {
            Write-Host $Global:ansiCode
        }
    }

    function addExpressions {        
        
        $expressionPattern = "^(?<$($refName)>[^\d]\w+),(?<$($refValue)>\d+)$"
        $expressionData
        $refData = @{}
        $i = 0

        foreach ($expression in $validExpressions) {

        # https://devblogs.microsoft.com/scripting/regular-expressions-regex-grouping-regex/
        # After hours of research I found how get the value of a regex group
        # using only the name, but the crucial detail for
        # work is to use [0] the index selector in the result without this
        # doesn't work, I only discovered this in this link because all
        # others do not show this.

            $expressionData = [Regex]::Matches($expression, $expressionPattern)
            $refData.Add($refValue, $expressionData[0].Groups[$refValue].Value)
            $refData.Add($refIndex, $validExpressionsIndex[$i])
            $refData.Add($refLength, $validExpressionsLength[$i])
            $Global:refBuffer.Add($expressionData[0].Groups[$refName].Value, $refData)
            ++$i
        }
        $Global:referencesReady = $true
    }

    function parseArguments {
        function checkTextAnimation {
            if ($TA -match "^(Blink)$") {
                return $true
            }
            return $false
        }
                             
         function checkForegroundColor {
            if ($FC -match "^(Black|Red|Green|Yellow|Blue|Magenta|Cyan|White)$") {
                return $true
            }
            return $false
        }

        function checkBackgroundColor {
            if ($BC -match "^(Black|Red|Green|Yellow|Blue|Magenta|Cyan|White)$") {
                return $true
            }
            return $false
        }

        function checkFontStyle {

            # https://stackoverflow.com/posts/46964463/revisions

            if ($FS -match "^(?!.*(.).*\1)[b|i|u|s]+$") {
                return $true
            }
            return $false
        }

        function checkExpressions {
            
            # https://powershellone.wordpress.com/2021/02/24/using-powershell-and-regex-to-extract-text-between-delimiters/

            $weakPattern = "(?<=%\().+?(?=\))"
            $syntaxPattern = "^([^\d][\w]+,[\d]+)"
            $expressions = [regex]::Matches($T, $weakPattern)
            $match = 0
            $i = 0

            function trimSpaces ($str) {
                $tmp = $str.replace(' ', '')
                return $tmp
            }

            if($expressions.Count) {

                $Global:validExpressions = ("." * $expressions.Count)

                foreach ($expression in $expressions){
                    if ((trimSpaces $expression.Value) -match $syntaxPattern) {
                        $Global:validExpressions.Add((trimSpaces $expression.Value))
                        $Global:validExpressionsIndex.Add(($expression.Index - 2))  # 2 meaning "%(" chars
                        $Global:validExpressionsLength.Add(($expression.Value.Length + 3)) # 3 meaning "%()" chars
                        ++$match
                        ++$i
                    } else {
                        Write-Host ("Invalid expression in the text: " + (trimSpaces $expression.Value))
                    }
                }
                if ($match -eq $expressions.Count) {
                    $Global:allExpressionsMatch = $true
                    return $true
                } else {
                    $Global:allExpressionsMatch = $false
                    return $false
                }
            } else {
                return $false
            }
        }

        if (($T.Length -gt 0) -and ($URT.Length -eq 0)) {

            $global:ansiCode = $ansiEscape
            
            if (parseFlags (getFlag ([Flags]::WITH_REFERENCES))) {
                
                if (checkExpressions) {
                    addExpressions
                }

                if ($allExpressionsMatch) {
                    if (checkTextAnimation) {
                        applyTextAnimation $TA
                    }
                    if (checkForegroundColor) {
                        applyForegroundColor $FC
                    }
                    if (checkBackgroundColor) {
                        applyBackgroundColor $BC
                    }
                    if (checkFontStyle) {
                        applyFontStyle $FS
                    }
        
                    applyText $T
                }
            }

            if ((parseFlags (getFlag ([Flags]::WITH_REFERENCES))) -eq $false) {
                
                if (checkTextAnimation) {
                    applyTextAnimation $TA
                }
                if (checkForegroundColor) {
                    applyForegroundColor $FC
                }
                if (checkBackgroundColor) {
                    applyBackgroundColor $BC
                }
                if (checkFontStyle) {
                    applyFontStyle $FS
                }
    
                applyText $T
            }           
        }

        if (($URT.Length -gt 0) -and ($T.Length -eq 0)) {

        }

        if ($T -and $URT) {
            addWarning "The parameters 'T' and 'URT' should be not used at same time."
        }

        if (parseFlags (getFlag ([Flags]::CLEAR_BUFFER))) {
            Clear-Variable -Name refBuffer -Scope Global
            addMessage "The refBuffer it's cleared successfully."
        }
    }

    parseArguments
    
    if (parseFlags (getFlag ([Flags]::DEBUG))) {
        Clear-Host
        Write-Host -ForegroundColor Cyan ($debugHeader + "`n`n")
        showError $errorLog
        showWarning $warningLog
        showMessage $messageLog
    }
}

printText -T "Installing electron... %( electronProgress, 4 ) %( nodeProgress, 7 )" -F "wr"
