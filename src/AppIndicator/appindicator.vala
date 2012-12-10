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
	
	public MyAppIndicator() {		
		//Create Indicator
		AppIndicator.Indicator ind = new AppIndicator.Indicator("example-simple-client", GlobalSettings.application_icon, AppIndicator.IndicatorCategory.APPLICATION_STATUS);
		ind.set_status(AppIndicator.IndicatorStatus.ACTIVE);
		ind.set_attention_icon("indicator-messages-new");
		
		// -- Item 1
		Gtk.MenuItem menu_item1 = new Gtk.MenuItem.with_label("Foo");
		menu_item1.show();
		menu_item1.activate.connect(() => {
			ind.set_status(IndicatorStatus.ATTENTION);
		});
		
		// -- Item 2
		Gtk.MenuItem menu_item2 = new Gtk.MenuItem.with_label("Bar");
		menu_item2.show();
		menu_item2.activate.connect(() => {
			ind.set_status(IndicatorStatus.ATTENTION);
		});
		
		//Create Menu
		Gtk.Menu menu = new Gtk.Menu();
		menu.append(menu_item1);
		menu.append(menu_item2);
		ind.set_menu(menu);
	}
}
