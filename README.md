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


## Twine-Specific Commands

These commands exist only in this Twine integration — they are not part of the core Harrow language, and won't work with `harrow.Runtime` used outside this format. Core syntax (routes, dialogue, `if`/`else`, variables) is documented in Harrow's own [Writing.md](https://github.com/nayata/harrow/blob/main/Documentation/Writing.md).


### Scenes

`[scene RouteName]` jumps to the given route and remembers the current position on an internal stack. `[scene close]` returns to wherever the last open scene was called from. `[scene clear]` empties the whole stack.

Scenes stack, so they can be nested arbitrarily deep — for example, opening a quest screen, then a dungeon screen from within it, then a battle screen from within that, and closing each one in turn back to where it was opened


### Bookmark & Return

`[bookmark]` remembers the current position as a single return point (unlike scenes, this is a single slot, not a stack — setting a new bookmark overwrites the previous one). `[return]` jumps back to it. `[bookmark clear]` clears it.

A dialogue choice can also target `return` directly instead of a route name:

```
[bookmark]

You step out of the entry portal into the abandoned Central Plaza. 
Once a thriving nightlife hub, now it’s a ghost town of flickering neon and drifting trash. Broken vending machines spark weakly.
In the distance, the skeletal silhouette of the old factory looms beyond layers of fog.

- Check your gear : Inventory
- Continue

...

# Inventory

Your plasma rifle hums softly, charging indicator glowing blue. Standard-issue, reliable.
Base Damage: [damage]

- Back : return
```


### Images and HTML

`[image filename.jpg]` displays an image and reveals the image box. The path is resolved relative to the configured assets folder (`config.assets.folder`) — so a bare filename like `filename.jpg` loads from that folder, while a full URL (`https://example.com/image.jpg`) loads directly from the internet. `[image show]` / `[image hide]` toggle the image box's visibility without changing its content.

Raw HTML can also be used directly in text lines — including `<img>` tags for inline images, or formatting tags such as `<h2>`, `<span>`, and similar:

```
<h2>Chapter One</h2>

This is regular narrative text.
<img src="images/map.jpg">

The party studies the map before setting out.
```


### Stat, Bar, and Dice

- `[stat name]` renders a labeled bar showing the current value of `name` (intended for **Fairmath**-style 0–100 stats).
- `[bar name]` renders a labeled bar showing `name` against `name.total` (e.g. current/max health).
- `[dice name]` renders a die face with the current value of `name`.

All three read directly from story variables — nothing needs to be declared beyond the variable itself (and `name.total` for `[bar]`).

```
Your character's stats.

[stat courage]
[bar health]
[dice dexterity]
```


### Chapter Title

```
[chapter Chapter Two]
```

Updates the chapter heading shown in the story header.


### Inline Images in Text

Regular text lines may contain raw `<img src="https://...">` (or `http://`) tags directly — the format detects and repairs this specific case so the URL's `:` isn't mistaken for a speaker-name separator. No special escaping is needed beyond writing the tag as normal HTML.


### Built-in Settings Screen

The Settings screen (opened via the header's settings icon) includes, by default:

- **Font Size** — cycles between Default, Large, and Small; affects the story textbox only.
- **Font Family** — cycles between the page's default font and a serif alternative; applies to the whole page (`body`), not just the textbox.
- **Theme** — cycles between Light and Dark.
- **Restart the Game** — reloads the story from the beginning.
- **Return** — closes the Settings screen and resumes the story.

The header text at the top of the Settings panel comes from `config.settings.title` (see [Configuration](#configuration) above) — it wraps the whole panel, independent of whichever tab is currently open.

#### Adding Content Tabs

The **Settings** screen can show additional read-only tabs alongside the default one — useful for a character sheet, journal, inventory summary, or any other reference screen the player can check without leaving the current scene.

To add a tab, tag a passage `menu` in the Twine editor:

Tag the `Character` passage with `menu`, and a **Character** tab appears in Settings, showing the rendered content of the `# Character` route. Any number of passages can be tagged this way — each becomes its own tab, in the order they appear in the story file. If at least one `menu`-tagged passage exists, the built-in font/theme/restart screen becomes its own **Settings** tab alongside them, rather than being the only thing shown; if none exist, it's shown directly with no tabs at all.

```
**Character**

[player]
Gold: [gold]
[stat courage]
```

Tab content supports `[if]`/`[else]`/`[end]` (including nested conditions), regular text, and `[stat]`/`[bar]` — the same rendering used during normal play. It does **not** execute variable assignments (`=`, `+`, `roll`, and so on) — opening a tab is a read-only snapshot of the current game state, so viewing it never changes any variables.


### Speaker Parsing & Escaping

When `config.parse.speaker` is `true`, a text line written as `Name: text` has `Name` wrapped in an invisible `<span class="speaker">` — hidden by default, but can be made visible and styled through custom CSS (for example, giving `speaker` a `display` and font/color rules of your own). When `config.parse.speaker` is `false`, no span is inserted; the speaker name is instead written directly into the visible text as a plain `Name: ` prefix.

Because a leading `:` on a text line is what marks a speaker name, a line that needs a literal colon without triggering this split should escape it with a backslash: `\:`.


### Configuration

Set once, typically near the top of the story, before any content is shown:

```
[config.parse.speaker true]
[config.text.fill 80]
[config.dialogue.vertical 3]
[config.settings.title Game Settings]
[config.text.end <h2>That is where the story ends.</h2>]
[config.assets.folder images/]
```

`config.parse.speaker` *true/false* — whether `Name: text` lines render the name inline as prose instead of as a styled speaker tag
`config.text.fill` Percentage of textbox height that triggers a page break (lower = shorter pages)
`config.dialogue.vertical` Choice count above which dialogue switches to a horizontal layout
`config.settings.title` The title shown at the top of the Settings screen
`config.text.end` Text shown when the story ends or `[close]` is used
`config.assets.folder` Base path used by `[image ...]`