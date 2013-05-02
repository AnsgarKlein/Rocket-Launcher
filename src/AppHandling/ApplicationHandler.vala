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


class ApplicationHandler {
	
	private string[] directories;
	private string[] directories_fallback = { "/usr/share/applications",
											"/usr/local/share/applications",
											GLib.Environment.get_home_dir()
											+"/.local/share/applications" };
	
	private List<App> apps;
	private List<int> current_apps;
	
	public ApplicationHandler() {
		//Select right directories to search in
		
		//If XDG_DATA_DIRS is set use all listed directories+/applications
		//to search for desktop files. Also search in some default locations
		//If XDG_DATA_DIRS is not set only search in default locations
		//Notice: It is not checked whether these directories exist, but
		//it should not be a problem if they don't. 
		string directories_environ = GLib.Environment.get_variable("XDG_DATA_DIRS");
		
		if (directories_environ != null) {
			List<string> directories_l = new List<string>();
			
			//Append values from $XDG_DATA_DIRS
			foreach (string dir in directories_environ.split(":")) {
				//Append '/' if necessary
				//then append "applications"
				if (dir.to_utf8()[dir.length-1] != '/') {
					dir = string.join("", dir, "/applications");
				} else {
					dir = string.join("", dir, "applications");
				}
				directories_l.append(dir);
			}
			
			//Append fallback values if they aren't already in list
			foreach (string fallback_dir in directories_fallback) {
				bool contains = false;
				foreach (string dir in directories_l) {
					if (fallback_dir == dir) {
						contains = true;
						break;
					}
				}
				if (!contains) {
					directories_l.append(fallback_dir);
				} else {
				}
			}
			
			//Convert List to array
			directories = new string[directories_l.length()];
			for (int i = 0; i < directories_l.length(); i++) {
				directories[i] = directories_l.nth_data(i);
			}
		} else {
			stdout.printf("XDG_DATA_DIRS is not set, falling back to defaults\n");
			directories = directories_fallback;
		}
		
		//Scan applications
		apps = new List<App>();
		scan_applications();
		
		//Select all applications as active (default)
		current_apps = new List<int>();
		filter_apps(Filter_by.ALL, null);
	}
	
	private void scan_applications() {
		//Go through all directories containing .desktop files
		foreach (string d in directories) {
			GLib.File directory = GLib.File.new_for_path(d);
			try {
				
				//Go through all files in this directory
				GLib.FileEnumerator enm = directory.enumerate_children(FileAttribute.STANDARD_NAME, 0);
				GLib.FileInfo fileInfo;
				while( (fileInfo = enm.next_file()) != null ) {
					
					string x = d+"/"+fileInfo.get_name();
					if (x.has_suffix(".desktop")) {
						//If the file has the right suffix we'll create an object
						//we wait until it parsed the file and confirmed that it is
						//valid, then we add it to the list
						App new_app = new App(x);
						if (new_app.is_vaild()) {
							apps.append(new_app);
						}
					}
					
				}
			}
			catch (Error e) {
				stderr.printf("\nError occured while scanning directories\n");
				stderr.printf("Error: \""+e.message+"\"\n");
				stderr.printf("Directory: "+d+"\n");
			}
		}
		
		//Sort list
		
		//We only sort the "apps" list (by app name)
		//That way "current_apps" will always be sorted
		apps.sort((CompareFunc)sortAppList);
	}
	
	public unowned List<App> get_apps() {
		return apps;
	}
	
	public unowned List<int> get_current_apps() {
		return current_apps;
	}
	
	public void filter_apps(Filter_by? filter, string? data) {
		// ---> if "ALL" filter is selected we'll make all apps selected
		if (filter == Filter_by.ALL) {
			//Clear current apps (index) list
			current_apps = new List<int>();
			
			//add all index to list
			for (int i=0; i<apps.length(); i++) {
				current_apps.append(i);
			}
		}
		
		// ---> if the data string is null we'll do nothing
		else if (data == null || data == "") {
			return;
		}
		
		// ---> Filter by categories
		else if (filter == Filter_by.CATEGORIES) {
			//Clear current apps (index) list
			current_apps = new List<int>();
			
			//Add index of matching apps to current apps (index) list
			for (int i = 0; i < apps.length(); i++) {
				
				App app = apps.nth_data(i);
				string[] categories = app.get_categories();
				
				for (int p = 0; p < categories.length; p++) {
					if (categories[p] == data) {
						current_apps.append(i);
						break;
					}
				}
				
			}
		}
		
		// ---> Filter by search (name, generic name, categories)
		else if (filter == Filter_by.SEARCH) {
			//Clear current apps (index) list
			current_apps = new List<int>();
			
			//Add index of matching apps to current apps (index) list
			for (int i = 0; i < apps.length(); i++) {
				
				App app = apps.nth_data(i);
				bool matched = false;
				
				// ++++++ Check for matching name
				if (app.get_name().down().contains(data.down())) {
					matched = true;
				}
				
				// ++++++ Check for matching generic name
				if (!matched) {
					string gen = app.get_generic();
					if (gen != null) {
						if (gen.down().contains(data.down())) {
							matched = true;
						}
					}
				}
				
				// ++++++ Check for matching category
				if (!matched) {
					string[] categories = app.get_categories();
					if (categories != null) {
						for (int p = 0; p < categories.length; p++) {
							if (categories[p].down().contains(data.down())) {
								matched = true;
								break;
							}
						}
					}
				}
				
				// ++++++ Add matched apps
				if (matched) {
					current_apps.append(i);
				}
			}
		}
		
		// ---> Notify
		selection_changed();
	}
	
	private static int sortAppList(App a, App b) {
		return GLib.strcmp(a.get_name(), b.get_name());
	}
	
	public signal void selection_changed();
}
