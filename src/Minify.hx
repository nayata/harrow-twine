class Minify {
	public static function run(entry:String):String {
		entry = ~/\/\*[\s\S]*?\*\//g.replace(entry, "");
		entry = ~/\s+/g.replace(entry, " ");
		return StringTools.trim(entry);
	}
}