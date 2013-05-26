Installation Instructions for Rocket-Launcher
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


Gtk3
----

To install Rocket-Launcher you will need to have Gtk3 installed.



appindicator
------------

Rocket-Launcher uses the appindicator library to supply an indicator in the message-area.
So you will need the libappindicator library and its vala bindings.

On Ubuntu (12.10) theses packages are called:
	* ``libappindicator3-1``
	* ``libappindicator3-dev``
	* ``gir1.2-appindicator3-0.1``



Vala
----

Since Rocket-Launcher is written in Vala you also need the vala compiler (valac) and it's dependencies.

You will need at least version 0.16 to compile successfully.

On Ubuntu (12.10) theses packages are called:
	* ``valac-0.16``
	* ``valac-0.16-vapi``
	* ``libvala-0.16-0``
	(If thats not enough try installing ``libvala-0.16-dev``)

If you use Ubuntu you can add a Vala ppa:
``ppa:vala-team/ppa``



Build
-----

When you have all dependencies installed simply do:
	$ make

	$ make install	(you might want to sudo this)



Usage
-----

Once you have installed Rocket-Launcher you can start it with the 'rocket-launcher' command,
or with through the included .desktop file.
