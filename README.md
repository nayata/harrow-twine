# Harrow for Twine

A custom [Twine 2](https://twinery.org) story format powered by [Harrow](https://github.com/nayata/harrow), a narrative parsing and runtime library written in Haxe.

## What is this?

**Harrow** for Twine replaces Twine's default link-based passage flow with a linear, script-driven narrative model closer to [ChoiceScript](https://www.choiceofgames.com/make-your-own-games/) / Choice of Games titles than to Harlowe or SugarCube. Instead of connecting passages through `[[links]]`, stories are written as continuous text with inline commands for dialogue, branching, conditions, and variables — read top to bottom, page by page, the way CoG-style interactive fiction is typically structured.

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