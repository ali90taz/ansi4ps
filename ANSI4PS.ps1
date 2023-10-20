
# ANSI4PS by Alisson dos Santos - Version 1.1.0

function printText {
    Param (
        [Parameter()] [string] $T,
        [Parameter()] $FC,
        [Parameter()] $BC,
        [Parameter()] [string] $FS,
        [Parameter()] [string] $TA
    )   
    [string] $ansiCode = ''
    function ansiEscape { 
        return "$([char]27)" + "[" 
    }
    function resetAnsi { 
       return ansiEscape + "0m" 
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
    function applyTextAnimation ([string] $aniFlags, [ref][string] $ansiCodeRef) {
        $ansiCodeRef.Value += "5"
    }
    function applyForegroundColor ($color, [ref][string] $ansiCodeRef) {
        if ($ansiCodeRef.Value -match "[\[]{1}$") {
            $ansiCodeRef.Value += "3" + (psColorToAnsiColor $color)
        } else {
            $ansiCodeRef.Value += ";3" + (psColorToAnsiColor $color)
        }
    }
    function applyBackgroundColor ($color, [ref][string] $ansiCodeRef) {
        if ($ansiCodeRef.Value -match "[\[]{1}$") {
            $ansiCodeRef.Value += "4" + (psColorToAnsiColor $color)
        } else {
            $ansiCodeRef.Value += ";4" + (psColorToAnsiColor $color)
        }
    }
    function applyFontStyle ([string] $styleFlags, [ref][string] $ansiCodeRef) {

        $bold = '1'
        $italic = '3'
        $underline = '4'
        $strikethrough = '9'

        if ($styleFlags -match "b") {
            if ($ansiCodeRef.Value -match "[\[]{1}$") {
                $ansiCodeRef.Value += $bold
            } else {
                $ansiCodeRef.Value += ";" + $bold
            }
        }
        if ($styleFlags -match "i") {
            if ($ansiCodeRef.Value -match "[\[]{1}$") {
                $ansiCodeRef.Value += $italic
            } else {
                $ansiCodeRef.Value += ";" + $italic
            }
        }
        if ($styleFlags -match "u") {
            if ($ansiCodeRef.Value -match "[\[]{1}$") {
                $ansiCodeRef.Value += $underline
            } else {
                $ansiCodeRef.Value += ";" + $underline
            }
        }
        if ($styleFlags -match "s") {
            if ($ansiCodeRef.Value -match "[\[]{1}$") {
                $ansiCodeRef.Value += $strikethrough
            } else {
                $ansiCodeRef.Value += ";" + $strikethrough
            }
        }
    }
    function applyText ([string] $text, [ref][string] $ansiCodeRef) {
        $ansiCodeRef.Value += 'm' + $text
    }
    function parseArguments ([ref][string] $ansiCodeRef){
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

            # This extremely complex piece of REGEX was
            # taken and adapted from the following link:
            # https://stackoverflow.com/posts/46964463/revisions
            # My current knowledge does not allow me to understand how it works

            if ($FS -match "^(?!.*(.).*\1)[b|i|u|s]+$") {
                return $true
            }
            return $false
        }
        if ($T) {

            $ansiCodeRef.Value = ansiEscape

            if (checkTextAnimation) {
                applyTextAnimation $TA ($ansiCodeRef)
            }
            if (checkForegroundColor) {
                applyForegroundColor $FC ($ansiCodeRef)
            }
            if (checkBackgroundColor) {
                applyBackgroundColor $BC ($ansiCodeRef)
            }
            if (checkFontStyle) {
                applyFontStyle $FS ($ansiCodeRef)
            }

            applyText $T ($ansiCodeRef)
            return $true
        }
        return $false
    }
    if (parseArguments ([ref] $ansiCode)) {
        
        Write-Host $ansiCode
        resetAnsi
    }
}