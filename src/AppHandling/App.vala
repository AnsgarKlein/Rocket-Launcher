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


class App {
	private string app_name;
	private string? app_generic_name = null;
	private string app_exec;
	private string[]? app_categories = null;
	private string app_comment;
	private string? app_icon = null;
	private string? app_path = null;
	private bool app_terminal;
	
	
	private bool valid = true;
	
	public App(string desktopfile) {
		parse_file(desktopfile);
	}
	
	public string get_name()			{ return app_name;			}
	public string? get_generic()		{ return app_generic_name;	}
	public string[]? get_categories()	{ return app_categories;	}
	public string get_comment()		{ return app_comment;		}
	public string? get_icon()			{ return app_icon;			}
	
	private void parse_file(string path) {
		//Open KeyFile
		GLib.KeyFile kf = new GLib.KeyFile();
		try {
			kf.load_from_file(path, GLib.KeyFileFlags.NONE);
		}
		catch (KeyFileError e) {
			stderr.printf("\nError Occured while scanning DesktopFile\n");
			stderr.printf("File path: %s\n", path);
			stderr.printf("KeyFileError: %s\n",e.message);
			valid = false;
			return;
		}
		catch (FileError e) {
			stderr.printf("\nError Occured while scanning DesktopFile\n");
			stderr.printf("File path: %s\n", path);
			stderr.printf("FileError: %s\n",e.message);
			valid = false;
			return;
		}
		
		//Test if KeyFile is valid & load keys
		try {
			if (!kf.has_group("Desktop Entry")) {
				stderr.printf("KeyValue File is not a valid .desktop file\n");
				stderr.printf("KeyValue  Group [Desktop Entry] does not exist\n");
				stderr.printf("Path: %s\n", path);
				stderr.printf("ignoring file ...\n");
				valid = false;
				return;
			}
			
			// --- <Name>
			try {
				app_name = kf.get_value("Desktop Entry", "Name");
			} catch (KeyFileError e) {
				stderr.printf("\nKeyValue File is not a valid .desktop file\n");
				stderr.printf("KeyValue 'Name' does not exist\n");
				stderr.printf("Path: %s\n", path);
				stderr.printf("ignoring file ...\n");
				valid = false;
				return;
			}
			
			// --- <Type>
			if (!kf.has_key("Desktop Entry", "Type") || kf.get_value("Desktop Entry", "Type") != "Application") {
				stderr.printf("\nKeyValue File is not a valid .desktop file\n");
				stderr.printf("KeyValue 'Name' does not exist or does not equal 'Application'\n");
				stderr.printf("Path: %s\n", path);
				stderr.printf("ignoring file ...\n");
				valid = false;
				return;
			}
			
			// --- <Exec>
			try {
				app_exec = kf.get_value("Desktop Entry", "Exec");
			} catch (KeyFileError e) {
				stderr.printf("\nKeyValue File is not a valid .desktop file\n");
				stderr.printf("KeyValue 'Exec' does not exist\n");
				stderr.printf("Path: %s\n", path);
				stderr.printf("ignoring file ...\n");
				valid = false;
				return;
			}
			
			// --- <NoDisplay>
			if (kf.has_key("Desktop Entry", "NoDisplay")) {
				if (kf.get_value("Desktop Entry", "NoDisplay") == "true") {
					valid = false;
					return;
				}
			}
			
			// --- <Hidden>
			if (kf.has_key("Desktop Entry", "Hidden")) {
				if (kf.get_value("Desktop Entry", "Hidden") == "true") {
					valid = false;
					return;
				}
			}
			
			// --- <GenericName>
			try {
				app_generic_name = kf.get_value("Desktop Entry", "GenericName");
			} catch (KeyFileError e) {
				
			}
			
			// --- <Comment>
			try {
				app_comment = kf.get_value("Desktop Entry", "Comment");
			} catch (KeyFileError e) {
				
			}
			
			// --- <Icon>
			try {
				app_icon = kf.get_value("Desktop Entry", "Icon");
			} catch (KeyFileError e) {
				
			}
			
			// --- <Categories>
			try {
				app_categories = kf.get_value("Desktop Entry", "Categories").split_set(";", 0);
			} catch (KeyFileError e) {
				
			}
			
			// --- <Path>
			try {
				app_path = kf.get_value("Desktop Entry", "Path");
			} catch (KeyFileError e) {
				
			}
			
			// --- <Terminal>
			if (kf.has_key("Desktop Entry", "Terminal")) {
				if (kf.get_value("Desktop Entry", "Terminal") == "true") {
					app_terminal = true;
				}
			}
			
		}
		catch (KeyFileError e) {
			stderr.printf("\nError occured in KeyFile\n");
			stderr.printf("File: %s\n", path);
			stderr.printf("KeyFileError: %s\n", e.message);
			valid = false;
			return;
		}
		
	}
	
	public bool is_valid() {
		return valid;
	}
	
	public void start() {
		//FIXME:
		// - Pay attention to applications with "Terminal" flag set to "true"
		// - Pay attention to applications with "Path" flag set
		// - Pay attention to applications with "TryExec" flag set
		
		//Remove unused arguments specified in desktopFiles,
		//which confuse spawn_command_line_async() method
		//
		//These are not arguments to be given to the programm,
		//but hints for programms managing desktopFiles what
		//types of data this programm can open.
		//
		//We should NOT pass these values to the programm.
		string exec_string = this.app_exec;
		string[] asd = {"%f", "%F", "%u", "%U", "%d", "%D", "%n", "%N", "%i", "%c", "%k", "%v", "%m"};
		foreach (string str in asd) {
			exec_string = exec_string.replace(str, "");
		}
		
		//Start program
		try {
			
			GLib.Pid pid;
			string[] argvp;
			try {
				GLib.Shell.parse_argv(exec_string, out argvp);
			} catch (GLib.ShellError e) {
				stderr.printf("Could not parse execution string for '%s'\n", app_name);
				argvp = {null};
			}
			
			GLib.Process.spawn_async_with_pipes(app_path,
									argvp,
									GLib.Environ.get(),
									SpawnFlags.SEARCH_PATH |
									SpawnFlags.STDOUT_TO_DEV_NULL |
									SpawnFlags.STDERR_TO_DEV_NULL,
									null,
									out pid,
									null,
									null,
									null);
									
		} catch (SpawnError e) {
			stderr.printf("\nError Occured while spawning process\n");
			stderr.printf("SpawnError: %s\n", e.message);
		}
	}
}
