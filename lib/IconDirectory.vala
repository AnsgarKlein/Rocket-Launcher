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
    private class IconDirectory : GLib.Object {
        private int size;
        private IconDirectoryType type;
        private int max_size;
        private int min_size;
        private int threshold;
        
        private string directory;
        private GLib.Tree<string, string> icons;
        
        private bool valid;
        
        public IconDirectory(string[, ] properties, string directory_abs) {
            //
            valid = true;
            directory = directory_abs;
            icons = new GLib.Tree<string, string>((a,b) => {
                return strcmp(a, b);
            });
            
            // Set some defaults, which we will override with values
            // from matrix.
            size = -1;
            type = IconDirectoryType.Threshold;
            max_size = -1;
            min_size = -1;
            threshold = 2;
            
            // Scan all icons in given directory
            create_icon_list();
            if (!valid) {
                return;
            }
            
            // Read values from matrix
            scan_matrix(properties);
            if (!valid) {
                return;
            }
        }
        
        private void scan_matrix(string[, ] matrix) {
            for (int i = 0; i < matrix.length[0]; i++) {
                string key = matrix[i, 0].down();
                if (key == "size") {
                    size = int.parse(matrix[i, 1]);
                } else if (key == "type") {
                    string val = matrix[i, 1].down();
                    if (val == "fixed") {
                        type = IconDirectoryType.Fixed;
                    } else if (val == "scalable") {
                        type = IconDirectoryType.Scalable;
                    } else if (val == "threshold") {
                        type = IconDirectoryType.Threshold;
                    }
                } else if (key == "maxsize") {
                    max_size = int.parse(matrix[i, 1]);
                } else if (key == "minsize") {
                    min_size = int.parse(matrix[i, 1]);
                } else if (key == "threshold") {
                    threshold = int.parse(matrix[i, 1]);
                }
                
                // It is totally okay if there are other keys.
                // Most themes include a "Context=" key.
                // But we're not interested in that.
            }
            
            // The only value that is mandatory to be set is 'Size'
            if (size == -1) {
                valid = false;
                return;
            }
            
            // If 'Type' has not been set it is already set
            // to 'Threshold'.
            
            // If 'Threshold' has not been set it is already set
            // to 2.
            
            // If 'MaxSize' or 'MinSize' has not been set
            // we set it to 'Size'.
            if (max_size == -1) {
                max_size = size;
            }
            if (min_size == -1) {
                min_size = size;
            }
        }
        
        private void create_icon_list() {
            GLib.File dir = GLib.File.new_for_path(directory);
            try {
                FileEnumerator child_enum = dir.enumerate_children(
                                GLib.FileAttribute.STANDARD_NAME,
                                GLib.FileQueryInfoFlags.NONE);
                
                GLib.FileInfo child_info;
                while ((child_info = child_enum.next_file()) != null) {
                    string child_name = child_info.get_name();
                    string child_name_d = child_name.down();
                    
                    if (child_name_d.has_suffix(".png") ||
                        child_name_d.has_suffix(".svg") ||
                        child_name_d.has_suffix(".xpm")) {
                        
                        string child_name_key = child_name.slice(0, child_name.length-4);
                        
                        this.icons.insert(child_name_key, directory+"/"+child_name);
                    }
                }
            } catch (Error e) {
                // This probably means that a directory that is given
                // in the index.theme file is not present.
                // We just silently ignore this.
                valid = false;
                return;
            }
        }
        
        public bool is_valid() {
            return valid;
        }
        
        public bool is_scalable() {
            if (type == IconDirectoryType.Scalable) {
                return true;
            }
            return false;
        }
        
        public int maximum_size() {
            switch (type) {
            case IconDirectoryType.Fixed:
                return size;
            case IconDirectoryType.Scalable:
                return max_size;
            case IconDirectoryType.Threshold:
                return size+threshold;
            default:
                return 0;
            }
        }
        
        public string? get_icon(string name) {
            if (!valid) {
                return null;
            }
            
            string icon_path = null;
            bool found_icon = icons.lookup_extended(name, null, out icon_path);
            
            if (!found_icon) {
                return icon_path;
            }
            
            return null;
        }
    }
    
    private enum IconDirectoryType {
        Fixed,
        Scalable,
        Threshold;
    }
}
