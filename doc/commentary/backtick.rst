Compiler macros are often used to lay down code in the calling word. You'll see something like:

::

  : foo ['] + compile ['] . compile ; immediate

This is fine, but sometimes you need to deal with other macros:

::

  : bar 1 literal, 2 literal, ['] foo execute ; immediate

This approach has one problem: keeping track of what words need to be compiled and which need to be called. Plus, with Retro's use of word classes, you may have other words that are handled in other ways.

The word ` was written to address this. It is class-aware, so lays down the proper code and the proper class handler for it. With ` the above examples can be rewritten:

::

  : foo ` + ` . ; immediate
  : bar ` 1 ` 2 ` foo ; immediate
