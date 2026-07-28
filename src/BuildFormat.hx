import haxe.macro.Context;
import haxe.Json;

class BuildFormat {
	public static macro function run() {
		var style = Minify.run(sys.io.File.getContent("main.css"));
		var novel = sys.io.File.getContent("novel.js");

		var source = sys.io.File.getContent("format.html");

		source = StringTools.replace(source, "{{CSS}}", style);
		source = StringTools.replace(source, "{{JS}}", novel);

		var string = Json.stringify(source);

		var format = sys.io.File.getContent("format.js");
		format = StringTools.replace(format, '"{{SOURCE}}"', string);
		
		sys.io.File.saveContent("dist/format.js", format);

		return macro {};
	}
}