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
	
	
	//Create Notification-Area icon
	#if WITH_APPINDICATOR
		//Create AppIndicator
		AppIndicator.Indicator ind = new AppIndicator.Indicator("example-simple-client", GlobalSettings.application_icon, AppIndicator.IndicatorCategory.APPLICATION_STATUS);
		ind.set_status(AppIndicator.IndicatorStatus.ACTIVE);
		ind.set_attention_icon("indicator-messages-new");
		
		//Item 1 (Show)
		Gtk.MenuItem menu_item1 = new Gtk.MenuItem.with_label("Show");
		menu_item1.show();
		menu_item1.activate.connect(() => {
			mainWindow.show_Window();
		});
		
		//Item 2 (Quit)
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
		
		//Menu
		Gtk.Menu menu = new Gtk.Menu();
		menu.append(menu_item1);
		menu.append(menu_item2);
		ind.set_menu(menu);
	#else
		//Create StatusIcon
		Gtk.StatusIcon status_icon = new Gtk.StatusIcon.from_icon_name(GlobalSettings.application_icon);
		status_icon.set_tooltip_text("Rocket-Launcher");
		status_icon.set_visible(true);
		
		//MenuItem 1 (Show)
		Gtk.MenuItem menu_item1 = new Gtk.MenuItem.with_label("Show");
		menu_item1.show();
		menu_item1.activate.connect(() => {
			mainWindow.show_Window();
		});
		
		//MenuItem 2 (Quit)
		Gtk.MenuItem menu_item2 = new Gtk.MenuItem.with_label("Exit");
		menu_item2.show();
		menu_item2.activate.connect(() => {
			mainWindow.exit_program();
		});
		
		//Menu
		Gtk.Menu menu = new Gtk.Menu();
		menu.append(menu_item1);
		menu.append(menu_item2);
		menu.show_all();
		
		status_icon.popup_menu.connect((button, activate_time) => {
			menu.popup(null, null, null, button, activate_time);
		});
	#endif
	
	
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
