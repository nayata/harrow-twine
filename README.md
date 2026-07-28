# Harrow for Twine

A custom [Twine 2](https://twinery.org) story format powered by [Harrow](https://github.com/nayata/harrow), a narrative parsing and runtime library written in Haxe.

## What is this?

**Harrow** for Twine replaces Twine's default link-based passage flow with a linear, script-driven narrative model closer to [ChoiceScript](https://www.choiceofgames.com/make-your-own-games/) / Choice of Games titles than to Harlowe or SugarCube. Instead of connecting passages through `[[links]]`, stories are written as continuous text with inline commands for dialogue, branching, conditions, and variables - read top to bottom, page by page, the way CoG-style interactive fiction is typically structured.

If you're coming from Twine's usual "map of connected passages" mental model, this format asks you to think in terms of *pages* and *routes* instead: a story flows forward automatically, and branching happens through explicit commands rather than clickable links scattered through prose.

## Features

- Linear, CoG-style narrative flow with named routes for branching
- Dialogue-style choices with conditional visibility
- Variables, conditions, and expressions (`if`, arithmetic, dice rolls, Fairmath-style stats)
- Built-in stat/progress bars, image display, and scene transitions
- A built-in Settings screen (font size, font family, theme)

## Installation

1. Open Twine 2 (desktop or [web version](https://twinery.org/2/)).
2. Go to **Story Formats** from the Twine library screen.
3. Click **Add a New Format**.
4. Paste the following Story Format URL:
```
https://nayata.github.io/format/format.js
```
5. Once loaded, open any story's settings and select **Harrow** as its story format.

## Documentation

- [Writing.md](https://github.com/nayata/harrow/blob/main/Documentation/Writing.md) - the core Harrow scripting syntax (routes, dialogue, variables, conditions)
- Twine-specific commands (scenes, stat bars, images, settings) are documented separately below, as they exist only in this Twine integration and are not part of the core Harrow language.


## Getting Started

## Getting Started

Harrow stories can be organized either the traditional Twine way - one route per passage, linked together - or written as a single continuous script within one passage, using named routes (`# RouteName`) to structure branching internally. Both approaches are valid; the example below uses a single passage for simplicity.

Create a new passage `Start`, set it as the story's starting passage, and paste in the following:

```harrow
[player = Arthur]
[has.key = false]
[gold = 10]

[player] arrives at the gates of an abandoned fortress.
A locked door blocks the only path forward.

- Check your bag : Inventory
- Search the courtyard : Courtyard
- Try the door : Door

# Inventory
You carry a sword and [gold] gold coins.
- Return : Start

# Courtyard
[has.key = true]
Among the broken stones, you discover a rusty key.
- Go to the gate : Door

# Door
[if has.key == true]
    You unlock the ancient door.
    [gold + 25]
    Inside the fortress you find an old treasure chest.
    You now have [gold] gold.
    [move Victory]
[else]
    The door is locked.
    - Search for a key : Courtyard
    - Check your bag : Inventory
[end]

# Victory
The treasure is yours.
[close]
```

Playing this story, a reader would:

1. Start at the fortress gate with three choices.
2. Check the inventory (a self-contained route that returns to the start) or search the courtyard (which sets `has.key` before offering a way to the door).
3. Reach the door, where an `[if]` condition checks `has.key` - locked without the key, unlockable with it.
4. On success, `gold` is increased, the new total is shown inline, and `[move Victory]` jumps straight to the ending route.

