import harrow.Storage;
import harrow.Format;
import harrow.Story;
import harrow.Logic;
import harrow.Page;

import js.Browser.document;
import js.Browser.window;
import js.html.Element;


class Settings {
	var story:Story;
	var list:Array<String> = [];

	var fontSizeNames:Array<String> = ["Default", "Large", "Small"];
	var fontSizeValues:Array<String> = ["1em", "1.3em", "0.85em"];
	var fontSizeIndex:Int = 0;
	
	var fontFamilyNames:Array<String> = ["Default", "Serif"];
	var fontFamilyValues:Array<String> = ["sans-serif", "serif"];
	var fontFamilyIndex:Int = 0;

	var themeNames:Array<String>  = ["Light", "Dark"];
	var themeValues:Array<String> = ["light", "dark"];
	var themeIndex:Int = 0;
	
	var sizeLabel:Element;
	var familyLabel:Element;
	var themeLabel:Element;

	var settings:Element;
	var textbox:Element;


	public function new(entry:Story, data:Element) {
		story = entry;

		// Get body default font
		fontFamilyValues[0] = window.getComputedStyle(document.body).fontFamily;

		// Navigation
		for (passage in data.children) {
			var tags = passage.getAttribute("tags");
			if (tags == "menu") list.push(passage.getAttribute("name"));
		}
		if (list.length > 0) list.push("Settings");

		settings = document.querySelector('settings');
		textbox = document.querySelector('textbox');
	}
	
	function changeFontSize() {
		fontSizeIndex = (fontSizeIndex + 1) % fontSizeNames.length;
		textbox.style.fontSize = fontSizeValues[fontSizeIndex];
		updateSettingsLabels();
	}
	
	function changeFontFamily() {
		fontFamilyIndex = (fontFamilyIndex + 1) % fontFamilyNames.length;
		document.body.style.fontFamily = fontFamilyValues[fontFamilyIndex];
		updateSettingsLabels();
	}

	function changeTheme() {
		themeIndex = (themeIndex + 1) % themeNames.length;
		document.documentElement.setAttribute("data-theme", themeValues[themeIndex]);
		updateSettingsLabels();
	}
	
	function updateSettingsLabels() {
		sizeLabel.textContent = 'Font Size: ' + fontSizeNames[fontSizeIndex];
		familyLabel.textContent = 'Font Family: ' + fontFamilyNames[fontFamilyIndex];
		themeLabel.textContent = 'Theme: ' + themeNames[themeIndex];
	}

	public function open() {
		document.querySelector('close').style.zIndex = "400";

		settings.innerHTML = '<header>' + Config.settings + '</header>';

		var menu = document.createElement("navigation");
		settings.appendChild(menu);

		var text = document.createElement('textbox');
		text.className = "information";
		settings.appendChild(text);

		var tabs:Array<Element> = [];

		for (entry in list) {
			var tab = document.createElement("div");
			tab.className = "tab";
			tab.innerHTML = entry;
			tabs.push(tab);
			
			tab.onclick = function(event) {
				if (entry == "Settings") getDefault(text);
				if (entry != "Settings") text.innerHTML = getRoute(entry);

				for (t in tabs) t.className = "tab";
				tab.className = "tab active";
			}
			menu.appendChild(tab);
		}

		if (list.length == 0) getDefault(text);
		if (list.length != 0) text.innerHTML = getRoute(list[0]);
		if (tabs.length != 0) tabs[0].className = "tab active";

		settings.style.display = 'grid';
		settings.style.zIndex = "300";
		settings.style.opacity = "1";
	}
	
	public function close() {
		document.querySelector('close').style.zIndex = "-1";

		settings.removeAttribute("class");
		settings.style.display = 'none';
		settings.style.opacity = "0";
		settings.style.zIndex = "-1";
	}

	// Default Settings screen
	public function getDefault(element:Element) {
		element.innerHTML = "";

		var letter = document.createElement("letter");
		letter.textContent = "A";
	
		var status = document.createElement("status");

		sizeLabel = document.createElement("size");
		sizeLabel.textContent = 'Font Size: ' + fontSizeNames[fontSizeIndex];
		sizeLabel.onclick = function(event) { changeFontSize(); }
	
		familyLabel = document.createElement("family");
		familyLabel.textContent = 'Font Family: ' + fontFamilyNames[fontFamilyIndex];
		familyLabel.onclick = function(event) { changeFontFamily(); }
	
		themeLabel = document.createElement("theme");
		themeLabel.textContent = 'Theme: ' + themeNames[themeIndex];
		themeLabel.onclick = function(e) { changeTheme(); }
	
		status.appendChild(sizeLabel);
		status.appendChild(familyLabel);
		status.appendChild(themeLabel);

		var divider = document.createElement("divider");
		var menu = document.createElement("menu");

		var restartItem = document.createElement("item");
		restartItem.textContent = "Restart the Game";
		restartItem.onclick = function(event) { window.location.reload(); }

		var returnItem = document.createElement("item");
		returnItem.textContent = "Return";
		returnItem.onclick = function(event) { close(); }
		
		menu.appendChild(restartItem);
		menu.appendChild(returnItem);
	
		element.appendChild(letter);
		element.appendChild(status);
		element.appendChild(divider);
		element.appendChild(menu);
	}


	// Get content from specific route
	function getRoute(name:String):String {
		var route = story.find(Page.ROUTE, name);
		if (route == null) return "";
	
		var string = "";
		var hidden:Null<Int> = null;
		var depth = 0;
		
		route = route + 1;
	
		for (i in route...story.data.length) {
			var page = story.data[i];
	
			if (page.type == Page.ROUTE) break;
	
			if (page.type == Page.CONDITION) {
				if (page.data == "if") {
					depth++;
					if (hidden == null && !Logic.condition(page.text)) {
						hidden = depth;
					}
				}
				else if (page.text == "else") {
					if (hidden == depth) hidden = null;
					else if (hidden == null) hidden = depth;
				}
				else if (page.text == "end") {
					if (hidden == depth) hidden = null;
					depth--;
				}
			}
	
			if (hidden != null) continue;
	
			if (page.type == Page.TEXT) {
				var speaker = page.data != "" ? '<span class="speaker">' + page.data + '</span>' : "";
				var element = page.data != "" ? '<p class="' + page.data + '">' : '<p>';
	
				if (!Config.speaker && page.data != "") speaker = page.data + ": ";
	
				string = string + element + speaker + Format.variable(page.text) + '</p>';
			}
			if (page.type == Page.EVENT) {
				if (page.data == "stat") string = string + Render.stat(page.text);
				if (page.data == "bar") string = string + Render.bar(page.text);
			}
		}
	
		return string;
	}
}