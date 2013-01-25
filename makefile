copyfiles:
	git checkout master -- bin
	cp -R bin/* .
	rm -rf bin
