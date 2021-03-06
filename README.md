## nim-thue

This is an interpreter for the [Thue programming language][1] written in Nim.
I made this mainly to experiment with the Thue language.

The implementation can run any Thue program but I've added functionality
described [here](http://lvogel.free.fr/thue.htm). The feature is optional and
is described along with the rest below.

[1]: https://en.wikipedia.org/wiki/Thue_(programming_language)

## Requirements

You need the [Nim compiler](http://nim-lang.org/) to compile the interpreter.

## Usage

### Compiling

```
$ nim c -d:release thue.nim
```

This creates an executable in your directory called `thue`.

### Running

```
$ ./thue [options] program.t
  options:
    -l, --left-to-right         Apply rules deterministically left to right
    -r, --right-to-left         Apply rules deterministically right to left
    -d, --debug                 Debug the program

    -nn, --no-newlines          Don't print newlines along with ~ directives,
                                instead only print newlines when ~ is alone
```

There are example programs in the `examples` directory.
