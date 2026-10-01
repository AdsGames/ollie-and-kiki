.PHONY: server neko html5 watch lint format watch-web

server:
	haxe --wait 6001

neko:
	SDL_VIDEODRIVER=x11 lime test neko --connect 6000

html5:
	lime test html5 --connect 6000

watch:
	find source -name "*.hx" | entr -r sh -c 'SDL_VIDEODRIVER=x11 lime test neko -debug --connect 6001'

lint:
	haxelib run checkstyle -s source --config checkstyle.json

format:
	haxelib run formatter -s source 

watch-web:
	find source -name "*.hx" -o -name "*.xml" | entr -r haxelib run lime test html5 -debug --connect 6000
