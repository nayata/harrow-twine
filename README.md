# Introduction

**Harrow Twine** is a Twine 2 story format built on the Harrow narrative library.

Unlike formats such as **Harlowe** or **SugarCube**, Harrow Twine focuses on a structured, gamebook-style experience inspired by **Choice of Games**. Readers progress through self-contained pages, make dialogue-style choices, and see only the options that are currently available based on the game's state.

Harrow provides a concise scripting language with built-in support for variables, conditions, arithmetic expressions, dice rolls, and Fairmath-style statistics. Common RPG and visual novel features are available without additional scripting, allowing authors to focus on writing instead of UI implementation.

### Features

* **Page-based storytelling** inspired by Choice of Games.
* **Dialogue-style choices** with conditional visibility.
* **Variables, conditions, arithmetic expressions, and dice rolls.**
* **Fairmath-style** stat calculations for RPG progression.
* **Built-in stat and progress bars.**
* **Image display** directly inside passages.
* **Animated dice roll visualization.**
* **Title screen** and a customizable **Settings** screen with font size, font family, theme selection, restart, and return options.
* Fully compatible with the Harrow story syntax while adding **Twine**-specific features and interface components.


## Installation

1. Open Twine 2 (desktop or [web version](https://twinery.org/2/)).
2. Go to **Story Formats** from the Twine library screen.
3. Click **Add a New Format**.
4. Paste the following Story Format URL:
```
https://nayata.github.io/format/format.js
```
5. Once loaded, open any story's settings and select **Harrow** as its story format.


## Writing Stories

A Harrow Twine story consists of **passages**. Each passage represents a complete scene. The story begins in the first passage and continues by moving to other passages.

The example below demonstrates the basic concepts:

* variables
* text
* choices
* conditional blocks
* moving between passages

```harrow
[relic = Moonstone Idol]
[torch = false]

You enter the Whispering Cave in search of the lost [relic].
A narrow passage leads deeper underground.

- Light a torch : torch = true
- Walk into the darkness

[if torch is true]
    You light your torch.

    The torch reveals a hidden spike trap. You carefully make your way past it.
    The tunnel ends at an ancient stone altar.

    [move Victory]
[else]
    Hidden spikes spring from the floor.

    [move Defeat]
[end]

# Victory

You claim the [relic] and leave the cave safely.

[close]

# Defeat

Your adventure ends in the darkness.

[close]
```

This example introduces most of the concepts you'll use throughout the documentation. The following chapters explain each feature in detail.


## Text
Text is written directly inside passages without any special markup.

Unlike traditional Twine story formats, **Harrow Twine** automatically presents long passages one page at a time. When the current page becomes full, the remaining text is hidden until the reader presses **Continue**.

This allows you to write naturally without manually splitting passages into smaller sections.

You can even place an entire chapter or short story inside a single passage, and **Harrow Twine** will paginate it automatically.


## Choices

Choices can be created using the `-` symbol at the beginning of a line.

A choice may include an action, written after a `:` symbol.
There are two types of actions:

1. Route navigation – to jump to another passage.

2. Variable operation – to change or assign a variable.

A choice may also be empty and simply continue the current flow.

```
- Attack : damage = 20
- Drink potion : Heal
- Wait
```

In this example:

- The `Attack` choice uses an action to set damage to 20.

- The `Drink potion` choice uses an action to navigate to the `Heal` route.

- The `Wait` choice has no action and continues the current flow.



## Branching

Branching in Harrow is done using `routes`, which are declared with the `#` symbol at the beginning of a line.
Routes function similarly to `passages`.

To move to a specific route, use an action in a choice or a move command:
`[move RouteName]`.

**Important:** The story flow stops when a new route begins.
An explicit action is required to transition into that route.

#### Example

Moving via choice:

```
The mouth of the cave yawns open, cold air curling out like breath.
- Enter the cave : CaveInterior


# CaveInterior
You step into the cave. It's cold and silent.
```

Moving via command:

```
The mouth of the cave yawns open, cold air curling out like breath.
[move CaveInterior]


# CaveInterior
You step into the cave. It's cold and silent.
```



## Variables

Variables are declared using square brackets and the `=` operator.

```
[gold = 50]
```

Variables can store numbers or strings.

```
[quest = Find the tomb of the forgotten king.]
[quest.status = completed]
```


#### Random

A variable can be assigned a random value:

```
[dice roll 20]
```


#### Variable operations

Basic mathematical operations (`+`, `-`, `*`, and `/`) are supported. Other variables can be used in calculations.

```
[damage = 20]
[critical roll 20]
[damage + critical]

[enemy.health - damage]
```


#### Printing variables

The value of a variable can be displayed in text using square brackets.

```
[gold = 50]
You have [gold] gold coins.
```

Variables can also be shown inside choices.

```
- I have [gold] gold coins.
- This is too much for this information.
```



## Conditional blocks

A simple `if`.

```
[torch.lit = true]

[if torch.lit = true]
    The torch casts long shadows across the stone walls.
[end]
```

`if/else` condition.

```
[if torch.lit = true]
    The torch casts long shadows across the stone walls.
[else]
    Darkness swallows everything beyond the first few steps.
[end]
```

`chance` condition.

```
[torch.lit = false]

[if torch.lit chance 50]
    [torch.lit = true]
    You fire the torch and long shadows falls across the stone walls.
[end]
```


## Actions

Actions control the flow of the story. They are used to perform operations such as moving to another passage, opening a scene, or ending the game.

Unlike variables and conditions, actions do not store or check data — they perform an immediate operation when the passage is processed.


## Move

`[move PassageName]` Moves the story to another passage.


## Scene

`[scene PassageName]` Opens another passage as a scene while remembering the current location. When the scene is closed with `[scene close]`, the story returns to the place where the scene was opened.

`[scene close]` — returns to the previous scene.
`[scene clear]` — clears the entire scene stack.

Scenes use a stack system, which allows them to be nested arbitrarily deep.

For example, a game can open a **quest screen**, then a **dungeon screen** from within the quest, and finally a **battle screen** from the dungeon. Closing each scene returns the player back through the same path:

**Battle → Dungeon → Quest → World**


## Bookmark & Return

`[bookmark]` Stores the current location as a return point.

`[return]` Returns to the saved bookmark.

`[bookmark clear]` Removes the saved bookmark.

Unlike scenes, bookmarks use a single return slot. Creating a new bookmark replaces the previous one.

A choice can also use `return` directly instead of a passage name:

```harrow
[bookmark]

You step out of the entry portal into the abandoned Central Plaza. 
Once a thriving nightlife hub, now it’s a ghost town of flickering neon and drifting trash.
In the distance, the skeletal silhouette of the old factory looms beyond layers of fog.

- Check your gear : Inventory
- Continue

...

# Inventory

Your plasma rifle hums softly, charging indicator glowing blue. Standard-issue, reliable.
Base Damage: [damage]

- Back : return
```


## Chapter

`[chapter Chapter Name]` Updates the chapter title displayed in the story header.

This can be changed at any point during the story and does not affect the story flow.


## Close

`[close]` Ends the story and displays the ending screen.

The text of the ending screen can be customized through the story configuration:

```harrow
[config.text.end <h2>That is where the story ends.</h2>]
```


## CoG-style Fairmath

Harrow Twine includes support for **Fairmath**, the percentage-based stat system popularized by *Choice of Games*.

Unlike simple addition and subtraction, Fairmath makes large values harder to increase and small values harder to decrease. This produces smooth character progression without allowing statistics to reach their minimum or maximum too quickly.

Fairmath is available for any numeric variable using the `%+` and `%-` operators.

```harrow
[strength %+ 20]
[morality %- 15]
```

Because Fairmath values are stored as normal variables, they can be used anywhere a regular variable can be used, including conditions.

```harrow
[if strength >= 70]
    You effortlessly force the door open.
[else]
    The door refuses to budge.
[end]
```

#### Displaying Stats

A Fairmath variable can be displayed as a built-in progress bar using the `stat` command.

```harrow
[stat strength]
```

The current value is shown both numerically and visually, making it ideal for character attributes such as strength, reputation, health, morale, or relationships.

Example:

```harrow
Character: [player.name]

Strength
[stat strength]

Reputation
[stat reputation]

A seasoned explorer who prefers diplomacy over violence, but never backs down from a challenge.
```


так же вы можете ограничить высоту текста чтобы например достичь вида визуальной новеллы.