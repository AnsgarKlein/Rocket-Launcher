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


static int main(string[] args) {
	//Can only run with (multi) thread support
	if (!Thread.supported()) {
		stderr.printf("Cannot run withouth thread support. Exiting ...\n");
		return 1;
	}
	
	//Only start when argument is --maximized or --minimized
	if (args[1] != "--minimized" && args[1] != "--maximized") {
		stdout.printf("Start the daemon with either\n");
		stdout.printf("\t--maximized or\n");
		stdout.printf("\t--minimized\n");
		stdout.printf("\nBut it's better to just let the launcher handle the daemon\n");
		return 1;
	}
	
	
	//Start
	stdout.printf("\n");
	Gtk.init(ref args);
	
		
	//Create Window
	MainWindow mainWindow = new MainWindow();
	if (args[1] == "--maximized") {
		mainWindow.show_all();
	}
	
	//Create AppIndicator
	new MyAppIndicator(mainWindow);
	
	//Start D-Bus server
	GLib.Bus.own_name(GLib.BusType.SESSION,
				"org.launcher.rocket",
				BusNameOwnerFlags.NONE,
				(dbusconnection, name) => {
					try {
						dbusconnection.register_object("/org/launcher/rocket", new DBusServer(mainWindow));
					} catch (IOError e) {
						stderr.printf("Could not register service\n");
					}
				},
				() => {},
				() => {
					stderr.printf("Could not aquire dbus name\n");
				});
	
	
	Gtk.main();
	stdout.printf("\n");
	return 0;
}
