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


static void main(string[] args) {
	//Check if D-Bus server is running
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
	
	
	//if the D-Bus server is not yet running, we start it
	if (!service_exists) {
		stdout.printf("D-Bus server is not running yet\n");
		stdout.printf("trying to start it ....\n");
		
		try {
			string[] argv = {"panzerfaust-launcher-daemon", "--maximized"};
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
			return;
		}
		stdout.printf("success\n");
		
		
		return;
	}
	
	//if the D-Bus server is already running, we notify it to show its window
	GLib.MainLoop loop = new GLib.MainLoop();
	
	
	DBus_Server dbus_server = null;
	try {
		dbus_server = GLib.Bus.get_proxy_sync(BusType.SESSION,
									"org.launcher.panzerfaust",
									"/org/launcher/panzerfaust",
									GLib.DBusProxyFlags.NONE,
									null);
		
		
		//Connecting to signal pong!
		dbus_server.error_response.connect( (return_msg) => {
			stdout.printf("Daemon Response: \"%s\"\n", return_msg);
			loop.quit();
		});
		
		
		//Send request
		if (dbus_server.send(dbus_request.show)) {
			//
		} else {
			stdout.printf("Error!\n");
		};
		
	} catch (IOError e) {
		stderr.printf("Error - Message: %s\n", e.message);
	}
	loop.run();
}
