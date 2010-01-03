=============
Git and Retro
=============

The Retro system is split into several repositories. To get
everything, execute the following:

::

  git clone git://github.com/crcx/retro10.git
  git clone git://github.com/crcx/ngaro.git
  git clone git://github.com/crcx/forthlets.git
  git clone git://github.com/crcx/wheke.git

For those wanting a breakdown of the current set of repositories:

+-----------+----------------------------------------+
| **Repo**  | **Description**                        |
+===========+========================================+
| retro10   | This repository stores the code needed |
|           | to build a new retroImage. You'll need |
|           | a working copy of Ngaro to build the   |
|           | source.                                |
+-----------+----------------------------------------+
| ngaro     | The Ngaro VM                           |
+-----------+----------------------------------------+
| forthlets | Various examples and demonstrations    |
+-----------+----------------------------------------+
| wheke     | A library of useful extensions to the  |
|           | language.                              |
+-----------+----------------------------------------+

========
Updating
========

With Git, updates are pretty easy:

::

  cd retro10 && git pull
  cd ngaro && git pull
  cd forthlets && git pull
  cd wheke && git pull

Note that if you make changes in your local copy of the repos, you may
have to resolve any conflicts manually before pushing future changes.

============
Contributing
============

If you want to share your changes with us, we recommend that you
create an account on github and use the github fork functionality
to create your repositories. If you do this, it's easy to push your
changes and submit pull requests. Plus we will generally follow all
forks and watch for any interesting developments in the forks.
