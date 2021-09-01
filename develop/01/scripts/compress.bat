::@echo off

echo "Compressing JS..."
call java -jar scripts/yuicompressor-2.4.6/build/yuicompressor-2.4.6.jar -o ../../website/js/app.min.js ../../website/js/app.js

::echo "Compressing CSS..."
::call java -jar scripts/yuicompressor-2.4.6/build/yuicompressor-2.4.6.jar -o %CSSDIR%/style.min.css %CSSDIR%/style.css