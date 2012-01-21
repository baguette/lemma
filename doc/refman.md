
Lemma 0.2 Reference Manual
======================

### 20 January 2012


> *Language is froth on the surface of thought.* -- John McCarthy

> *Programming languages should be designed not by piling feature on top of feature, but by removing the weaknesses and restrictions that make additional features appear necessary.*  -- Revised(3) Report on the Algorithmic Language Scheme

> *Having an open, and large, set of functions operate upon an open, and small, set of extensible abstractions is the key to algorithmic reuse and library interoperability.*  -- Rich Hickey



Introduction
------------

Lemma is a general-purpose programming language.  It is a member of the Lisp family of languages and is designed to interoperate with the [Lua][] platform.  Lemma is multi-paradigm, offering support for procedural, object-oriented, and functional programming.

`lemma` is also the name of a processor for the Lemma programming language.  `lemma` provides an interactive interpreter (a *REPL* or *read-evaluate-print loop* in Lisp parlance) and a compiler that translates Lemma source code to Lua source code.

Both the language and processor (as well as this manual) are works in progress.

**TODO** Note about Lemma being *properly tail-recursive*. (Thanks to Lua being properly tail-recursive).

[Lua]:      http://lua.org/



Values and types
----------------

Lemma is an *untyped*, *dynamically checked* language -- variables don't have types, but values do.  Lemma provides values of several types.  Programmers are free to add new types.

- *Booleans* represent truth values.  The two boolean values are *true* and *false*.  In many contexts where boolean values are needed, *truthy* or *falsy* values may be substituted.  Falsy values are *false* and *nil*; all other values are considered truthy.
- *Nil* is a value that paradoxically signifies the lack of any significant value.  It is the only member of the nil type.
- *Number* values represent Lua numbers.  The specific type of number is dependent on the Lua installation, but it's usually an IEEE 754 double-precision floating point.
- *Symbols* represent names but can sometimes represent other things, too.
- *Strings* represent sequences of characters (e.g., text).
- *Lists* represent sequences of values.
- *Iters* also represent sequences of values, but do so (almost) lazily.  They are potentially (countably) infinite in length.
- *Vectors* represent arrays of values.
- *Hashmaps* represent collections of mappings from values to values.
- *Function* values may represent procedures and methods; they are essentially little packets of executable code.

Lemma may have values of any type in Lua; programmers may stumble upon *tables*, *threads*, *userdata*.  Lemma doesn't currently provide any direct support for manipulating these types of values, however they may be manipulated by calling Lua functions.



External representation
-----------------------

The textual representation of data in Lemma is known as the *external representation*.  Before Lemma code is processed, a subprogram known as the *reader* converts these human-readable external representations into machine-friendly forms known as *internal representations*.  The reader's compliment, the *writer*, can perform the (almost) inverse conversion.  Note that there are some types of value that do not have an external representation (iters, for example), and some values may have multiple external representations (strings and symbols, for example).  It is important to distinguish between external and internal representations: the numeral `42`, which is a sequence of characters, is the external representation of the number forty-two, which is a number.

Lemma source consists of

1. *atoms* separated by whitespace or delimiters, 
2. delimited *collection* literals, and
3. *comments*.

Atoms and collections together constitute *data* (plural of *datum*).  Whitespace consists of spaces, tabs, newlines, or commas (`,`); whitespace is only significant for the separation of atoms.  Delimiters are parentheses `()`, square brackets `[]`, and curly brackets `{}`.


### Atoms

- *Booleans* are written as `true` or `false`.
- *Nil* is written as `nil`.
- *Numbers* are written as any number of digits, optionally with a sign, a decimal point, and/or a decimal exponent.  Integers in base 16 are also permitted with a `0x` prefix.
    `3    -3    3.0    +3.1416    314.16e-2    -0.31416E1    0xff    -0x56`
- *Symbols* may be written in two ways:
    1. as a sequence of characters not containing any whitespace or delimiters and not representing any other type of datum*: `this-is-a-symbol`
    2. as a sequence of characters enclosed in pipes, where literal pipes may be escaped within: `|a single symbol enclosed in \| characters|`
- *Strings* may be written in two ways:
    1. as any atom prefixed with a colon: `:short-form-string` `:123  =>  "123"`
    2. as a sequence of characters enclosed in double quotes, where literal double quotes may be escaped within: `"a string enclosed in \" characters"`

\* Type 1 symbols may also not begin with a character which begins a reader macro. See below.


### Collections

Lemma provides three kinds of collection literals:

- *Lists* are sequences of data enclosed in balanced parentheses: `(= forty-two 42)` is a list of 3 data, the symbol `=`, the symbol `forty-two`, and the number `42`.
- *Vectors* are arrays of data enclosed in square brackets: `[:a :b 1 2]` is a vector of 4 data, two strings and two numbers.
- *Hashmaps* are associative mappings between pairs of data enclosed in curly brackets: `{:a 1 :b 2}` represents a map of strings to numbers.

Since collections are groups of data, and since collections are themselves data, they may be nested arbitrarily: `(list [1 2 3 4] {:a 1 :b 2})`

**Note** Iters have no external representation, but many functions in the standard library produce them.


### Comments

Comments do not correspond to any type of data; they are ignored by the reader completely.  They allow the programmer to include notes directly in the source.  There are three kinds of *comments* in Lemma:

1. Line comments start with a semicolon (`;`) that is not a part of a symbol or a string and continues until the end of the line.
2. Datum comments start with `#;` and subsume the next datum: `#;commented-symbol` `#;(commented list)`
3. Block comments start with `#|` and end with a corresponding `|#`. Block comments may be nested.


### Reader macros

Some data are so common in Lemma programs that the reader actually provides shorthand ways of writing them.  These abbreviations are known as *reader macros*.  A reader macro is triggered by one or more special characters that precede a form.  The list below shows the supported reader macros and their expansions, where `x` stands for any datum and `=>` in this context should be read as "expands to" (the meaning of the expansions will be presented later).

        'x  =>  (quote x)
        `x  =>  (quasiquote x)
        ~x  =>  (unquote x)
        @x  =>  (splice x)
        .x  =>  (method x)



Execution model
---------------

Lemma's execution model centers around *expressions* and the *evaluation* of expressions to yield values.  Any datum can form an expression.  Numbers, strings, booleans, and nil evaluate to themselves; they are called *self-evaluating* (`=>` should be read as "evaluates to" in this context):

        42    =>  42
        "hi"  =>  "hi"
        true  =>  true
        false =>  false
        nil   =>  nil

Symbols are evaluated as names for some other value, and are sometimes called *variables*.  A symbol can be *bound* to a value; unbound symbols evaluate to nil:

        unbound-sym  =>  nil
        lemma/*ns*   =>  "lemma"

Vectors are evaluated by evaluating all of their constituents in place:

        [:hi 42 nil lemma/*ns*]  =>  ["hi" 42 nil "lemma"]

Hashmaps are evaluated by evaluating their keys and associating them with the results of evaluating their values:

        { lemma/*ns* lemma/*ns*, :a 1 }  =>  { "lemma" "lemma", "a" 1 }

The most complicated evaluation is the evaluation of lists.  Lists are used to represent function calls.  First, Lemma evaluates the first element (or *head*) of the list and expects it to yield a function value (it is an error if the head does not evaluate to a callable object).  Next, Lemma evaluates each element in the rest of the list (or *tail*) and passes those values as *arguments* to the function, thus *calling* the function.  The result of evaluating the entire list is the result returned from the function call:

        (+ 2 4)  =>  6

In this example, the head of the list, the symbol `+`, is evaluated.  It results in a function that takes two arguments and returns the sum of those arguments.  Each element of the tail is evaluated.  Since the tail is composed of only self-evaluating forms, the final function call is simply the addition of 2 and 4.  The entire list, then, evaluates to 6.

**Note** There are a few lists in Lemma that do not follow the above evaluation strategy; see *Special forms* below.

**Note** Functions in Lemma may produce side-effects.


### Symbol resolution

#### Namespaces

**Note** Namespaces are broken at the moment.  They will correspond to a module system eventually.

#### Environments

#### Table paths

Symbols that contain periods are resolved as paths into nested tables.  This mimics the `var` production rule of the Lua 5.1 grammar.  Conceptually, the symbol is split into subsymbols at the periods.  The leftmost subsymbol is evaluated in the current environment, expecting a table value.  The other subsymbols are converted to strings and used as subsequent indexes into a hierarchy of nested tables.

        html.head.title

is semantically equivalent to

        (get (get html :head) :title)

however, the first representation happens at resolution time while the second happens at runtime.


### Special forms

### Macros

**Note** Macros work but are kludgey when working with compiled files.  They'll be fixed along with namespaces.



Library reference
-----------------

### General

*macro* **` defn`** ` name argvec @body`

> Defines a function named `name` with parameter vector `argvec` and body `@body`. The parameter vector is exactly as in the `fn` special form.

*procedure* **` type`** ` obj`

> Returns a string indicating the type of `obj`.

*procedure* **` method`** ` key`

> Returns a function of `[t @args]` that calls the method specified by `key` on `t` with `@args` as arguments.  A shortened form is available as the `.` reader macro:

        (.upper :hello)          =>  "HELLO"
        (map .upper [:a :b :c])  =>  ("A" "B" "C")

### Booleans

### Numbers

### Sequences

All sequences in Lemma must implement `first`, `rest`, and `empty?`.  All built-in sequences also implement `cons`:

*procedure* **` first`** ` seq`

> Returns the head of `seq`.

*procedure* **` rest`** ` seq`

> Returns the tail of `seq`.

*procedure* **` empty?`** ` seq`

> Returns truthy if there are no elements in `seq`, falsy otherwise.

*procedure* **` cons`** ` obj seq`

> Returns a new sequence whose head is `obj` and tail is `seq`.

Lemma provides a number of functions for sequence manipulation **TODO**:

*procedure* **`second`** ` seq`

> Returns the second value of a `seq`.

*procedure* **`map`** ` f seq`

> Returns a new iter where each element is the result of applying `f` to the corresponding element in `seq`.

        (map (fn [x] (* x 2)) [1 2 3 4])  =>  (2 4 6 8)
        (map .upper [:a :b :c])           =>  ("A" "B" "C")

*procedure* **`for-each`** ` f seq`

> Applies `f` to each element of `seq`, presumably for side effects.  Always returns `nil`.

*procedure* **`filter`** ` f seq`

> Returns a new sequence where each element is the next element of `seq` that, when `f` is applied to it, evaluates truthily.

        (filter odd? [1 2 3 4 5])                  =>  (1 3 5)
        (filter (fn [x] (< x 10)) [7 9 10 11 12])  =>  (7 9)

*procedure* **`foldl`** ` f init seq`

*procedure* **`foldr`** ` f init seq`

#### Lists

*procedure* **` list`** ` @args`

> Constructs a new list whose elements are the elements of `args`, in the same order.

#### Iters

*procedure* **` iter`** ` f s var filter?`

> Constructs a new iter whose elements are generated by calling `(filter (f s var))` expecting two results. The first result becomes the next value of `var` while the second result is added to the sequence.  If `filter` is unspecified, it defaults to something compatible with Lua's builtin iterators (`ipairs`, `pairs`, etc.) which packs multiple return values into a vector.

        (first (iter (lua/pairs lua/table)))  =>  ["insert" function: 0x100102a60]
        (map .upper (iter (lua/io.lines)))    =>  reads lines and upcases them until EOF


### Vectors

### Hashmaps

### Input/Output



Lua interoperation
------------------

### Tables

### The `lua` namespace

### Compiling



Differences from other Lisps
----------------------------

* `nil` is not a symbol, nor is `nil` the empty list.  A symbol named "nil" can be written as `|nil|`. (Likewise, `true` and `false` are not symbols, but `|true|` and `|false|` are.)
* There is no built-in pair type.
* `splice` (also known as the `@` operator) is not restricted to use inside `quasiquote`. It may be used anywhere to unpack the values of any sequence.  For example, `(apply f lst)` is better expressed as `(f @lst)` in Lemma.
* Lemma has no keyword type. `:string`s are provided as a shorthand to facilitate interoperability with Lua. Use them appropriately.

About this document
-------------------

This document has been formatted as [GitHub Flavored Markdown][GFM] and is readable as plain text.  Care has been taken for compatibility with other Markdown processing systems, such as the original [Markdown][] and [Pandoc][].  When viewing as plain text, it may be helpful to wrap long lines.  Many text editors, as well as the Unix commands `fold` and `fmt`, can do this automatically.

[GFM]:      http://github.github.com/github-flavored-markdown/
[Markdown]: http://daringfireball.net/projects/markdown/
[Pandoc]:   http://johnmacfarlane.net/pandoc/
