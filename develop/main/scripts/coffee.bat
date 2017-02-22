@echo off

echo "Compiling coffee script files..."
call coffee --join ../../website/js/main.js --compile src/App.coffee

::call scripts\compress.bat

echo "Done."