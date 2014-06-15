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
    enum dbus_request {
        show,
        hide,
        toggle
    }
    
    [DBus (name = "org.launcher.rocket")]
    interface DBusManagerInterface : Object {
        public abstract bool send(RocketLauncher.dbus_request request) throws IOError;
    }
    
    [DBus (name = "org.launcher.rocket")]
    class DBusManager : GLib.Object, DBusManagerInterface {
        MainWindow main_window;
        public DBusManager(MainWindow main_window) {
            this.main_window = main_window;
        }
        
        public bool send(dbus_request request) {
            //The compiler complains about this function never getting
            //called, but obviously we can ignore that because the function
            //will be called through D-Bus.
            
            switch (request) {
            case dbus_request.show:
                main_window.show_Window();
                break;
            case dbus_request.hide:
                main_window.hide_Window();
                break;
            case dbus_request.toggle:
                main_window.toggle_visibiliy();
                break;
            }
            
            return true;
        }
        
        
    }
}
