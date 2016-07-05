'use strict';

function scrollToAnchor(hash) {
	location.hash = "#" + hash;
}

window.onload = function() {

	function prepareForSpeech(html) {
		return html.replace(/<\/*span.*?>/gi, '').replace(/<br>/gi, '\n');
	}

	var article = document.getElementsByTagName('article')[0];
	if (article) {
		article.onclick = function(ev) {
			var word;
			var text;
			var targetElement = ev.target;
			if (targetElement.tagName === 'SPAN') {
				ev.preventDefault();
				ev.stopPropagation();
                word = targetElement.innerText.trim();
                webkit.messageHandlers.wordClick.postMessage(word + "|" + targetElement.parentElement.innerText)
			}
		};
	}
}

