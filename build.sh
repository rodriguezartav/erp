./node_modules/hem/bin/hem build
echo 'Compiled JS'

lessc -x ./css/index.less > ./public/application.css
echo 'Compiled CSS'

