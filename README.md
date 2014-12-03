#Flaxen
Flaxen is a Haxe 3 project that combines a game engine ([HaxePunk](https://github.com/HaxePunk/HaxePunk)) with an entity component system ([Ash-Haxe](https://github.com/nadako/Ash-HaXe)). 

##Overview
Flaxen started as base code I just used for game jams; pardon the dust as I try to make this more useful.

###Ash
In a typical ECS (entity component system), you create entities to represent any kind of game object, whether it represent an on-screen game entity or any kind of ad-hoc data you'd like to manipulate in an ECS model. To make the entities do things, first you add components to the entities. Components are simple objects that define the characteristics (behaviors/states) of the entity they belong to. Then you build systems, which process groups of entities that contain some specific set of components, observe changes in these components, and respond appropriately. A common example is movement: give an entity Position and Velocity components, and create a MovementSystem that looks for entities having both of these components (this is the Ash concept of a "node"); for each such entity found, the system updates the Position component based on the values in the Velocity component. For more information about ECS and Ash in particular, here's a [good overview](http://www.richardlord.net/blog/why-use-an-entity-framework) by Richard Lord, the author of original Ash.

###HaxePunk
HaxePunk is a game library that provides a number of useful constructs. It can be used on its own, separate from Flaxen; visit the [HaxePunk website](http://HaxePunk.com). You don't need to know HaxePunk to use Flaxen (although it can help). Flaxen provides built-in components that abstract access to Image, Text, Backdrop, Emitter, Tilemap and Spritemap. Additional HaxePunk objects are available that Flaxen does not support.

###Flaxen
Flaxen wraps a HaxePunk engine and provides an interface to manipulate Ash entities. Built-in components like Image, Layer and Position can be added to entities, and built-in nodes and systems like the RenderingSystem maps these entities to their HaxePunk counterparts. Flaxen also provides its own HaxePunk scene.

##Install Flaxen
Flaxen is not currently in the haxelib library. To install it from github:

```bash
haxelib git flaxen https://github.com/scriptorum/flaxen
```

It requires Haxe 3 and has dependencies on [OpenFL](http://www.openfl.org/documentation/getting-started/installing-openfl/), [HaxePunk](https://github.com/HaxePunk/HaxePunk) and [Ash-Haxe](https://github.com/nadako/Ash-HaXe). Install those libraries. You go do that.

##How to Use It
Here's some meager information to get you started! Most of this I typed up without testing it, so that makes me a rotten person.

###Create Flaxen
Subclassing Flaxen is the recommended method to initialize it.

```haxe
class MyFlaxenApp extends Flaxen
{
	public static function main()
	{
		new MyFlaxenApp();
	}

	override public function ready()
	{
		// Setup here...
	}
}
```

###Entities and Components

You can create a new named entity with newSingleton. This entity will be added to Ash.

```haxe
newSingleton("mySingleton");
```

Quite often you won't care about the name, so use newEntity. You could also supply a string which will be used to prefix the autogenerated name, which makes it easier when debugging.

```haxe
var e1 = newEntity();
var e2 = newEntity("obj"); // e.g., returns entity named obj1 
```

You can retrieve a named entity in a few ways:

```haxe
e = getEntity("moon"); // returns entity if found or null
e = demandEntity("moon"); // returns entity if found or logs error
e = resolveEntity("moon"); // returns entity, if not found creates it
```

Ash entities can have components added to them immediately: 

```haxe
var e = newEntity().add(new Compo1()).add(new Compo2());
e.add(precreatedComponentInstance);
```

You can get components from entities a number of ways:

```haxe
c = e.get(Compo1);
c = getComponent("moon", Compo1);
c = demandComponent("moon", Compo1);
```

Components are removed through the Ash entity: 

```haxe
e.remove(Compo1);
```

And entities are removed a few ways:
```haxe
ash.removeEntity("moon"); // The ash object is public, go nuts
removeEntity("moon"); // returns true if removed, false if not found
demandRemoveEntity("moon"); // Log error not found, otherwise remove
```

###Showing an Image
Here's a simple image. The whole source image is centered on the screen. The entity is given a middle offset (instead of an upper-left corner), which the RenderingSystem takes into account when positioning the Image. Offset is not required to show a simple image, but Image and Position are. Under the hood this creates a HaxePunk Image.

```haxe
var e:Entity = newEntity()
	.add(new Image("art/flaxen.png"))
	.add(Position.center())
	.add(Offset.center());
```

To show part of an image, say a sprite on a sprite sheet, you could add a clipping region to the image:

```haxe
var image = new Image("art/flaxen.png", new Rectangle(0,0,50,50));
e.add(image);
```

Or more simply you could add a Tile and an ImageGrid. The number of tiles across and down are calculated at run-time based on the image dimensions and ImageGrid size. Yes, ImageGrid should really be called CellSize or something. Don't you think I know it's poorly named? I'm the one who named it! Hmph! Uh ... where was I? Oh yes:

```haxe
var e:Entity = newEntity()
	.add(new Image("art/tiles.png"))
	.add(Position.center())
	.add(Offset.center())
	.add(new ImageGrid(50, 50))
	.add(new Tile(0));
```

###Showing a Grid of Images
Under the hood, we use a HaxePunk Tilemap. The entity requires an Image and Position, but also needs a Grid and an ImageGrid. Don't get me started on ImageGrid again. Anyhow, Image again points to a sprite sheet with multiple images. ImageGrid is again the size of one of these sprites on the sheet. And Grid is a general purpose 2D array of Ints that corresponds to the tile #s you want to show at any given position of the grid. For example, if you have four tiles in tiles.png and want to show a 3x3 grid of tiles, this might very well do that:

```haxe
var e:Entity = newEntity()
	.add(new Image("art/tiles.png"))
	.add(Position.topLeft());
	.add(new ImageGrid(50, 50));
var grid = new Grid(3, 3);
grid.load("0,0,0;1,2,1;3,3,3");
e.add(grid);
```

###Playing an Animation
A HaxePunk Spritemap will be created if you put together an entity with an Image, Position and ImageGrid, but instead of Tile you use an Animation. Animations can be removed automatically (if desired) when they complete or looped.

```haxe
var e:Entity = new Entity()
	.add(new Image("art/anim.png"))
	.add(Position.zero())
	.add(ImageGrid.create(50, 50));
	.add(new Animation("2,4-7,9", 30, LoopType.Both));
```

###Repeating an Image Over the Screen
In HaxePunk this is a Backdrop object. It requires an Image and a Repeating component:

```haxe
var e:Entity = newEntity()
	.add(new Image("art/tiles.png"))
	.add(Repeating.instance);
```

###Adding Text
For TrueType text you need Position and a Text object. By default it will use the HaxePunk font (04B_03__.ttf).

```haxe
var textEntity:Entity = newEntity()
	.add(new Position(10,10))
	.add(new Text("I have something to say"));
```

This could be styled using a TextStyle object. Style options include word wrapping, justification, and an optional drop shadow.

```haxe
var style = TextStyle.createTTF(0xFFFF00, 40, "myfont.ttf", Center);
textEntity.add(style);
```

Flaxen has its own bitmapped text. This requires an additional Image component, and can also be styled with a TextStyle:

```haxe
var e:Entity = new Entity()
	.add(new Image("art/myfont.png"))
	.add(Size.screen().scale(.8))
	.add(Position.center())
	.add(new Text("I have nothing to say"))
	.add(TextStyle.createBitmap(true, Center, Center, -4, -2));
```

Note that a bitmap font image must contain the characters of the BitmapText.ASCII_CHAR_SET, from left to right, with a clean and non-overlapping gap between letters. It will scan the character widths when the font is first used. You can also supply an alternate character set, to specify which characters are in the image. 

The folowing gives a numeric character set, and defines the width of the space to be equal to the "2" character. (Normally it's one third of the "M", but this set lacks an M, so pthbth...)

```haxe
TextStyle.createBitmap(false, Right, Top, 0, -2, 0, "2", false, "0123456789")
```

###Adding a Particle Emitter
The particle system is based off of HaxePunk's Emitter. It requires Position and Emitter components. The image is supplied to the Emitter object, which in retrospect should be supplied by an Image, but then folks might think they could do tiles or clips which it doesn't support. Anyhow this puffs a little smoke:

```haxe
var emitter = new Emitter("art/particle-smoke.png");
emitter.destroyEntity = true;
emitter.maxParticles = Math.floor(radius * radius / 15);
emitter.lifespan = 1.0;
emitter.lifespanRand = 0.1;
emitter.distance = radius * 1.5;
emitter.rotationRand = new Rotation(360);
emitter.stopAfterSeconds = 0.3;
emitter.emitRadiusRand = radius / 10;
emitter.alphaStart = 0.2;

newSingleton("emitter").add(somePosition).add(emitter);
```

###Other Features

There are several notable features here that I need to document. First, most entities (not Emitter) can have optional components added to them that affect their appearance:

* Scale
* Rotation
* Offset
* Origin
* Size
* Alpha
* Invisible
* ScrollFactor
* Size
* Rotation

All visual entities can have a Layer (incuding Emitter). Also there are these other unmentioned features:

* ActionQueue lets you chain events, add/remove components/entities, wait for components to reach a certain state, do timed delays and make callbacks to your functions. I like. Scotchy scotch scotch.
* The mode system lets you specify different start/stop and input handlers based on your game mode (scene), mark entities as transitional, and do a few other funky things. 
* Flaxen has its own Tween component for interpolating values, but you can still use HaxePunk's tweener if you want.
* Sounds can be managed through a Sound component.
* CameraSystem supports the use of a CameraFocus component to follow the camera.
* Dependency relationships between entities can be defined in order to remove dependents as a group.
* A layout manager for help switching between mobile orientations.
* ComponentSets for pre-defining entity transformations and invoking them at runtime.
* And moaaar stuff that barely works!

## For More Help
Some simple demos are included. Flaxen has changed a lot, but you can look at my Ludum Dare compo entries (on GitHub) for a few more examples. This is a work in progress and you should expect it to continue to evolve and break code.

##Dependencies
Flaxen would not be possible without the work of these awesome projects:
* [HaxePunk](https://github.com/HaxePunk/HaxePunk) 
* [Ash-Haxe](https://github.com/nadako/Ash-HaXe)
* [OpenFL](http://www.openfl.org/)

##The MIT License (MIT)

Copyright (c) 2014 Eric Lund

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.