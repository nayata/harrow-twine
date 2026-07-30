import harrow.Storage;

class Render {
	public static function dice(name:String):String {
		var value = Std.parseFloat(Storage.get(name));

		if (Math.isNaN(value)) return '';
		
		return '<dice><face></face><value>${value}</value></dice>';
	}

	public static function stat(name:String):String {
		var value = Std.parseFloat(Storage.get(name));

		if (Math.isNaN(value)) return '';

		var upper = name.charAt(0).toUpperCase() + name.substr(1);
		var label = upper.split(".").shift();
		
		return '<stat><bar><fill style="width:${value}%"></fill></bar><label>${label}: ${value}%</label></stat>';
	}

	public static function bar(name:String):String {
		var label = Storage.get(name + ".label");
		
		if (label == null) {
			label = name.charAt(0).toUpperCase() + name.substr(1);
			label = label.split(".").shift();
		}

		var value = Std.parseFloat(Storage.get(name));
		var total = Std.parseFloat(Storage.get(name + ".max"));
		
		if (Math.isNaN(value)) return '';
		if (Math.isNaN(total) || total <= 0) total = 100;

		var percent = (value / total) * 100;

		return '<stat><bar><fill style="width:${percent}%"></fill></bar><label>${label}: ${value}/${total}</label></stat>';
	}
}