@echo off

echo "Compiling coffee script files..."
call coffee --join ../../website/01/js/main.js --compile src/App.coffee

echo "Done."