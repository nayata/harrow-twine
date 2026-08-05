import harrow.Library;
import harrow.Story;

class Parser {
	public static function get(storydata:js.html.Element):Story {
		var entry = "";
		var start = "";

		// Get 'startnode' id value
		var startnode = storydata.getAttribute('startnode');
		var passages = storydata.children;


		// Iterate through the passages
		for (passage in passages) {
			var name = passage.getAttribute("name");
			var pid = passage.getAttribute("pid");

			if (name != null) {
				// Add Route from Passage name
				entry += "#" + name + "\n";

				// Get 'Story' start
				if (pid == startnode) start = name;

				// Parse Passage
				var content = passage.innerHTML.split("\n");

				for (line in content) {
					// Replace Twine links
					var string = StringTools.trim(line);
									
					var lead = string.substring(0, 1);
					var link = string.substring(0, 2);
					
					if (lead == "-") {
						string = StringTools.replace(string, "[[", "");
						string = StringTools.replace(string, "]]", "");
					}
					if (link == "[[") {
						string = StringTools.replace(string, "[[", "");
						string = StringTools.replace(string, "]]", "");
						string = "[move " + string + "]";
					}
					if (link == "::") {
						string = StringTools.replace(string, "::", "#");
					}

					// Fix 'greater-than/less-than' sign
					string = StringTools.replace(string, "&lt;", "<");
					string = StringTools.replace(string, "&gt;", ">");

					entry += string + "\n";
				}
			}
		}


		// harrow.Story from Twine storydata
		var story = Library.get(entry);

		// Move 'Story.page' to StoryData 'start' value
		story.move(start);

		// Return harrow.Story.
		return story;
	}
}