class Buffer {
	var content:String = "";

	public function new() {}

	public function full():Bool {
		return content.length > 0;
	}
	public function get():String {
		var result = content;
		content = "";
		return result;
	}
	public function set(text:String) {
		content = content + text;
	}
	public function clear() {
		content = "";
	}
}