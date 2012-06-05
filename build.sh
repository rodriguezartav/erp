lessc -x ./css/index.less > ./public/application.css
echo 'Compiled CSS'
./node_modules/hem/bin/hem build
echo 'Compiled JS'
