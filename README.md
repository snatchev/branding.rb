# Branding

Proud of your code? Add some _bling_ to your terminal.

[![asciicast](https://asciinema.org/a/9gk8mur6c5gmff67to3y1l1a1.png)](https://asciinema.org/a/9gk8mur6c5gmff67to3y1l1a1)

## Perks

* No dependencies!
* Pure Ruby PNG decoding in < 200 LoC
* Hi-Res mode for 4x pixel density!
* Hi-Color mode for 720 colors!!
* Loads of fun!

## Quality

Much quality.

## How it works

Branding will detect your Rails application's favicon. It adds a small
initializer in development and testing environments that draws the favicon with
ANSI control characters whenever you run tests, a rake task or boot the console.

### Hi-Res mode

`hires` mode is a technique where we can 4x the "pixel" density of the
terminal. This is accomplished by using the half-height unicode characters.

Some terminal fonts do not render these characters very well and there are some artifacts.

So far, `Inconsolata` has yield the best results.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'branding'
```

## Usage

If you're adding branding to your Rails project, there is no more
configuration. To test how images look in the terminal:

```shell
branding logo-72x72.png
```

To test out **hires mode**, try:

```shell
branding -p hires logo-144x144.png
```

## Contributing

Have a good idea to make Branding more awesome? Make a pull request and share your thoughts!
