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
	//Print help
	if (args[1] == "--help" || args[1] == "-h") {
		stdout.printf("  -h, --help\t\tPrint this help and exit\n");
		stdout.printf("  -m, --minimized\tStart the application minimized (to notification area)\n");
		return 0;
	}
	
	
	//Check if D-Bus daemon is running
	bool service_exists = false;
	GLib.MainLoop temp_loop = new GLib.MainLoop();
	
	GLib.Bus.watch_name(BusType.SESSION,
				"org.launcher.panzerfaust",
				BusNameWatcherFlags.AUTO_START,
				() => {
					service_exists = true;
					temp_loop.quit();
					},
				() => {
					service_exists = false;
					temp_loop.quit();
				}
				);
				
	temp_loop.run();
	
	
	//if the D-Bus daemon is not yet running, we start it
	if (!service_exists) {
		stdout.printf("D-Bus server is not running yet\n");
		stdout.printf("trying to start it ....\n");
		
		try {
			string[] argv = {"panzerfaust-launcher-daemon", ""};
			if (args[1] == "--minimized" || args[1] == "-m") {
				argv[1] = "--minimized";
			} else {
				argv[1] = "--maximized";
			}
			string[] envv = Environ.get();
			int child_pid;
			int child_stdin_fd;
			int child_stdout_fd;
			int child_stderr_fd;
			
			GLib.Process.spawn_async_with_pipes(
				".",
				argv,
				envv,
				SpawnFlags.SEARCH_PATH,
				null,
				out child_pid,
				out child_stdin_fd,
				out child_stdout_fd,
				out child_stderr_fd);
			
		} catch (SpawnError e) {
			stdout.printf("no success, sorry :(");
			stdout.printf("Error Message: %s\n", e.message);
			return 1;
		}
		stdout.printf("success\n");
		
		
		return 0;
	}
	
	
	//if the D-Bus server is already running, we notify it to show its window
	DBus_Server dbus_server = null;
	try {
		dbus_server = GLib.Bus.get_proxy_sync(BusType.SESSION,
									"org.launcher.panzerfaust",
									"/org/launcher/panzerfaust",
									GLib.DBusProxyFlags.NONE,
									null);
		
		
		//Send request
		if (dbus_server.send(dbus_request.show)) {
			return 0;
		} else {
			stdout.printf("Error while telling application to show its window\n");
			return 1;
		};
		
	} catch (IOError e) {
		stderr.printf("Error while connecting to dbus\n");
		stderr.printf("Message: %s\n", e.message);
		return 1;
	}
}
