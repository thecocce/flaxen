package flaxen.render;

import flaxen.component.Text;
import flaxen.component.Alpha;
import flaxen.component.Size;
import flaxen.render.FancyText;
import flash.text.TextFormatAlign;

class TextView extends View
{
	private var curWidth:Int = 0;
	private var curHeight:Int = 0;
	private var curMessage:String;
	private var curStyle:TextStyle;
	private var display:FancyText;

	override public function begin()
	{
		nodeUpdate();
	}

	// Create or update text object
	private function setText(forceNew:Bool)
	{
		// Create new text
		if(graphic == null || forceNew || curStyle.changed)
		{
			// TODO Support ScrollFactor
			graphic = display = new FancyText(curMessage, 0, 0, curStyle.size, curStyle.color, 
				curStyle.font, curWidth, curHeight, Std.string(curStyle.alignment), 
				curStyle.wordWrap, 1, curStyle.leading, curStyle.shadowOffset, curStyle.shadowColor); 
			curStyle.changed = false;			
		}

		// Update text message
		else display.setString(curMessage);
	}

	override public function nodeUpdate()
	{
		super.nodeUpdate();

		if(hasComponent(Text))
		{
			var text:Text = getComponent(Text);
			var updateDisplay = false;
			var forceNew = false;

			// Check for style change, provide style default
			var style = text.style;
			if(style == null)
				style = new TextStyle(0xFFFFFF, 14, com.haxepunk.HXP.defaultFont);
			if(style != curStyle || style.changed)
			{
				curStyle = style;
				updateDisplay = true;
			}

			// Check for text area dimensions change
			if(hasComponent(Size))
			{
				var size:Size = getComponent(Size);
				var sw = Math.round(size.width);
				var sh = Math.round(size.height);
				if(sw != curWidth || sh != curHeight)
				{
					curWidth = sw;
					curHeight = sh;
					updateDisplay = true;
					forceNew = true;
				}
			}
			else curWidth = curHeight = 0;

			// Check for text message change
			if(text.message != curMessage)
			{
				curMessage = text.message;
				updateDisplay = true;
			}
			else curMessage = "";

			// If any changes, update text object
			if(updateDisplay)
				setText(forceNew);

			// Update alpha/transparency
			if(hasComponent(Alpha))
			{
				var alpha:Float = getComponent(Alpha).value;
				if(alpha != display.getAlpha())
					display.setAlpha(alpha);
			}
		}
		else if(display != null)
		{
			display = null;
			return;
		}
	}
}