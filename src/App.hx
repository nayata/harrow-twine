import harrow.Dialogue;
import harrow.Library;
import harrow.Runtime;
import harrow.Storage;
import harrow.Format;
import harrow.Story;
import harrow.Choice;
import harrow.Logic;
import harrow.Page;

import js.Browser.document;
import js.Browser.window;
import js.html.Element;


@:expose
class App {
	public static var ME:App;

	public var novel:Runtime;
	public var story:Story;

	var cover:Element;
	var start:Element;
	var transition:Element;
	var imagebox:Element;
	var dialogue:Element;
	var textbox:Element;
	var button:Element;

	var settings:Settings;

	var location:Array<Int> = [];
	var bookmark:Int = -1;

	var buffer:Buffer;


	static function main() {
		ME = new App();
	}

	
	public function new() {
		// Macro to build Twine `format.js` in `dist` folder
		BuildFormat.run();
		
		buffer = new Buffer();

		harrow.Syntax.custom = customSyntax;
		harrow.Random.dice = Dice.roll;

		var storydata = document.querySelector('tw-storydata');

		story = Parser.get(storydata);
		novel = new Runtime(story);

		novel.onText = onText;
		novel.onDialogue = onDialogue;
		novel.onTransition = onTransition;
		novel.onEvent = onEvent;
		novel.onClose = onEnd;
		novel.onEnd = onEnd;

		cover = document.querySelector('cover');
		start = document.querySelector('start');
		transition = document.querySelector('transition');
		imagebox = document.querySelector("imagebox");
		dialogue = document.querySelector('dialogue');
		textbox = document.querySelector('textbox');
		button = document.querySelector('continue');

		button.textContent = "Continue";
		button.setAttribute("role", "button");
		button.style.display = 'none';
		button.onclick = function(event) {
			onClick();
		}

		// Story Title
		document.querySelector('chapter').innerHTML = storydata.getAttribute('name');

		// Twine user style
		var style = document.createElement('style');
		style.innerHTML = document.querySelector('#twine-user-stylesheet').innerHTML;
		document.querySelector('body').appendChild(style);

		// Twine user script
		var script = document.createElement('script');
		script.innerHTML = document.querySelector('#twine-user-script').innerHTML;
		document.querySelector('body').appendChild(script);

		// Story Title and Author
		var passage = document.querySelector('tw-passagedata[name="StoryAuthor"]');
		
		document.querySelector('author').innerHTML = passage != null ? passage.innerHTML : "Story by Author";
		document.querySelector('name').innerHTML = storydata.getAttribute('name');

		// Settings
		settings = new Settings(story, storydata);

		document.querySelector('close').onclick = function(event) {
			settings.close();
		}
		document.querySelector('open').onclick = function(event) {
			settings.open();
		}
		
		// Title page
		document.querySelector('page').id = "title";
		start.onclick = function(event) {
			document.querySelector('page').removeAttribute("id");
			novel.nextPage();
		}
	}


	// `Continue` button event
	function onClick() {
		button.style.display = 'none';
		textbox.innerHTML = '';
		novel.nextPage();
	}


	// Show button and text
	function showText() {
		button.style.display = 'block';
		fade(textbox);
	}


	// Show text or add text to buffer
	function onText(text:String, name:String) {
		var speaker = name != "" ? '<span class = "speaker">' + name + '</span>' : "";
		var element = name != "" ? '<p class = "' + name + '">' : '<p>';

		if (!Config.speaker &&  name != "") speaker = name + ": ";

		textbox.innerHTML += buffer.get();

		if (currentFillRatio() > Config.maxHeight) {
			buffer.set(element + speaker + text + '</p>');
			showText();
			return;
		}

		textbox.innerHTML += element + speaker + text + '</p>';

		var full = currentFillRatio() > Config.maxHeight;
		var next = novel.story.look(novel.story.page + 1);
		var last = next == null;

		if (last) showText();
		if (last) return;

		if (full && next.type == Page.DIALOGUE) novel.nextPage();
		if (full && next.type != Page.DIALOGUE) showText();

		if (full) return;

		var allowed = (next.type == Page.TEXT || next.type == Page.DIALOGUE || next.type == Page.EVENT);

		if (next.type == Page.EVENT) {
			if (next.data == "return") allowed = false;
			if (next.data == "scene") allowed = false;
		}

		if (allowed) novel.nextPage();
		if (!allowed) showText();
	}


	function currentFillRatio():Float {
		var visibleHeight = textbox.clientHeight;

		var last = textbox.lastElementChild;
		var contentHeight = last != null ? last.offsetTop + last.offsetHeight : 0;

		return Math.min(100, contentHeight / visibleHeight * 100);
	}


	// Show dialogue choices
	function onDialogue(choices:Array<Choice>) {
		if (buffer.full()) textbox.innerHTML = buffer.get();

		fade(textbox);

		dialogue.removeAttribute("id");
		if (choices.length > Config.maxVertical) dialogue.id = "horizontal";

		for (entry in choices) {
			var choice = document.createElement("choice");
			choice.setAttribute("role", "button");
			choice.innerHTML = Format.variable(entry.text);

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

		if (type == "route" && data != "return") story.move(data);
		if (data == "return" && bookmark != -1) story.turn(bookmark);
		if (type == "variable") Logic.variable(data);
		
		novel.nextPage();
	}


	// Events
	function onEvent(type:String, data:String) {
		switch (type) {
			case "config.parse.speaker": 
				Config.speaker = data == "true";
			case "config.text.fill": 
				Config.maxHeight = Std.parseInt(data);
			case "config.dialogue.vertical": 
				Config.maxVertical = Std.parseInt(data);
			case "config.settings.title": 
				Config.settings = data;
			case "config.text.end":
				Config.endText = data;
			case "config.assets.folder": 
				Config.folder = data;

			case "bookmark":
				bookmark = data == "clear" ? -1 : story.page - 1;
			case "return":
				if (bookmark != -1) story.turn(bookmark);

			case "scene": 
				sceneEvent(data);
			case "image": 
				imageEvent(data);

			case "dice":
				buffer.set(Render.dice(data));
			case "stat": 
				buffer.set(Render.stat(data));
			case "bar": 
				buffer.set(Render.bar(data));

			default:
		}
	}


	// Scene's emulation
	function sceneEvent(data:String) {
		if (data == "close") {
			var page = location.pop();
			if (page != null) story.turn(page);
		}
		else if (data == "clear") {
			location = [];
		}
		else {
			location.push(story.page);
			story.move(data);
		}
	}


	// Imagebox [image command/source]
	function imageEvent(data:String) {
		if (data == "show") {
			document.querySelector('page').className = "novel";
			imagebox.style.display = 'block';
		}
		else if (data == "hide") {
			document.querySelector('page').removeAttribute("class");
			imagebox.style.display = 'none';
		}
		else {
			document.querySelector('page').className = "novel";

			imagebox.style.backgroundImage = "url('" + Config.folder + data + "')";
			imagebox.style.display = 'block';

			fade(imagebox);
		}
	}


	static function fade(element:Element, duration:Int = 300, from:Float = 0, to:Float = 1) {
		element.style.transition = 'none';
		element.style.opacity = Std.string(from);
		element.getBoundingClientRect();
		element.style.transition = 'opacity ${duration}ms';
		element.style.opacity = Std.string(to);
	}


	// Transition
	function onTransition(name:String) {
		function hide() {
			transition.style.zIndex = "-1";
		}
		function fade() {
			transition.className = "hidden";

			haxe.Timer.delay(hide, 600);
			novel.nextPage();
		}

		transition.style.zIndex = "600";
		transition.className = "active";

		haxe.Timer.delay(fade, 900);
	}


	// Called on story end or on [close]
	function onEnd() {
		buffer.clear(); 
		textbox.innerHTML = Config.endText;
		fade(textbox);

		button.textContent = "Restart";
		button.style.display = 'block';
		button.onclick = function(event) {
			window.location.reload();
		}
	}


	function customSyntax(page:Page, entry:String) {
		if (page.type == Page.TEXT) {
			if (page.data == '<img src="https' || page.data == '<img src="http') {
				page.text = page.data + ":" + page.text;
				page.data = "";
			}
		}
	}
}