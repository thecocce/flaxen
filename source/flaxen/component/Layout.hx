package flaxen.component;

// A layout can be used in addition to position to establish the 0,0 point
// Changing a layout would then move (as a group) all entities using that layout.

enum Orientation { Landscape; Portrait; }

class Layout
{
	public var name:String;
	public var current:Position;
	public var portrait:Position;
	public var landscape:Position;
	public var orientation:Orientation;

	public function new(name:String, portrait:Position, landscape:Position)
	{
		this.name = name;
		this.portrait = portrait;
		this.current = this.landscape = landscape;
		this.orientation = Landscape;
	}

	// You must call setOrientation
	public function setOrientation(orientation:Orientation, ?offset:Position)
	{
		current = (orientation == Portrait ? portrait : landscape);
		if(offset != null)
			current = current.clone().add(offset.x, offset.y);
	}
}