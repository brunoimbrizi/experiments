@echo off

echo "Toasting..."
call toaster -c

::echo "Compiling coffee script files..."
::call coffee --join bin/js/main.js --compile src/Path.coffee src/Drag.coffee src/Boid.coffee src/App.coffee

::echo "Compiling less..."
::call lessc -x src/less/style.less > ../../website/css/style.css

::call scripts\compress.bat
::call scripts\docco.bat

echo "Done."