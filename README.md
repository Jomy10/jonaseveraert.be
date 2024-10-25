# Website

Official repository for [jonaseveraert.be](https://jonaseveraert.be).
Feel free to use any code for your own projects.

## Installation

### macOS

```sh
brew install libmagic sqlite3
```

### Dependencies

```sh
bundle install
bun install
ruby init.rb
```

### Running

```sh
ruby src/main.rb
```

## Running on FreeBSD with Pot

```sh
sh pot_build.sh
pot start website
```

## rc script

```sh
ln $(pwd)/rc_script /usr/local/etc/rc.d/website
chmod a+x /usr/local/etc/rc.d/website
```
