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


using AppIndicator;

class MyAppIndicator {
	
	public MyAppIndicator(MainWindow mainWindow) {		
		//Create Indicator
		AppIndicator.Indicator ind = new AppIndicator.Indicator("example-simple-client", GlobalSettings.application_icon, AppIndicator.IndicatorCategory.APPLICATION_STATUS);
		ind.set_status(AppIndicator.IndicatorStatus.ACTIVE);
		ind.set_attention_icon("indicator-messages-new");
		
		// -- Item 1 (Show)
		Gtk.MenuItem menu_item1 = new Gtk.MenuItem.with_label("Show");
		menu_item1.show();
		menu_item1.activate.connect(() => {
			mainWindow.show_Window();
		});
		
		// -- Item 2 (Quit)
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
			ind.set_status(IndicatorStatus.ATTENTION);
			
			mainWindow.exit_program();
		});
		
		//Create Menu
		Gtk.Menu menu = new Gtk.Menu();
		menu.append(menu_item1);
		menu.append(menu_item2);
		ind.set_menu(menu);
	}
}
