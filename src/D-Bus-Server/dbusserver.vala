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


[DBus (name = "org.launcher.panzerfaust")]
class DBusServer {
	MainWindow mainWindow;
	public DBusServer(MainWindow mainWindow) {
		this.mainWindow = mainWindow;
	}
	
	public bool send(dbus_request request) {
		//The compiler complains about this function never getting
		//called, but obviously we can ignore that because the function
		//will be called through D-Bus.
		
		
		//when true: print line on incoming dbus request
		bool debug = false;
		
		
		if (debug) stdout.printf("Incoming D-Bus request:\t");
		
		switch (request) {
		case dbus_request.show:
			if (debug) stdout.printf("show-window\n");
			
			mainWindow.show_Window();
			break;
		case dbus_request.hide:
			if (debug) stdout.printf("hide-window\n");
			
			mainWindow.hide_Window();
			break;
		}
		
		/**bool error = false;
		if (error) {
			return false;
		}**/
		
		return true;
	}
	
}

enum dbus_request {
	show,
	hide
}
