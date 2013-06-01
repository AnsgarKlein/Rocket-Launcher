Installation Instructions for Rocket-Launcher  
=============================================  

Gtk3
----


To install Rockt-Launcher you will need to have Gtk3 and its Vala (gir) bindings installed.

On Ubuntu (12.04) these packages are called:  
    + ``gir1.2-gtk-3.0``
    + ``libgtk-3-dev``



appindicator
------------

Because Ubuntu has decided that *Gtk.StatusIcon* is not cool anymore *Rocket-Launcher* can use the *appindicator* library to supply an indicator in the notification area.  
If you don't use Ubuntu's Unity Desktop Environment you propably don't want to use *appindicator*, so Rocket-Launcher has support for *Gtk.StatusIcon* too.  
If you want to use *libappindicator* you will need the libappindicator library and its Vala (gir) bindings.

On Ubuntu (12.04) theses packages are called:  
    + ``libappindicator3-1``
    + ``libappindicator3-dev``
    + ``gir1.2-appindicator3-0.1``



Vala
----

Since *Rocket-Launcher* is written in Vala you also need the Vala compiler (valac) and it's dependencies.

You will need at least version 0.16 to compile successfully.

On Ubuntu (12.04) theses packages are called:  
    + ``valac-0.16``
    + ``valac-0.16-vapi``
    + ``libvala-0.16-0``

If you use Ubuntu you can add a Vala ppa:
``ppa:vala-team/ppa``



Building (easy)
---------------

When you have all dependencies installed simply run the install.sh script, which will interactively ask you for your requirements, set the environment variables accordingly and run *make*.
    ```$ ./install.sh```
    ```$ make install```

Building
--------

The building process respects several environment parameters.  
You can set *DEBUG_BUILD* to create a debug build or *RELEASE_BUILD* to create an performance optimized build.  

If you use Ubuntu Unity (the default Ubuntu Desktop Environment, not something like *XFCE*/*KDE*/*LXDE*) you will need the *appindicator* library in order to display an icon in the message area.  
You will also have to set the *WITH_APPINDICATOR* environment variable to use *appindicator*.

Example:  
```$ export DEBUG_BUILD=```
```$ export RELEASE_BUILD=1```
```$ export WITH_APPINDICATOR=```
```$ make```
```$ make install```


Usage
-----

Once you have installed Rocket-Launcher you can start it with the 'rocket-launcher' command, or with through the included .desktop file.

Always start *Rocket-Launcher* with the ```rocket-launcher``` command, not ```rocket-launcher-daemon```.
```rocket-launcher``` will check if another instance of *Rocket-Launcher* is running, and highlight it instead of starting another.

You probably want to bind the ```rocket-launcher``` command to a keyboard shortcut, as well as add ```rocket-launcher --minimized``` to your autostart script.
