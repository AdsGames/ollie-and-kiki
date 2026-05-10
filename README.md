# Kiki's Delivery Day

## Installing

You will need [haxelib](https://haxe.org/download/)

```sh
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib run lime setup
haxelib run lime setup flixel
haxelib run flixel-tools setup
```

Optionally

```sh
haxelib install checkstyle
haxelib install formatter
```

## Running

### Neko

```sh
lime test neko
```

### Native

```sh
lime test cpp
```

### HTML5

```sh
# Not required if using vscode
haxe --wait 6000
lime test html5 --connect 6000
```

or in vscode

`ctrl + shift + b`

## VS Code Extension

For better development download the LIME plugin for vscode.

## Demo

Code is built and automatically deployed [here](https://adsgames.github.io/ollie-and-kiki/)!
