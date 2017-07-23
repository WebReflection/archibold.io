### Using archibold require script [![donate](https://img.shields.io/badge/$-donate-ff69b4.svg?maxAge=2592000&style=flat)](https://github.com/WebReflection/donate)

It is possible to write _Bash_ scripts capable of requiring modules, utilities, and software at runtime.

The list of currently available modules and utilities is in the [utils folder](https://github.com/WebReflection/archibold.io/tree/gh-pages/utils)
while the list of software that can be installed and configured is in the [install folder](https://github.com/WebReflection/archibold.io/tree/gh-pages/install).

Following an example of how to use `require` within a bash script.

```sh
# include archibold.io require
source <(curl -s archibold.io/require)

# require utilities or specific software
require echomd

# use them right away
echomd 'Hello *archibold.io* !!!'
```

Please note **install** scripts are independent and can be used directly via

```
bash <(curl -s archibold.io/install/yaourt)
```
