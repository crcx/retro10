==============
Building Retro
==============

Requirements
------------
To build a new image, you'll need the following:

- Make
- Ngaro VM ("retro")
- An existing image file (at least core + stage2)

Given these, edit the Makefile and modify the first line to
point to your Ngaro VM.

Full Image
----------
This is the basic core, second stage, and additional tools.

::

   make

Minimal Image
-------------
Just the core functionality. This is not enough to run the
metacompiler.

::

   make core

Extended Image
--------------
The minimal core and extensions from stage 2. This is the
baseline for running the metacompiler.

::

   make stage2

Javascript
----------
If you are using the JS implementations, you'll also need:

- grep
- sed

::

   make js

Java MIDP
---------
If you are using the MIDP implementations, you'll also need:

- grep
- sed

::

   make midp
