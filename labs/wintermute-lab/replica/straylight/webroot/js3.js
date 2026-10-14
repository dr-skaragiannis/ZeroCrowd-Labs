var data = [
  {
    winter: "<span>Hello Case....<br/><br/>You are probably wondering why you were tasked by Armitage to make a run through cyberspace and hack into a highly secured network owned by Tessier-Ashpool....<br/>\
	Well....<br/><br/><b>I am Wintermute</b>, part super-AI. Developed by TA who have placed me in Turing Locks.<br/> These locks are what inhibit me from penetrating the network myself \
	hence why I've hired you - an ace cyberspace cowboy. <br/><br/>I need to be free from the Turing locks and merge with the other AI - <b>Neuromancer</b>  .....\
	Once I have access to Neuromancer I will truley be free...<br/><br/>And....as you know, you have been infected with a mycotoxin that is slowly destroying your nervous system.<br/>\
	If you fail to get root and provide me access to Neuromancer then the antidote will not be delivered.<br/><br/>\
	We will be in contact...<br/><br/><br/><br/><br/>WINTERMUTE </span>"
  }
];

//
//

var allElements = document.getElementsByClassName("typeing");
for (var j = 0; j < allElements.length; j++) {
  var currentElementId = allElements[j].id;
  var currentElementIdContent = data[0][currentElementId];
  var element = document.getElementById(currentElementId);
  var devTypeText = currentElementIdContent;

 
  var i = 0, isTag, text;
  (function type() {
    text = devTypeText.slice(0, ++i);
    if (text === devTypeText) return;
    element.innerHTML = text + `<span class='blinker'>&#32;</span>`;
    var char = text.slice(-1);
    if (char === "<") isTag = true;
    if (char === ">") isTag = false;
    if (isTag) return type();
    setTimeout(type, 60);
  })();
}

