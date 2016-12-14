#!/usr/bin/env bash

#########################
# archibold.io (C) 2016 #
#########################

if [ "$DIR" = "" ]; then
  exit 1
fi


echo "#!/usr/bin/env bash

####################
# (C) archibold.io #
####################
# <link rel='styleSheet' href='/css/markdown.css'/>
# <script defer src='//cdn.rawgit.com/showdownjs/showdown/1.5.1/dist/showdown.min.js'></script>
# <script defer src='/js/transformer.js'></script><pre>
####################

source <(curl -s archibold.io/require)

require echomd

clear

echomd '" > $DIR/index.html

echo "# archibold.io/$DIR" >> $DIR/index.html
for f in $(ls $DIR); do
  if [ "$f" != "index.html" ]; then
    echo "
**$f**" >> $DIR/index.html
    if [ -f info/$f ]; then
      cat info/$f >> $DIR/index.html
      echo '' >> $DIR/index.html
    fi
  fi
done

echo "'" >> $DIR/index.html
