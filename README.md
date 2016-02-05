# Gemfighter
Gemfighter is a roguelike game, written in Ruby. Its original incarnation was 
called [gemthief](https://github.com/mhink/gemthief), but that project quickly 
started getting out of hand because I was overusing ActiveSupport. That said,
a major goal of this project is to make it 'Rubyish'- that is, make good use
of available language features, idioms, and architectural styles.

Accordingly, it's very object-oriented, but strongly prefers composition over
inheritance.

## Entities (/lib/entity.rb)
The `Entity` class is a thin layer over `Object`. In fact, it's more like a free-form
`Struct` than anything else. When an `Entity` is instantiated, it accepts a set of
keyword arguments (`kwargs`), and then stores the value of each in a corresponding
instance variable. Each of these instance variables represents a component, and
is accessible through the corresponding accessors. Entities may also be named by
providing a unique name as the initial (non-keyword) parameter to #new.

The idea here is that Entities should just be considered a 'bag of components',
and each component should simply be named data. I originally tried making 
components actual objects, but the temptation to implement methods on them was
extremely strong, and I never found a good way to elegantly compose them into
Entities without resorting to extensive metaprogramming.

`Entity` instances are stored in a registry maintained by the `Entity` class itself;
after they are created, they may be looked up by component using the 
`Entity.find_by` method; they may also be looked up by name using `Entity.find`.

One convention I've been trying to stick with is that components should be 
serializable, so that in the future I don't have to do a bunch of re-tooling
to be able to save/load stuff. This means that stuff like the Window instance
shouldn't be stored in an Entity.

## Systems (/game/*_system.rb)
I'm still toying with the patterns here, but the long and short of it is that 
Systems are more or less singleton objects implemented as a Ruby `Module`. 
However, This is not actually enforced by any existing code structure. The 
convention I've been following is that these Systems are only allowed to
interact with the outside world by reading and modifying Entity instances- and
it's perfectly fine if that Entity's sole purpose is to be the medium for 
inter-system communications. 

It's also acceptable for these systems to maintain
internal state; however, this state should remain isolated; no other system
is allowed to hold a reference to it. (Again, this isn't enforced at either the
language or the runtime level- it's just a convention that I'm trying out.)

**PlayerSystem**: Sets a 'velocity' component on the "player" entity if the
appropriate input has been received.
**MapSystem**: Checks registered entities to see if they're allowed to move to
the location they've requested. If they are, it moves them and updates the map's
collision bitmap.
**LogSystem**: Currently disabled; the idea is that this will facilitate the
in-game log.
**ShutdownSystem**: Listens for input that doesn't affect the player, and takes
the appropriate action. I'll probably rename this and use it for input that
doesn't cause the *player*'s state to change (such as showing a menu).
**DrawingSystem**: What it says on the tin. I have a basic "render graph" set
up, and this recurses down that graph in preorder, rendering entities as it
goes along. Entities can specify a 'render_with' component to indicate the 
method that DrawingSystem should use to render them.

## Game (/lib/game.rb, /game/gemfighter.rb)
The base Game class simply does system setup and teardown for the core Game loop.
It's also where exception and throw-catch handling live. It could easily not be
a subclass at all, but I wanted to keep my 'system' code and my 'game-specific'
code in their own places so they wouldn't be cluttered.

The Gemfighter class is the nucleus for game state and logic. Its functions:
1. Instantiate Entities. In the future, I want to move this responsibility
   elsewhere (so that I could, for instance, load Entities from a file).
2. Instantiate the game Window. I used to have a System responsible for this, 
   but it seemed like useless abstraction.
3. Store received input in the "input" Entity. Again, I used to have a system
   specifically for this, but it eventually didn't seem to fit, because I had
   to store a reference to the Window in an Entity, and that felt wrong.
4. Invoke systems in the correct order, during the correct Window lifecycle 
   events. Pretty straightforward.

## Other Stuff
### Rakefile
This is the invocation point for the game. `rake play` starts the game, and
`rake console` just instantiates the game and drops into a Pry session.

### /config/environment.rb
This is a common Ruby pattern; it loads our dependencies, sets some globals
representing various directories in the project, and sets up the Ruby load path.
(Hence, 'environment.rb'.)

### /lib/window.rb
A wrapper for Gosu::Window, which allows us to set up callbacks for certain
functions and, importantly, lets us hold down a key to continuously drive the
core game loop.

### /lib/bitmap.rb
A convenience class for using the excellent Bitset gem to represent a 2d array
of bits.
