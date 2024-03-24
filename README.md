# Inky

Inky is an unopinonated GUI framework for the [LÖVE game framework](https://love2d.org/), though it should work with anything Lua(JIT) based.
It is heavily inspired by [Helium](https://github.com/qeffects/helium) and [React](https://reactjs.org/).

### Why?
Inky aims to solve LÖVE's problem of having no generic GUI framework that can work everywhere for anything.
Most of LÖVE's GUI frameworks provide a (limited) set of widgets, and/or constrain itself to only a single input system.
Inky gives complete freedom in both these aspects: Mouse, Mobile, Gamepad, Retro, Modern, Windowed. Everything is possible with Inky.

### How?
Inky does _not_ provide any out of the box widgets for you to use. If you want a button, you'll have to program it.
However! Inky _does_ provide everything to make this process streamlined and easy.
Making a widget means settings up '_hooks_' for the widget's logic, and providing a draw function.
Inky provides hooks to respond to events, interact with pointers, manage state, perform side effects, and much more.

## Getting Started

To get started, create a local copy of Inky in your game's directory by downloading it, or cloning the repository.

Use `Inky.defineElement` to define a new UI element:
```lua
-- button.lua
local Inky = require("inky")

return Inky.defineElement(function(self)
	self.props.count = 0

	self:onPointer("release", function()
		self.props.count = self.props.count + 1
	end)

	return function(_, x, y, w, h)
		love.graphics.rectangle("line", x, y, w, h)
		love.graphics.printf("I have been clicked " .. self.props.count .. " times", x, y, w, "center")
	end
end)

```

Then, use `Inky.scene` to set up a scene with your element, and use `Inky.pointer` to delegate the events:
```lua
-- main.lua
local Inky = require("inky")

local Button = require("examples.getting_started.button")

local scene   = Inky.scene()
local pointer = Inky.pointer(scene)

local button_1 = Button(scene)
local button_2 = Button(scene)

love.window.setMode(220, 66)
love.window.setTitle("Example: Getting Started")

function love.update(dt)
	local mx, my = love.mouse.getX(), love.mouse.getY()
	pointer:setPosition(mx, my)
end

function love.draw()
	scene:beginFrame()

	button_1:render(10, 10, 200, 16)
	button_2:render(10, 40, 200, 16)

	scene:finishFrame()
end

function love.mousereleased(x, y, button)
	if (button == 1) then
		pointer:raise("release")
	end
end

```
The above is also available as an example at https://github.com/Keyslam/Inky/tree/develop/examples/getting_started.

## High Level Overview
With Inky you'll be interacting with 3 kinds of objects: Elements, Scenes, Pointers.

### Elements
Elements encapsulate a single UI widget, like a button, a label, or a list. 
You define your widgets using `Inky.defineElement`. For each Element you can configure it's variables, how to respond to events, how to draw, and much more.

#### Quick Reference
```typescript
Element = Inky.defineElement(initializer)

element = Element(scene)

element.props.foo = "bar"

x, y, w, h = element:getView()

element:on(eventName, callback)

element:onPointer(eventName, callback)
element:onPointerInHierarchy(eventName, callback)

element:onPointerEnter(callback)
element:onPointerExit(callback)

element:onEnable(callback)
element:onDisable(callback)

element:useOverlapCheck(predicate)

element:useEffect(effect, ...)

element:render(x, y, w, h, depth)
```

### Scenes
Scenes manage Elements. 1 Scene can contain many Elements, and an Element can only be in 1 Scene. 

#### Quick Reference
```typescript
scene = Inky.scene(spatialHashSize)

scene:beginFrame()
scene:finishFrame()

didBeginFrame = scene:didBeginFrame()

scene:raise(eventName, ...)
```

### Pointers
Pointers represent the cursor in the GUI system, but are flexible to also support touch controls, d-pad controls, keyboard controls, and much more.
Pointers can have a (x, y) position, in which case they interact with Elements at that location.
Pointers can also have a target Element, in which case they only interact with that Element.

#### Quick Reference
```typescript
pointer = Inky.pointer(scene)

pointer:setPosition(x, y)
x, y = pointer:getPosition()

pointer:setTarget(target)
target = pointer:getTarget()

mode = pointer:getMode()

pointer:setActive(active)
active = pointer:isActive()

doesOverlapElement = pointer:doesOverlapElement(element)
doesOverlapAnyElement = pointer:doesOverlapAnyElement()

consumed = pointer:raise(eventName, ...)

pointer:captureElement(element, shouldCapture)
doesCaptureElement = pointer:doesCaptureElement(element)
```

## API

### Creating an Element
Elements can be defined by providing a `initializer` function, which can optionally return a `draw` function.

```lua
local MyElement = Inky.defineElement(function(element)
	-- Optional draw function
	return function(self, x, y, w, h, depth)

	end
end)

```
The result can then be called to create an instance of the Element
```lua
local myElement = MyElement(scene)
```

### Rendering an Element
Elements can be rendered, meaning it will respond to events and be drawn.
If no depth is provided, the depth of the parent Element `+ 1` is used instead.
> **_NOTE:_** A [Scene Frame](#) has to be started before an Element can be rendered.
```lua
myElement:render(x, y, w, h, depth?)
```

### Using arguments
Elements contain a `props` field which can be used to send and read arguments.
```lua
local myElement = MyElement(scene)
myElement.props.foo = "bar"
```

```lua
local MyElement = Inky.defineElement(function(element)
	print(element.props.foo) -- "bar"
end)
```

> **_NOTE:_** It is encouraged to also use the `props` field to store variables that define the state of the Element.
```lua
local MyElement = Inky.defineElement(function(element)
	-- Bad
	local hovered = false

	-- Good
	element.props.hovered = false
end)
```

### Responding to props changed
Elements can listen to the change of a prop.
> **_NOTE:_** Effects are executed right before the next draw of the Element
```lua
local MyElement = Inky.defineElement(function(element)
	-- Listen to 'foo' changing
	element:useEffect(function()
		print("Foo changed")
	end, "foo")

	-- Listen to 'foo' or 'bar' changing
	element:useEffect(function()
		print("foo or bar changed")
	end, "foo", "bar")
end)
```

### Responding to Events
Elements can listen to [Pointers Events](#raising-pointer-events) and [Scene Events](#raising-scene-events)

```lua
local MyElement = Inky.defineElement(function(element)
	-- Listen to Scene Event raised
	element:on(eventName, function(self, ...)
		print("Scene event")
	end)

	-- Listen to Pointer Event raised
	element:onPointer(eventName, function(self, pointer, ...)
		print("Pointer event")
	end)

	-- Listen to Pointer event in Hierarchy
	-- That is, any (grand)child of this Element accepted the Pointer Event
	element:onPointerInHierarchy(eventName, function(self, pointer, ...)
		print("Pointer event in hierarchy")
	end)
end)
```

### Responding to Pointer Hovers
Elements can listen to know when a Pointer starts or stops hovering over it.

```lua
local MyElement = Inky.defineElement(function(element)
	-- Listen to Pointer started hovering Element
	element:onPointerEnter(function(self, pointer, ...)
		print("Enter")
	end)

	-- Listen to Pointer stopped hovering this Element
	element:onPointerExit(function(self, pointer, ...)
		print("Exit")
	end)
end)
```

### Responding to enable/disable
When an Element is rendered this frame, but wasn't rendered last frame, it is effectively enabled.
Similarly, if an Element isn't rendered this frame, but was rendered last frame, it is effectively disabled.
Elements can listen to know when this occurs.

```lua
local MyElement = Inky.defineElement(function(element)
	-- Listen to Element enabled
	element:onEnable(function(self)
		print("Enabled")
	end)

	-- Listen to Element disabled
	element:onDisable(function(self)
		print("Disabled")
	end)
end)
```

### Custom overlap check
Elements can provide a custom function for overlapping checks with Pointers. This can be useful for rounded buttons, for example.
> **_NOTE:_** Pointers _always_ need to overlap with bounding box of the Element
```lua
local MyElement = Inky.defineElement(function(element)
	-- Define a overlap check
	element:useOverlapCheck(function(self, px, py, x, y, w, h)
		-- Only if the pointer's x position is less than 200
		return px < 200
	end)
end)
```

### Get view
Elements know the position they were last rendered at
```lua
local MyElement = Inky.defineElement(function(element)
	element:on(eventName, function()
		local x, y, w, h = element:getView()
	end)
end)
```

### Creating a Pointer
Pointers need to be attached to a Scene
```lua
local pointer = Inky.pointer(scene)
```

### Position of Pointer
The position of a Pointer can be set and got.
Setting the position changes the [mode](#pointer-modes) of the Pointer to `POSITION`.
```lua
pointer:setPosition(x, y)
local x, y = pointer:getPosition()
```

### Target of Pointer
The target of a Pointer can be set and got.
Setting the target changes the [mode](#pointer-modes) of the Pointer to `TARGET`. See 
```lua
pointer:setTarget(element)
local target = pointer:getTarget()
```

### Pointer Modes
Pointers can be in 2 modes: `POSITION` and `TARGET`.

In `POSITION` mode the Pointer interacts with any Elements it overlaps with. This is useful for your standard mouse cursor.\
In `TARGET` mode the Pointer interacts only with the target Element. This can be useful for keyboard navigation and programmatically interacting with Elements.

```lua
local mode = pointer:getMode()
```

### Pointer Active
Pointers can be made (in)active. When a Pointer is inactive it doesn't interact with any Elements.
```lua
pointer:setActive(boolean)
local isActive = pointer:isActive()
```

### Raising Pointer Events
Pointer Events can be raised to be [caught by Elements](#responding-to-events).
Pointer Events are sent to the Element with the highest depth first. When an Element listens to the Event it is consumed, and won't be sent to any other Elements.
If the event was consumed by any element, this function returns `true`. Otherwise it returns `false`.

```lua
consumed = pointer:raise(eventName, ...)
```

### Pointer capturing Elements
When a Pointer 'captures' an Element all the Pointer Events will be sent to it, regardless of if the Pointer overlaps the Element.
```lua
-- Start capturing
pointer:captureElement(element, true)

-- Start capturing
pointer:captureElement(element, false)

local doesCaptureElement = pointer:doesCaptureElement(element)
```

### Pointer overlapping Elements
Pointers know which Elements it is overlapping
```lua
local doesOverlapElement = pointer:doesOverlapElement(element)
local doesOverlapAnyElement = pointer:doesOverlapAnyElement()
```

### Creating a Scene
Scenes use a SpatialHash under the hood which cell size can be configured.
```lua
-- Create a Scene with the default SpatialHash size (32)
local scene = Scene()

-- Create a Scene with a SpatialHash size of (64)
local scene = Scene(64)
```

### Scene Frames
Elements need to be [rendered](#rendering-an-element) within a Scene Frame, which needs to be started and finished.
```lua
function love.draw()
	scene:beginFrame()
	-- Render elements
	scene:finishFrame()
end

local didBeginFrame = scene:didBeginFrame()
```

### Raising Scene Events
Scene Events can be raised to be [caught by Elements](#responding-to-events).
Scene Events are sent to all Elements active in the Scene.

```lua
scene:raise(eventName, ...)
```
