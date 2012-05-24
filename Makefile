all:
	cake build
	cake server

develop:
	coffee -o bin/javascripts -wcb coffeescripts
