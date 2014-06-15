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
    private class IconTheme : GLib.Object {
        /**
         * This is the absolute path to the theme directory, NOT to the
         * 'index.theme' file of the theme.
        **/
        private string path;
        
        /**
         * If the IconTheme is valid.
         * The theme is not valid if no index.theme exists or it is
         * malformed.
        **/
        private bool valid;
        
        /**
         * This is the 'internal' name because there is also the user
         * visisble name.
         * This is the name that the icon theme directoriy has, NOT
         * the name that is set in the 'index.theme' file.
         * (which should be shown to the user)
        **/
        private string? internal_name;
        
        /**
         * This is an array of parent IconThemes.
         * Parent IconThemes are specified in the 'index.theme' file
         * in the 'Inherits=' line.
        **/
        private IconTheme[] parents;
        
        /**
         * List of sub directory that actually contain the icon files
         * of this theme.
         * These sub directories are given as groups in the
         * 'index.theme' file.
        **/
        private IconDirectory[] icon_directories;
        
        public IconTheme(string? name) {
            valid = true;
            
            internal_name = name;
            if (internal_name == null) {
                valid = false;
                return;
            }
            
            this.path = find_path();
            if (!valid) {
                return;
            }
            
            parse_index_file();
            if (!valid) {
                return;
            }
        }
        
        public void doo() { }
        
        public bool is_valid() {
            doo();
            return valid;
        }
        
        private void parse_index_file() {
            // Locate path for index.theme file
            string index_path;
            if (path.to_utf8()[path.length-1] != '/') {
                index_path = string.join("", path, "/index.theme");
            } else {
                index_path = string.join("", path, "index.theme");
            }
            
            //Open KeyFile
            GLib.KeyFile kf = new GLib.KeyFile();
            try {
                kf.load_from_file(index_path, GLib.KeyFileFlags.NONE);
            } catch (KeyFileError e) {
                string error_str = "";
                error_str += "Error occured while scanning index.theme of icon theme.\n";
                error_str += "Icon theme: \"" +internal_name +"\"\n";
                error_str += "KeyFileError: \"" +e.message +"\"\n";
                error_str += "Ignoring icon theme including all icons ...\n";
                print_error(error_str);
                valid = false;
                return;
            } catch (FileError e) {
                string error_str = "";
                error_str += "Error occured while scanning index.theme of icon theme.\n";
                error_str += "Icon theme: \"" +internal_name +"\"\n";
                error_str += "FileError: \"" +e.message +"\"\n";
                error_str += "Ignoring icon theme including all icons ...\n";
                print_error(error_str);
                valid = false;
                return;
            }
            
            // If KeyFile does not have the top group '[Icon Theme]'
            // it is not valid.
            if (!kf.has_group("Icon Theme")) {
                string error_str = "";
                error_str += "Error occured while scanning index.theme of icon theme.\n";
                error_str += "Icon theme: \"" +internal_name +"\"\n";
                error_str += "KeyValue File is not a valid index.theme file!\n";
                error_str += "KeyValue Group [Icon Theme] does not exist!\n";
                error_str += "Ignoring icon theme including all icons ...\n";
                print_error(error_str);
                valid = false;
                return;
            }
            
            string[] directories;
            
            // If KeyFile does not have the 'Directories' key inside
            // the '[Icon Theme]' group it is not valid.
            try {
                if (!kf.has_key("Icon Theme", "Directories")) {
                    string error_str = "";
                    error_str += "Error occured while scanning index.theme of icon theme.\n";
                    error_str += "Icon theme: \"" +internal_name +"\"\n";
                    error_str += "KeyValue File is not a valid index.theme file!\n";
                    error_str += "KeyValue Group [Icon Theme] does not contain key \"Directories\"!\n";
                    error_str += "Ignoring icon theme including all icons ...\n";
                    print_error(error_str);
                    valid = false;
                    return;
                }
                directories = kf.get_string("Icon Theme", "Directories").split(",");
            } catch (KeyFileError e) {
                string error_str = "";
                error_str += "Error occured while scanning index.theme of icon theme.\n";
                error_str += "Icon theme: \"" +internal_name +"\"\n";
                error_str += "Could not access KeyValue File!\n";
                error_str += "KeyFileError: \"" +e.message +"\"\n";
                error_str += "Ignoring icon theme including all icons ...\n";
                print_error(error_str);
                valid = false;
                return;
            }
            
            // Scan for parent icon themes
            // A theme does not need to have parents set.
            try {
                List<IconTheme> parents_l = new List<IconTheme>();
                if (kf.has_key("Icon Theme", "Inherits")) {
                    string p = kf.get_string("Icon Theme", "Inherits");
                    string[] parents = p.split(",");
                    for (int i = 0; i < parents.length; i++) {
                        string parent = parents[i];

                        // We ignore the hicolor theme.
                        // This is against the standard, but we still
                        // do this to prevent not finding an icon theme
                        // if a theme has hicolor as an explicit parent.
                        // We will manually look in the hicolor theme after
                        // we've searched the last theme.
                        if (parent != "hicolor") {
                            IconTheme newTheme = new IconTheme(parent);
                            if (newTheme.is_valid()) {
                                parents_l.append(newTheme);
                            }
                        }
                    }
                }
                this.parents = new IconTheme[parents_l.length()];
                for (int i = 0; i < parents_l.length(); i++) {
                    this.parents[i] = parents_l.nth_data(i);
                }
            } catch (KeyFileError e) {
                string error_str = "";
                error_str += "Error occured while scanning index.theme of icon theme.\n";
                error_str += "Icon theme: \"" +internal_name +"\"\n";
                error_str += "Could not access KeyValue File!\n";
                error_str += "KeyFileError: \"" +e.message +"\"\n";
                error_str += "Ignoring icon theme including all icons ...\n";
                print_error(error_str);
                valid = false;
                return;
            }
            
            // Create an IconDirectory from every directory group
            // with the corresponding keys (and key values).
            
            // Create File for IconTheme directory, which we need
            // to get the path for sub directories.
            GLib.File parent_dir = GLib.File.new_for_path(this.path);
            
            // We create a list of sub directories,
            // that we later convert to an array
            List<IconDirectory> icon_directories_l = new List<IconDirectory>();
            
            // We look at every 'directory' group,
            // take all its keys and the corresponding key values
            // and add them to a mx2 matrix.
            // We then create an Object out of that matrix.
            for (int i = 0; i < directories.length; i++) {
                string[] keys;
                try {
                    // If an item in the 'Directory' list does not
                    // exist as a group in this KeyValue File we ignore
                    // that item.
                    if (!kf.has_group(directories[i])) {
                        continue;
                    } else {
                        keys = kf.get_keys(directories[i]);
                    }
                } catch (KeyFileError e) {
                    string error_str = "";
                    error_str += "Error occured while scanning index.theme of icon theme.\n";
                    error_str += "Icon theme: \"" +internal_name +"\"\n";
                    error_str += "Could not access KeyValue File!\n";
                    error_str += "KeyFileError: \"" +e.message +"\"\n";
                    error_str += "Ignoring icon theme including all icons ...\n";
                    print_error(error_str);
                    valid = false;
                    return;
                }
                
                // Create mx2 Matrix
                string[,] key_value_matrix = new string[keys.length, 2];
                
                // Add all properties of directory
                for (int p = 0; p < keys.length; p++) {
                    string val = null;
                    try {
                        val = kf.get_string(directories[i], keys[p]);
                    } catch (KeyFileError e) {
                        string error_str = "";
                        error_str += "Error occured while scanning index.theme of icon theme.\n";
                        error_str += "Icon theme: \"" +internal_name +"\"\n";
                        error_str += "Could not access KeyValue File!\n";
                        error_str += "KeyFileError: \"" +e.message +"\"\n";
                        error_str += "Ignoring icon theme including all icons ...\n";
                        print_error(error_str);
                        valid = false;
                        return;
                    }
                    
                    key_value_matrix[p, 0] = keys[p];
                    key_value_matrix[p, 1] = val;
                }
                
                // Get absolut path for sub directory
                GLib.File child_dir_f = parent_dir.resolve_relative_path(directories[i]);
                string child_dir = child_dir_f.get_parse_name();
                
                // Create IconDirectory object and add it to the directory
                // list if its valid.
                IconDirectory ic_dir = new IconDirectory(
                                        key_value_matrix,
                                        child_dir);
                
                if (ic_dir.is_valid()) {
                    icon_directories_l.append(ic_dir);
                }
            }
            
            // Sort list by maximum icon size
            CompareFunc<IconDirectory> sortFunc = (a, b) => {
                // This sort function actually returns 1 when it should
                // return -1 and vice versa.
                // This is so we can easily sort our list with
                // in descending order.
                int size_a = a.maximum_size();
                int size_b = b.maximum_size();
                
                if (size_a < size_b) {
                    return 1;
                } else if (size_a == size_b) {
                    return 0;
                } else {
                    return -1;
                }
            };
            icon_directories_l.sort(sortFunc);
            
            // Convert list to array
            icon_directories = new IconDirectory[icon_directories_l.length()];
            for (int i = 0; i < icon_directories_l.length(); i++) {
                icon_directories[i] = icon_directories_l.nth_data(i);
            }
        }
        
        private string? find_path() {
            // Go through every base dir in list of base dirs
            foreach (string d in IconThemeBaseDirectories.get_theme_base_directories()) {
                
                GLib.File base_dir = GLib.File.new_for_path(d);
                
                // Check if any sub directory of this base dir has the
                // name of this theme.
                // If we found the correct sub directory we return
                // its path.
                try {
                    FileEnumerator child_enum = base_dir.enumerate_children(
                                    "*",
                                    GLib.FileQueryInfoFlags.NONE);
                    
                    GLib.FileInfo child_info;
                    while ((child_info = child_enum.next_file()) != null) {
                        string child_name = child_info.get_name();
                        
                        if (child_name == this.internal_name) {
                            GLib.File child_file = base_dir.resolve_relative_path(child_name);
                            return child_file.get_path();
                        }
                    }
                } catch (Error e) {
                    string warn_str = "";
                    warn_str += "Error occured while looking";
                    warn_str += " for the path of theme";
                    warn_str += " '" +internal_name +"'\n";
                    warn_str += "Could not scan sub directories !\n";
                    warn_str += "Error: " +e.message;
                    warn_str += "Ignoring icon theme ...\n";
                    print_warning(warn_str);
                    valid = false;
                    return null;
                }
            }
            
            string warn_str = "";
            warn_str += "Error occured while looking";
            warn_str += " for the path of theme";
            warn_str += " \"" +internal_name +"\"\n";
            warn_str += "Could not find theme dir !\n";
            warn_str += "Ignoring icon theme ...\n";
            print_warning(warn_str);
            valid = false;
            return null;
        }
        
        public string? get_icon(string name, bool ignore_svg = false) {
            // Look in all directories of this current theme for the specified
            // icon.
            foreach(IconDirectory icon_directory in icon_directories) {
                // We ignore directories containing svg if we don't
                // support them.
                if (ignore_svg && icon_directory.is_scalable()) {
                    continue;
                }
                
                string? icon_path = icon_directory.get_icon(name);
                
                if (icon_path != null) {
                    return icon_path;
                }
            }
            
            // If we haven't found the icon in the current theme we then try
            // to find it in all parent themes.
            for (int i = 0; i < parents.length; i++) {
                string icon_path = parents[i].get_icon(name, ignore_svg);
                
                if (icon_path != null) {
                    return icon_path;
                }
            }
            
            // If we haven't found the icon at all we return null
            return null;
        }
    }
    
    private class IconThemeBaseDirectories : GLib.Object {
        private static string[] icon_directories;
        
        public static string[] get_theme_base_directories() {
            if (icon_directories == null) {
                icon_directories = setup_theme_base_directories();
            }
            
            return icon_directories;
        }
        
        private static string[] setup_theme_base_directories() {
            // Create a list of base directories, because a list is
            // easier to handle.
            // We later convert that list to an array.
            List<string> base_dirs_l = new List<string>();
            string[] base_dirs;
            
            // Add '$HOME/.icons' to list of base directories
            string? home_dir = GLib.Environment.get_variable("HOME");
            if (home_dir != null) {
                if (home_dir.to_utf8()[home_dir.length-1] != '/') {
                    home_dir = string.join("", home_dir, "/.icons");
                } else {
                    home_dir = string.join("", home_dir, ".icons");
                }
                
                // Check if directory is a valid directory
                bool valid = is_valid_directory(home_dir);
                
                // Check if directory is already contained in list
                // if not, we add it.
                if (valid) {
                    bool contained = false;
                    foreach (string contained_dir in base_dirs_l) {
                        if (contained_dir == home_dir) {
                            contained = true;
                            break;
                        }
                    }
                    
                    if (!contained) {
                        base_dirs_l.append(home_dir);
                    }
                }
                
            } else {
                string warn_str = "";
                warn_str += "Error occured while scanning for directories,\n";
                warn_str += "that contain icon themes.\n";
                warn_str += "Environment variable $HOME is not set!\n";
                warn_str += "Ignoring directory '$HOME/.icons' ...\n";
                print_warning(warn_str);
            }
            
            // Add '/usr/share/icons' and '/usr/local/share/icons'
            string[] default_locations = {"/usr/share/icons", "/usr/local/share/icons"};
            foreach (string default_dir in default_locations) {
                bool valid = is_valid_directory(default_dir);
                
                // Check if directory is a valid directory
                if (valid) {
                    // Check if directory is already contained in list
                    // if not, we add it.
                    bool contained = false;
                    foreach (string contained_dir in base_dirs_l) {
                        if (contained_dir == default_dir) {
                            contained = true;
                            break;
                        }
                    }
                    
                    if (!contained) {
                        base_dirs_l.append(default_dir);
                    }
                }
            }
            
            // Add directories from XDG_DATA_DIRS to list of base
            // directories.
            string? xdg_data_dirs = GLib.Environment.get_variable("XDG_DATA_DIRS");
            if (xdg_data_dirs != null) {
                foreach (string new_dir in xdg_data_dirs.split(":")) {
                    // Append '/icons' or 'icons'
                    if (new_dir.to_utf8()[new_dir.length-1] != '/') {
                        new_dir = string.join("", new_dir, "/icons");
                    } else {
                        new_dir = string.join("", new_dir, "icons");
                    }
                    
                    // Check if directory is a valid directory
                    bool valid = is_valid_directory(new_dir);
                    
                    // Check if directory is already contained in list
                    // if not, we add it.
                    if (valid) {
                        bool contained = false;
                        foreach (string contained_dir in base_dirs_l) {
                            if (contained_dir == new_dir) {
                                contained = true;
                                break;
                            }
                        }
                        
                        if (!contained) {
                            base_dirs_l.append(new_dir);
                        }
                    }
                }
            } else {
                string warn_str = "";
                warn_str += "Error occured while scanning for directories,\n";
                warn_str += "that contain icon themes.\n";
                warn_str += "Environment variable $XDG_DATA_DIRS is not set!\n";
                warn_str += "Ignoring directory \"$XDG_DATA_DIRS/icons\" ...\n";
                print_warning(warn_str);
            }
            
            // Convert List to array
            base_dirs = new string[base_dirs_l.length()];
            for (int i = 0; i < base_dirs_l.length(); i++) {
                base_dirs[i] = base_dirs_l.nth_data(i);
            }
            
            return base_dirs;
        }
        
        private static bool is_valid_directory(string path) {
            // Check if file exists
            GLib.File file = GLib.File.new_for_path(path);
            if (!file.query_exists()) {
                string warn_str = "";
                warn_str += "Error occured while scanning for directories,\n";
                warn_str += "that contain icon themes.\n";
                warn_str += "Directory \"" +path +"\" does not exist!\n";
                warn_str += "Ignoring dir ...\n";
                print_warning(warn_str);
                return false;
            }
            
            // If file is directory it is valid
            GLib.FileType file_type = file.query_file_type(GLib.FileQueryInfoFlags.NONE);
            if (file_type == GLib.FileType.DIRECTORY) {
                return true;
            }
            
            // If file is regular file it is not valid
            if (file_type == GLib.FileType.REGULAR) {
                return false;
            }
            
            // If file is a symlink, we check if the file it is
            // linking to is valid.
            if (file_type == GLib.FileType.SYMBOLIC_LINK) {
                GLib.FileInfo file_info;
                try {
                    file_info = file.query_info("*", GLib.FileQueryInfoFlags.NONE);
                } catch (GLib.Error e) {
                    string warn_str = "";
                    warn_str += "Error occured while scanning for directories,\n";
                    warn_str += "that contain icon themes.\n";
                    warn_str += "Error occured while following symlink\n";
                    warn_str += "Ignoring dir \"" +path +"\" ...\n";
                    print_warning(warn_str);
                    return false;
                }
                
                string symlink_target = file_info.get_symlink_target();
                return is_valid_directory(symlink_target);
            }
            
            // This should not happen
            string error_str = "";
            error_str += "Error occured while scanning for directories,\n";
            error_str += "that contain icon themes.\n";
            error_str += "Unknown error occured in '" +path +"'\n";
            error_str += "Ignoring dir \"" +path +"\"\n";
            print_error(error_str);
            return false;
        }
    }
}
