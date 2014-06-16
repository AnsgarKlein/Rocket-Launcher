Installation Instructions
=========================

GTK+ 3
------

To install Rockt-Launcher you will need to have GTK+ 3 and its Vala
bindings installed.

On Ubuntu (12.04) these packages are called:

* ``gir1.2-gtk-3.0``
* ``libgtk-3-dev``



appindicator (optional)
-----------------------

Because Ubuntu has decided that *Gtk.StatusIcon* is not cool anymore
*Rocket-Launcher* can use the *appindicator* library to supply an indicator in
the notification area.  
If you don't use Ubuntu's Unity Desktop Environment you propably don't want to
use *appindicator*, so Rocket-Launcher has support for *Gtk.StatusIcon* (default) too.  
If you want to use *libappindicator* you will need the libappindicator library
and its Vala bindings.

On Ubuntu (12.04) theses packages are called:

* ``libappindicator3-1``
* ``libappindicator3-dev``
* ``gir1.2-appindicator3-0.1``



Other Dependencies
------------------

Since *Rocket-Launcher* does some drawing with Cairo and uses Xlib for
determining the current icon theme you technically also need Cairo and Xlib
(and their Vala bindings). But Xlib bindings come with vala and GTK+ 3 depends
on cairo, so you most probably don't have to install them separately.



D-Bus
-----

*Rocket-Launcher* requires a working *D-Bus* System.
If you don't know what *D-Bus* is, you probably have that.



Vala
----

Since *Rocket-Launcher* is written in Vala you also need the Vala compiler
(valac) and it's dependencies.

You will need at least version 0.16 to compile successfully, but the newer
the better.

On Ubuntu (12.04) theses packages are called:

* ``valac-0.16``
* ``valac-0.16-vapi``
* ``libvala-0.16-0``

If you use Ubuntu you can add a Vala ppa to always get the lastest
Vala compiler:

``ppa:vala-team/ppa``



Building (easy)
---------------

When you have all dependencies installed simply run the install.sh script,
which will interactively ask you for your requirements, set the environment
variables accordingly and run *make*.

``$ ./install.sh``  
``$ make install``

Building
--------

The building process respects several environment parameters.  
You can set *RCKTL_BUILD_DEBUG* to create a debug build or
*RCKTL_BUILD_RELEASE* to create an performance optimized build.  

If you use Ubuntu Unity (the default Ubuntu Desktop Environment, not something
like *XFCE*/*KDE*/*LXDE*) you will need the *appindicator* library in order
to display an icon in the message area.  
You will also have to set the *RCKTL_FEATURE_APPINDICATOR* environment
variable to use *appindicator*.  
*Rocket-Launcher* also supports threaded builds. You can tell make to build
with multiple threads with *-j* tag.
(Or set it in *MAKEFLAGS* environment variable)  
Make supports setting the *DESTDIR* environment variable to specify a
(absolut) path that gets prepended to every installed file.

Example:

``$ export RCKTL_BUILD_DEBUG=``  
``$ export RCKTL_BUILD_RELEASE=1``  
``$ export RCKTL_FEATURE_APPINDICATOR=``  
``$ make -j4``  
``$ make install``  


Usage
-----

Once you have installed Rocket-Launcher you can start it with the
'rocket-launcher' command or by using the included .desktop file.

*Rocket-Launcher* will check if another instance of *Rocket-Launcher* is
running, and show its window instead of starting another instance.

You probably want to bind the ``rocket-launcher`` command to a keyboard
shortcut, as well as add ``rocket-launcher --minimized`` to your
autostart script.

