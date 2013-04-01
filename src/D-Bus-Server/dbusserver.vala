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
		stdout.printf("Incoming D-Bus request: ");
		
		switch (request) {
		case dbus_request.show:
			stdout.printf("show-window\n");
			mainWindow.show_Window();
			break;
		case dbus_request.hide:
			stdout.printf("hide-window\n");
			mainWindow.hide_Window();
			break;
		}
		
		bool error = false;
		if (error) {
			error_response("Unknown Error!");
			return false;
		}
		
		error_response("");
		return true;
	}
	
	public signal void error_response(string return_msg);
}

enum dbus_request {
	show,
	hide
}
