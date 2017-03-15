'use strict'

function scrollToAnchor(hash) {
        location.hash = "#" + hash
}

window.onload = function() {
    
        var foreignWordRegExp = /\w[-'\w]*\w/

        function prepareForSpeech(html) {
                return html.replace(/<\/*span.*?>/gi, '').replace(/<br>/gi, '\n')
        }

        var article = document.getElementsByTagName('article')[0]
        if (article) {
                article.onclick = function(ev) {

                        function allForeignTextClick() {
                                var s = window.getSelection()
                                var range = s.getRangeAt(0)
                                var node = s.anchorNode
                                var nodeLength = node.textContent.length

                                while (range.startOffset > 0 && range.toString().indexOf(' ') !== 0) {
                                        range.setStart(node, range.startOffset - 1)
                                }

                                if (range.toString().indexOf(' ') === 0) {
                                        range.setStart(node, range.startOffset + 1)
                                }

                                while (range.endOffset < nodeLength && range.toString().indexOf(' ') === -1) {
                                        range.setEnd(node, range.endOffset + 1)
                                }

                                var word = range.toString().trim()
                                var match = word.match(foreignWordRegExp)
                                if (match) {
                                        word = match[0]
                                }
                                webkit.messageHandlers.wordClick.postMessage(word + "|" + word)
                        }

                        function mixedTextClick() {
                                var targetElement = ev.target
                                if (targetElement.tagName === 'SPAN') {
                                        ev.preventDefault()
                                        ev.stopPropagation()
                                        var word = targetElement.innerText.trim()
                                        webkit.messageHandlers.wordClick.postMessage(word + "|" + targetElement.parentElement.innerText)
                                }
                        }

                        var isForeignText = document.getElementById("foreign-text")
                        if (isForeignText) {
                                allForeignTextClick()
                        } else {
                                mixedTextClick()
                        }
                }
        }
}
