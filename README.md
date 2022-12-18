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
Making a widget means settings up '_hooks_' for the widget's logic, and providing a render function.
Inky provides hooks to respond to events, interact with pointers, manage state, perform side effects, and much more.

## Getting Started

To get started, create a local copy of Inky in your game's directory by downloading it, or cloning the repository.

Use `Inky.element` to define a new UI element:
```lua
-- button.lua
local Inky = require("inky")

return Inky.element.make(function(scene, context, props)
	local count = 0

	context:onPointer("release", function()
		count = count + 1
	end)

	return function(view)
		love.graphics.rectangle("line", view.x, view.y, view.w, view.h)
		love.graphics.printf("I have been clicked " .. count .. " times", view.x, view.y, view.w, "center")
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
	scene:newFrame()

	button_1(10, 10, 200, 16)
	button_2(10, 40, 200, 16)
end

function love.mousereleased(x, y, button)
	if (button == 1) then
		pointer:emit("release")
	end
end

```
The above is also available as an example at https://github.com/Keyslam/Inky/tree/develop/examples/getting_started.

### Element
```typescript
element = Element.make(function(scene, context, props)
	// Hooks

	return function(view)
		// Rendering
	end
end)

elementInstance = element(scene)
// Or
elementInstance = element(scene, {
	foo = "bar"
})

elementInstance.foo = "bar"
// Or
elementInstance:foo("bar")

elementInstance(x: number, y: number, w: number, h: number) // Rendering
```

### Context

```typescript
context:on(name: string, callback: (view: View, ...)) => self
context:onPointer(name: string, callback: (pointer: Pointer, view: View, ...)) => self

context:onPointerEnter(name: string, callback: (pointer: Pointer)) => self
context:onPointerExit(name: string, callback: (pointer: Pointer)) => self

context:useOverlapCheck(predicate: (x: number, y: number, view: View): boolean) => self

context:useState(initialValue: any): getter: () => any, setter: (value: any)
context:useEffect(effect: (), ...) => self
```


### Scene
```typescript
scene = Scene()

scene:newFrame() => self

scene:emit(name: string, ...) => self
```

### Pointer
```typescript
pointer = Pointer(scene: Scene)

pointer:getPosition() => x: number, y: number
pointer:setPosition(x: number, y: number) => self

pointer:getTarget() => Element
pointer:setTarget(target: Element) => self

pointer:getMode() => "POSITION" | "TARGET"

pointer:getActive() => boolean
pointer:setActive(active: boolean) => self

pointer:emit(name: string, ...) => self
```

### View
```typescript
view.x: number
view.y: number
view.w: number
view.h: number
```