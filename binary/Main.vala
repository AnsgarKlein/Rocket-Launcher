/**
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
**/


namespace RocketLauncher {
    static int main(string[] args) {
        // Can only run with (multi) thread support
        if (!Thread.supported()) {
            string err_str = "";
            err_str += "Cannot run without thread support !";
            err_str += "Exiting ...\n";
            print_error(err_str);
            return 1;
        }
        
        // Print help and exit if started with "--help" or "-h"
        foreach (string arg in args) {
            if (arg == "-h" || arg == "--help") {
                stdout.printf("Options:\n");
                stdout.printf("  -h --help\t\tPrint this help\n");
                stdout.printf("  -m --minimized\tStart the application minimized\n");
                stdout.printf("\t\t\tStart the application again to show window.\n");
                return 0;
            }
        }
        
        // Check if an application instance is already running
        bool running = false;
        GLib.MainLoop check_loop = new GLib.MainLoop();
        
        GLib.Bus.watch_name(BusType.SESSION,
                            "org.launcher.rocket",
                            BusNameWatcherFlags.AUTO_START,
                            () => {
                            running = true;
                            check_loop.quit();
                            },
                            () => {
                            running = false;
                            check_loop.quit();
                            }
                            );
        
        check_loop.run();
        
        // If in instance is already running we toggle its visibility
        // and exit.
        if (running) {
            DBusManagerInterface dbus_manager = null;
            try {
                dbus_manager = GLib.Bus.get_proxy_sync(BusType.SESSION,
                                                      "org.launcher.rocket",
                                                      "/org/launcher/rocket",
                                                      GLib.DBusProxyFlags.NONE,
                                                      null);
                
                
                // Send toggle request
                if (dbus_manager.send(dbus_request.toggle)) {
                    return 0;
                } else {
                    string err_str = "";
                    err_str += "Error occured while trying to tell already running\n";
                    err_str += "application to toggle its window visibility.\n";
                    err_str += "Application is not listening to us !\n";
                    err_str += "Exiting ...\n";
                    print_error(err_str);
                    return 1;
                };
            } catch (IOError e) {
                string err_str = "";
                err_str += "Error occured while trying to connect to D-Bus.\n";
                err_str += "Could not connect to application !";
                err_str += "IOError: " +e.message +"\n";
                err_str += "Exiting ...\n";
                print_error(err_str);
                return 1;
            }
        }
        
        // If no instance is running we start up the complete application
        // and register with dbus.
        Gtk.init(ref args);
        
        // Create Window
        MainWindow mainWindow = new MainWindow();
        
        // If we got no '--minimized' or '-m' command line option
        // we maximize the window
        if (args.length < 2 || (args[1] != "--minimized" && args[1] != "-m")) {
            mainWindow.show_all();
        }
        
        // Register D-Bus server
        GLib.Bus.own_name(GLib.BusType.SESSION,
                        "org.launcher.rocket",
                        BusNameOwnerFlags.NONE,
                        (dbusconnection, name) => {
                            try {
                              dbusconnection.register_object("/org/launcher/rocket", new DBusManager(mainWindow));
                            } catch (IOError e) {
                                string err_str = "";
                                err_str += "Error occured while trying to connect to D-Bus.\n";
                                err_str += "Could not register application with D-Bus !";
                                err_str += "IOError: " +e.message +"\n";
                                err_str += "D-Bus Features will not work ...\n";
                                print_error(err_str);
                            }
                        },
                        () => {},
                        () => {
                            string err_str = "";
                            err_str += "Error occured while trying to connect to D-Bus.\n";
                            err_str += "Could not register application with D-Bus !";
                            err_str += "D-Bus Features will not work ...\n";
                            print_error(err_str);
                        });
        
        // Create Notification-Area icon
        #if RCKTL_FEATURE_APPINDICATOR
            //Create AppIndicator
            AppIndicator.Indicator ind;
            ind = new AppIndicator.Indicator(Constants.application_name,
                                             Constants.application_icon,
                                             AppIndicator.IndicatorCategory.APPLICATION_STATUS);
            ind.set_status(AppIndicator.IndicatorStatus.ACTIVE);
            ind.set_attention_icon("indicator-messages-new");
            
            // Item 1 (Show)
            Gtk.MenuItem menu_item1 = new Gtk.MenuItem.with_label("Show");
            menu_item1.show();
            menu_item1.activate.connect(() => {
                mainWindow.show_Window();
            });
            
            // Item 2 (Quit)
            Gtk.MenuItem menu_item2 = new Gtk.MenuItem.with_label("Exit");
            menu_item2.show();
            menu_item2.activate.connect(() => {
                //I don't know why, but ironically you need at least one
                //menu item which changes the "status" (-> icon) of the
                //indicator.
                //Otherwise the program will compile just fine, but just
                //don't show the indicator (no error).
                //We just change the status on the exit menu item, so
                //probably no one will notice since the application quits
                //afterwards.
                ind.set_status(AppIndicator.IndicatorStatus.ATTENTION);
                
                mainWindow.exit_program();
            });
            
            // Menu
            Gtk.Menu menu = new Gtk.Menu();
            menu.append(menu_item1);
            menu.append(menu_item2);
            ind.set_menu(menu);
        #else
            // Create StatusIcon
            Gtk.StatusIcon status_icon;
            status_icon = new Gtk.StatusIcon.from_icon_name(Constants.application_icon);
            status_icon.set_tooltip_text(Constants.application_name);
            status_icon.set_visible(true);
            
            // MenuItem 1 (Show)
            Gtk.MenuItem menu_item1 = new Gtk.MenuItem.with_label("Show");
            menu_item1.show();
            menu_item1.activate.connect(() => {
                mainWindow.show_Window();
            });
            
            // MenuItem 2 (Quit)
            Gtk.MenuItem menu_item2 = new Gtk.MenuItem.with_label("Exit");
            menu_item2.show();
            menu_item2.activate.connect(() => {
                mainWindow.exit_program();
            });
            
            // Menu
            Gtk.Menu menu = new Gtk.Menu();
            menu.append(menu_item1);
            menu.append(menu_item2);
            menu.show_all();
            
            status_icon.popup_menu.connect((button, activate_time) => {
                menu.popup(null, null, null, button, activate_time);
            });
        #endif
        
        
        Gtk.main();
        stdout.printf("\n");
        return 0;
    }
}
