return unless window.console and window.console.log

log = ->
    args = []

    makeArray(arguments).forEach (arg) ->
        if typeof arg is 'string'
            args = args.concat stringToArgs arg

        else
            args.push arg

    _log.apply window, args

_log = ->
    console.log.apply console, makeArray(arguments)

window.__defineGetter__ "clear", ->
	  clear()

makeArray = (arrayLikeThing) ->
    Array::slice.call arrayLikeThing

formats = [{
    # Italic
    regex: /\*(.*)\*/
    replacer: (m, p1) -> "%c#{p1}%c"
    styles: -> ['font-style: italic', '']
}, {
    # Bold
    regex: /\_(.*)\_/
    replacer: (m, p1) -> "%c#{p1}%c"
    styles: -> ['font-weight: bold', '']
}, {
    # Code
    regex: /\`(.*)\`/
    replacer: (m, p1) -> "%c#{p1}%c"
    styles: -> ['background: rgb(255, 255, 219); padding: 1px 5px; border: 1px solid rgba(0, 0, 0, 0.1)', '']
}, {
    # Custom syntax: [c="color: red"]red[c]
    # this is [c=color: red]red[c]
    regex: /\[c\=([\"\']*)(.*)\1\](.*)\[c\]/
    replacer: (m, p2, p3) -> "%c#{p3}%c"
    styles: (match) -> [match[2], '']
}]

hasMatches = (str) ->
    _hasMatches = false

    formats.forEach (format) ->
        if format.regex.test str
            _hasMatches = true

    return _hasMatches

getOrderedMatches = (str) ->
    matches = []

    formats.forEach (format) ->
        match = str.match format.regex
        if match
            matches.push
                format: format
                match: match

    return matches.sort((a, b) -> a.match.index - b.match.index)

stringToArgs = (str) ->
    styles = []

    while hasMatches str
        matches = getOrderedMatches str
        firstMatch = matches[0]
        str = str.replace firstMatch.format.regex, firstMatch.format.replacer
        styles = styles.concat firstMatch.format.styles(firstMatch.match)

    [str].concat styles

# TODO - replace these with a feature test
isSafari = -> /Safari/.test(navigator.userAgent) and /Apple Computer/.test(navigator.vendor)
isIE = -> /MSIE/.test(navigator.userAgent)

# Safari starting supporting stylized logs in Nightly 537.38+
# See https://github.com/adamschwartz/log/issues/6
safariSupport = ->
    m = navigator.userAgent.match /AppleWebKit\/(\d+)\.(\d+)(\.|\+|\s)/
    return false unless m
    return 537.38 >= parseInt(m[1], 10) + (parseInt(m[2], 10) / 100)

# Export
if (isSafari() and not safariSupport()) or isIE()
    window.log = _log
else
    window.log = log
window.log.l = _log
