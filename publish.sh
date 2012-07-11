mkdir -p ~/Desktop/jquery.nanoscroller.$1
cp bin/javascripts/jquery.nanoscroller.min.js ~/Desktop/jquery.nanoscroller.$1
cp bin/css/nanoscroller.css ~/Desktop/jquery.nanoscroller.$1
zip ~/Desktop/Archive.zip ~/Desktop/jquery.nanoscroller.$1/*
mv ~/Desktop/Archive.zip ~/Desktop/jquery.nanoscroller.$1.zip
