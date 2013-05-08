copyfiles:
	git checkout master -- bin
	cp -R bin/* .
	git rm -rf bin
	git checkout master -- docs
