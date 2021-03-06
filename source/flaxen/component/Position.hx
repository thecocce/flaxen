package flaxen.component;

import ash.signals.Signal1;

class Position
{
	public var signal:Signal1<Position>;
	private var _x:Float;
	private var _y:Float;
	public var x(get,set):Float;
	public var y(get,set):Float;

	public function new(x:Float, y:Float)
	{
		signal = new Signal1<Position>();
		this._x = x;
		this._y = y;
	}

	public function subtract(x:Float, y:Float): Position
	{
		return add(-x, -y);
	}

	public function add(x:Float, y:Float): Position
	{
		this.x += x;
		this.y += y;
		return this;
	}

	public function copy(pos:Position): Position
	{
		this.x = pos.x;
		this.y = pos.y;
		return this;
	}

	public function clone(): Position
	{
		return new Position(x, y);
	}

	public function matches(o:Position): Bool
	{
		if(o == null)
			return false;
		return (o.x == x && o.y == y);
	}

	public static function safeClone(o:Position): Position
	{
		return (o == null ? null : o.clone());
	}

	public static function match(o1:Position, o2:Position): Bool
	{
		if(o1 == o2)
			return true;
		if(o1 == null)
			return false;
		return (o1.matches(o2));
	}	

	// Returns an angle between this point and another point, degrees, 0 north
	public function getAngleTo(pos:Position): Float
	{
	  	var theta = Math.atan2(pos.y - y, pos.x - x);
	    theta += Math.PI / 2.0;
	    var angle = theta * 180 / Math.PI;
	    return (angle < 0 ? angle + 360 : angle);
	}

	public function getDistanceTo(pos:Position): Float
	{
		var dx = pos.x - x;
		var dy = pos.y - y;
		return Math.sqrt(dx * dx + dy * dy);
	}

	// Accessors added for basic signalling. Not really happy to put this in a generic component.
	public function set_x(x:Float): Float
	{
		this._x = x;
		signal.dispatch(this);
		return _x;
	}

	public function set_y(y:Float): Float
	{
		this._y = y;
		signal.dispatch(this);
		return _y;
	}

	public function set(x:Float, y:Float)
	{
		this._x = x;
		this._y = y;
		signal.dispatch(this);
	}

	public function get_x(): Float
	{
		return _x;
	}

	public function get_y(): Float
	{
		return _y;
	}

	public function toString(): String
	{
		return x + "," + y;
	}

	//
	// Some convenience methods
	//

	public static inline function zero(): Position
	{
		return topLeft();
	}

	public static inline function topLeft(): Position
	{
		return new Position(0, 0);
	}

	public static inline function top(): Position
	{
		return new Position(com.haxepunk.HXP.halfWidth, 0);
	}

	public static inline function topRight(): Position
	{
		return new Position(com.haxepunk.HXP.width, 0);
	}

	public static inline function left(): Position
	{
		return new Position(0, com.haxepunk.HXP.halfHeight);
	}

	public static inline function center(): Position
	{
		return new Position(com.haxepunk.HXP.halfWidth, com.haxepunk.HXP.halfHeight);
	}

	public static inline function right(): Position
	{
		return new Position(com.haxepunk.HXP.height, com.haxepunk.HXP.halfHeight);
	}

	public static inline function bottomLeft(): Position
	{
		return new Position(0, com.haxepunk.HXP.height);
	}

	public static inline function bottom(): Position
	{
		return new Position(com.haxepunk.HXP.halfWidth, com.haxepunk.HXP.height);
	}

	public static inline function bottomRight(): Position
	{
		return new Position(com.haxepunk.HXP.width, com.haxepunk.HXP.height);
	}
}