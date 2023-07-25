SERVER = server.com
LUASRC = .args .init.lua .lua $(shell fd -e lua -e fnl -E '*macros.fnl' | sed 's/.fnl$$/.lua/')

${SERVER}: redbean.com db ${LUASRC}
	cp redbean.com ${SERVER} && zip -r ${SERVER} ${LUASRC} tmpl/

db: sqlite3.com
	( [ -d db ] || mkdir db ) && ./sqlite3.com db/sqlite3 < schema.sql

%.lua: %.fnl
	fennel -c $< >$@

.PHONY: js
js:
	npx squint compile asset/*.cljs

.PHONY: clean
clean:
	rm -f ${SERVER}

.PHONY: debug
debug:
	DEBUG=1 rlwrap ./${SERVER} -p 8888 -uv -D .

.PHONY: repl
repl:
	./${SERVER} -F .init.lua -e "require'fennel'.repl()" -i

.PHONY: reload
reload:
	find .init.lua .lua tmpl | entr -r ./${SERVER} -p 8888 -D .

.PHONY: deps
deps:
	curl https://redbean.dev/redbean-latest.com >redbean.com && chmod +x redbean.com
	curl https://redbean.dev/sqlite3.com >sqlite3.com && chmod +x sqlite3.com
	curl https://raw.githubusercontent.com/pkulchenko/fullmoon/master/fullmoon.lua >.lua/fullmoon.lua
	curl https://raw.githubusercontent.com/slembcke/debugger.lua/master/debugger.lua >.lua/debugger.lua
	curl https://raw.githubusercontent.com/starwing/luaiter/master/iter.lua >.lua/iter.lua
	curl https://raw.githubusercontent.com/andreyorst/itable/main/src/itable.fnl >.lua/itable.fnl
	curl https://tiddlywiki.com/empty.html >wiki.html
	cp ~/github/fennel/fennel.lua .lua/
	sudo sh -c "echo ':APE:M::MZqFpD::/usr/bin/ape:' >/proc/sys/fs/binfmt_misc/register"
