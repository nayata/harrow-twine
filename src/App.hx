import harrow.Dialogue;
import harrow.Library;
import harrow.Runtime;
import harrow.Storage;
import harrow.Story;
import harrow.Choice;
import harrow.Logic;
import harrow.Page;

import js.Browser.document;
import js.html.Element;
import js.jquery.JQuery;


@:expose
class App {
	public static var ME:App;

	public var novel:Runtime;
	public var story:Story;

	var textbox:Element;
	var dialogue:Element;
	var button:Element;

	var bookmark:Array<Int> = [];

	var parsespeaker:Bool = false;
	var maxlenght:Int = 240;
	var buffer:String = "";
	var folder:String = "";


	static function main() {
		ME = new App();
	}

	
	public function new() {
		// Macro to build Twine `format.js` in `dist` folder
		BuildFormat.run();
		
		var dice = new Dice();
		harrow.Random.dice = dice.roll;

		var storydata = document.querySelector('tw-storydata');

		story = Parser.get(storydata);
		novel = new Runtime(story);

		novel.onText = onText;
		novel.onDialogue = onDialogue;
		novel.onTransition = onTransition;
		novel.onEvent = onEvent;
		novel.onEnd = onEnd;

		textbox = document.querySelector('textbox');
		dialogue = document.querySelector('dialogue');
		button = document.querySelector('button');

		button.textContent = "Continue";
		button.style.display = 'none';
		button.onclick = function(event) {
			onClick();
		}

		// Story Title
		document.querySelector('chapter').innerHTML = storydata.getAttribute('name');

		// Settings buttons
		document.querySelector('close').onclick = function(event) {
			close();
		}
		document.querySelector('open').onclick = function(event) {
			open('Settings');
		}

		// Twine user style
		var style = document.createElement('style');
		style.innerHTML = document.querySelector('#twine-user-stylesheet').innerHTML;
		document.querySelector('body').appendChild(style);

		// Twine user script
		var script = document.createElement('script');
		script.innerHTML = document.querySelector('#twine-user-script').innerHTML;
		document.querySelector('body').appendChild(script);

		novel.nextPage();
	}


	// `Continue` button event
	function onClick() {
		button.style.display = 'none';
		novel.nextPage();
	}


	// Show text stored in buffer
	function showText() {
		textbox.innerHTML = buffer;
		buffer = "";

		textbox.style.opacity = "0";
		new JQuery(textbox).fadeTo(300, 1);
	}


	// Add text to buffer or show text if buffer length is > then maxlenght
	function onText(text:String, name:String) {
		var speaker = name != "" ? '<span class = "speaker">' + name + '</span>' : "";
		var element = name != "" ? '<p class = "' + name + '">' : '<p>';

		if (!parsespeaker &&  name != "") speaker = name + ": "; // Fix for already parsed speaker

		buffer = buffer + element + speaker + decode(text) + '</p>';

		var ready = buffer.length > maxlenght;
		var page = novel.story.look(novel.story.page + 1);
		var last = page == null;

		if (last) {
			button.style.display = 'block';
			showText();
		}

		if (last) return;

		if (page.type == Page.DIALOGUE && ready) {
			novel.nextPage();
		}
		if (page.type != Page.DIALOGUE && ready) {
			button.style.display = 'block';
			showText();
		}

		if (ready) return;

		if (page.type == Page.TEXT || page.type == Page.DIALOGUE) {
			novel.nextPage();
		}
		else {
			button.style.display = 'block';
			showText();
		}
	}


	// Show dialogue choices
	function onDialogue(choices:Array<Choice>) {
		if (buffer.length > 0) showText();

		for (entry in choices) {
			var choice = document.createElement("choice");
			choice.setAttribute("role", "button");
			choice.innerHTML = format(entry.text);

			var allowed = entry.mode == "empty" ? true : Logic.condition(entry.mode);
			if (!allowed) choice.className = "disabled";
			
			choice.onclick = function(event) {
				onSelect(entry.type, entry.data);
			}
			dialogue.appendChild(choice);
		}
	}


	// Send dialogue selected choice to Runtime
	function onSelect(type:String, data:String) {
		dialogue.innerHTML = "";
		textbox.innerHTML = "";

		novel.onChoice(type, data);
	}


	// Events
	function onEvent(type:String, data:String) {
		switch (type) {
			case "config.parse.speaker": 
				parsespeaker = data == "true";
			case "config.text.maxlenght": 
				maxlenght = Std.parseInt(data);
			case "config.assets.folder": 
				folder = data;
			case "scene": 
				sceneEvent(data);
			case "image": 
				imageEvent(data);
			default:
				screenEvent(type, data);
		}
	}


	// Scene's emulation
	function sceneEvent(data:String) {
		if (data == "close") {
			var page = bookmark.pop();
			if (page != null) story.turn(page);
		}
		else if (data == "clear") {
			bookmark = [];
		}
		else {
			bookmark.push(story.page);
			story.move(data);
		}
	}


	// Imagebox quick access: [image name] instead of [imagebox image name]
	function imageEvent(data:String) {
		var element = document.querySelector("imagebox");

		if (data == "show") {
			document.querySelector('page').className = "novel";
			element.style.display = 'block';
		}
		else if (data == "hide") {
			document.querySelector('page').removeAttribute("class");
			element.style.display = 'none';
		}
		else {
			document.querySelector('page').className = "novel";
			element.style.display = 'block';

			element.style.backgroundImage = "url('" + folder + decode(data) + "')";
			element.style.opacity = "0";
			new JQuery(element).fadeTo(300, 1);
		}
	}


	// Woking with 'html' elements
	function screenEvent(name:String, data:String) {
		var entry = data.split(":");

		var type = entry.shift();
		var text = entry.join(" ");

		var element = document.querySelector(name);
		if (element == null) return;

		text = decode(text);

		switch (type) {
			case "add": 
				var item = document.createElement(text);
				element.appendChild(item);
			case "append":
				element.innerHTML = element.innerHTML + format(text);
			case "before": 
				var item = document.createElement(text);
				element.parentNode.insertBefore(item, element);
			case "after": 
				var item = document.createElement(text);
				element.parentNode.insertBefore(item, element.nextSibling);
			case "onclick": 
				element.setAttribute("onclick", format(text));
			case "hide": 
				element.style.display = 'none';
			case "show": 
				element.style.display = 'block';
			case "class": 
				element.setAttribute("class", text);
				if (text == "default") element.removeAttribute("class");
			case "id": 
				element.setAttribute("id", text);
				if (text == "default") element.removeAttribute("id");
			case "html": 
				element.innerHTML = text == "empty" ? "" : format(text);
			case "text": 
				element.textContent = text == "empty" ? "" : format(text);
			case "css": 
				var position = text.indexOf(' ');
				var prop = text.substring(0, position);
				var data = text.substring(position + 1, text.length);
				element.style.setProperty(prop, data);
			case "image": 
				element.style.backgroundImage = "url('" + folder + text + "')";
				element.style.opacity = "0";
				new JQuery(element).fadeTo(300, 1);
			case "remove": 
				element.parentNode.removeChild(element);
			default:
		}
	}


	// Transition
	function onTransition(name:String) {
		function hide() {
			var transition = document.querySelector('transition');
			transition.style.zIndex = "-1";
		}
		function fade() {
			var transition = document.querySelector('transition');
			transition.className = "off";

			haxe.Timer.delay(hide, 600);
			novel.nextPage();
		}

		var transition = document.querySelector('transition');
		transition.style.zIndex = "600";
		transition.className = "active";

		haxe.Timer.delay(fade, 900);
	}


	function onEnd() {
		textbox.innerHTML = "<p>Story End.</p>";
		new JQuery(textbox).fadeTo(300, 1);
	}


	// Open specific route in 'Settings' screen
	public function open(name:String) {
		var page = story.find(Page.ROUTE, name);
		if (page == null) return;

		var skip = false;
		var string = '';

		page = page + 1;

		for (i in page...story.data.length) {
			if (story.data[i].type == Page.ROUTE) break;
			if (story.data[i].type == Page.CONDITION) {
				if (skip && story.data[i].text == "else" || skip && story.data[i].text == "end") {
					skip = false;
				}
				else {
					skip = !Logic.condition(story.data[i].text);
				}
			}

			if (skip) continue;

			if (story.data[i].type == Page.TEXT) {
				var speaker = story.data[i].data;
				var element = speaker != "" ? '<p class = "' + speaker + '">' : '<p>';

				string = string + element + story.data[i].text + '</p>';
			}
			if (story.data[i].type == Page.EVENT) {
				var element = StringTools.replace(story.data[i].text, ":", " ");

				element = story.data[i].data + " " + decode(element);
				element = format(element);

				string = string + element;
			}
		}

		document.querySelector('close').style.zIndex = "400";

		var element = document.querySelector('settings');
		element.innerHTML = '<content>' + string + '</content>';
		element.setAttribute("class", name.toLowerCase());
		element.style.display = 'grid';
		element.style.zIndex = "300";
		element.style.opacity = "1";
	}


	// Close 'Settings' screen
	public function close() {
		document.querySelector('close').style.zIndex = "-1";

		var element = document.querySelector('settings');
		element.removeAttribute("class");
		element.style.display = 'none';
		element.style.opacity = "0";
		element.style.zIndex = "-1";
	}


	// Get variable value from `harrow.Storage`
	public function get(key:String):String {
		return Storage.get(key);
	}


	// Set variable to `harrow.Storage`
	public function set(key:String, value:String) {
		Storage.set(key, value);
	}


	// HTML colon fix
	function decode(entry:String):String {
		entry = StringTools.replace(entry, "https ", "https:");
		entry = StringTools.replace(entry, "http ", "http:");
		return entry;
	}


	// HTML variables
	function format(entry:String):String {
		if (entry.indexOf("$") == -1) return entry;

		var rex:EReg = ~/\$\S+?(?=[^a-zA-Z.]|$)/g;
		entry = rex.map(entry, function(r) {
			var matching = r.matched(0);
			var variable = matching.substring(1, matching.length);

			if (Storage.has(variable)) return Storage.get(variable);
			return matching;
		});

		return entry;
	}
}