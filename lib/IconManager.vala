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
    public class IconManager : GLib.Object {
        /**
         * Don't access this directly !
         * Only access it through get_current_theme()
        **/
        private static IconTheme current_theme = null;

        /**
         * This is used if the current theme does not contain the icon.
         * This is probably always 'hicolor'
        **/
        private static IconTheme fallback_theme = null;

        static construct {
            IconManager.current_theme = null;
            IconManager.fallback_theme = new IconTheme("hicolor");
        }
        
        private enum IconThemeProvider {
            X11,
            GNOME,
            LXDE,
            GTK3,
            GTK2
        }

        public IconManager() {
            //
        }
        
        private IconTheme get_current_theme() {
            lock (IconManager.current_theme) {
                // If current theme is not set at all
                // we set a new current theme.
                if (current_theme == null) {
                    // Guess the current theme
                    string? new_icon_theme = guess_current_theme_default();
                    
                    // If we could not guess the current theme
                    // we use the fallback_theme.
                    if (new_icon_theme == null) {
                        IconManager.current_theme = IconManager.fallback_theme;
                        return IconManager.current_theme;
                    }
                    
                    IconManager.current_theme = new IconTheme(new_icon_theme);
                    
                    // If we guessed the current theme and it is
                    // invalid we use the fallback theme.
                    if (current_theme.is_valid() == false) {
                        string error_str = "";
                        error_str += "Error occured while creating current icon theme.\n";
                        error_str += "Created icon theme is not valid !\n";
                        error_str += "Using empty dummy theme without icons ...\n";
                        print_error(error_str);
                        IconManager.current_theme = IconManager.fallback_theme;
                    }
                    
                    return IconManager.current_theme;
                }
            }

            // If current theme is set, we return it.
            return IconManager.current_theme;
        }
                
        private static string? guess_current_theme_default() {
            IconThemeProvider[] providers = { IconThemeProvider.X11,
                                              IconThemeProvider.LXDE,
                                              IconThemeProvider.GTK3,
                                              IconThemeProvider.GTK2,
                                              IconThemeProvider.GNOME };
            
            return guess_current_theme(providers);
        }
        
        private static string? guess_current_theme(IconThemeProvider[] providers) {            
            // Detect theme
            string? theme = null;
            foreach (IconThemeProvider provider in providers) {
                switch (provider) {
                case IconThemeProvider.X11:
                    theme = guess_current_theme_x11();
                    break;
                case IconThemeProvider.GNOME:
                    theme = guess_current_theme_gnome();
                    break;
                case IconThemeProvider.LXDE:
                    theme = guess_current_theme_lxde();
                    break;
                case IconThemeProvider.GTK3:
                    theme = guess_current_theme_gtk3();
                    break;
                case IconThemeProvider.GTK2:
                    theme = guess_current_theme_gtk2();
                    break;
                default:
                    break;
                }
                
                if (theme != null) {
                    return theme;
                }
            }
            
            string error_str = "";
            error_str += "Error occured while trying to determine current icon theme.\n";
            error_str += "Could not determine current theme!\n";
            print_error(error_str);
            return null;
        }
        
        private static string? guess_current_theme_x11() {
            // Declare some constants which we need later
            const uint8 XSETTINGS_TYPE_INT = 0;
            const uint8 XSETTINGS_TYPE_STRING = 1;
            const uint8 XSETTINGS_TYPE_COLOR = 2;
            const uint8 LSBFIRST = 0;
            const uint8 MSBFIRST = 1;
            
            // Get default display
            X.Display default_display = new X.Display(null);
            if (default_display == null) {
                string warn_str = "";
                warn_str += "Error occured while querying X11,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Could not get default X.Display !\n";
                warn_str += "Can not determine icon theme via X11 ...\n";
                print_warning(warn_str);
                return null;
            }
            
            // XGrabServer()
            default_display.flush();
            default_display.grab_server();
            default_display.flush();
            
            // Create selection for settings
            X.Atom settings_selection1;
            settings_selection1 = default_display.intern_atom("_XSETTINGS_S0", false);
            
            // Get owner window of settings selection
            X.Window settings_window;
            settings_window = default_display.get_selection_owner(settings_selection1);
            
            // Get different selection for settings
            X.Atom settings_selection2 = default_display.intern_atom("_XSETTINGS_SETTINGS", false);
            
            // Get settings property using settings_selection2 from
            // owner window of settings_selection1
            X.Atom type_atom;
            int format;
            ulong n_items;
            ulong bytes_after;
            uint8* data;
            int result;
            
            result = default_display.get_window_property(settings_window,
                                                 settings_selection2,
                                                 0,
                                                 long.MAX,
                                                 false,
                                                 settings_selection2,
                                                 out type_atom,
                                                 out format,
                                                 out n_items,
                                                 out bytes_after,
                                                 out data);
            
            // XUngrabServer()
            default_display.flush();
            default_display.ungrab_server();
            default_display.flush();
            
            if (result != X.ErrorCode.SUCCESS) {
                X.free(data);
                
                string warn_str = "";
                warn_str += "Error occured while querying X11,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "XGetWindowProperty returned an Error !\n";
                warn_str += "Can not determine icon theme via X11 ...\n";
                print_warning(warn_str);
                return null;
            }
            if (type_atom != settings_selection2 || format != 8) {
                X.free(data);
                
                string warn_str = "";
                warn_str += "Error occured while querying X11,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "XGetWindowProperty returned something wrong !\n";
                warn_str += "Can not determine icon theme via X11 ...\n";
                print_warning(warn_str);
                return null;
            }
            
            // Convert uint8* to uint8[]
            uint8[] data_ar = new uint8[n_items];
            for (ulong i = 0; i < n_items; i++) {
                data_ar[i] = *(data+i);
            }
            
            // Free original data
            X.free(data);
            
            // Create DataInputStream from data
            GLib.MemoryInputStream mem_is;
            mem_is = new GLib.MemoryInputStream.from_data(
                data_ar, (element) => {
                    X.free(element);
                });
            GLib.DataInputStream data_is = new GLib.DataInputStream(mem_is);
            
            // Read byte stream
            try {
                // Read 1B (byte-order)
                uint8 byte_order = data_is.read_byte();
                
                if (byte_order == LSBFIRST) {
                    data_is.set_byte_order(DataStreamByteOrder.LITTLE_ENDIAN);
                } else if (byte_order == MSBFIRST) {
                    data_is.set_byte_order(DataStreamByteOrder.BIG_ENDIAN);
                }
                
                // Skip 3B (unused bytes)
                data_is.skip(3);
                
                // Skip 4B (SERIAL)
                data_is.skip(4);
                
                // Read 4B (NSETTINGS)
                uint32 nsettings = data_is.read_int32();
                
                // Read all the settings
                for (int i = 0; i < nsettings; i++) {
                    uint8 type;
                    uint16 name_len;
                    string name = "";
                    
                    // Read 1B (SETTING_TYPE)
                    type = data_is.read_byte();
                    
                    // Skip 1B (unused)
                    data_is.skip(1);
                    
                    // Read 2B (name-len)
                    name_len = data_is.read_int16();
                    
                    // Read XB (name)
                    for (int p = 0; p < name_len; p++) {
                        name += ((char)data_is.read_byte()).to_string();
                    }
                    
                    // Skip XB (padding)
                    {
                        uint32 pad_len = (4 - (name_len % 4)) % 4;
                        data_is.skip(pad_len);
                    }
                    
                    // Skip 4B (last-change-serial)
                    data_is.skip(4);
                    
                    if (type == XSETTINGS_TYPE_INT) {
                        // Skip 4B (value)
                        data_is.skip(4);
                    } else if (type == XSETTINGS_TYPE_STRING) {
                        // Read 4B (value-len)
                        uint32 value_len = (uint32)data_is.read_int32();
                        
                        if (name == "Net/IconThemeName") {
                            // Read XB (value)
                            string value_str = "";
                            for (int p = 0; p < value_len; p++) {
                                value_str += ((char)data_is.read_byte()).to_string();
                            }
                            
                            return value_str;
                        } else {
                            // Skip XB (value)
                            data_is.skip(value_len);
                        }
                        
                        // Skip XB (padding)
                        uint32 pad_len = (4 - (value_len % 4)) % 4;
                        data_is.skip(pad_len);
                    } else if (type == XSETTINGS_TYPE_COLOR) {
                        // Skip 4x 2B (value)
                        data_is.skip(8);
                    }
                }
                data_is.close();
                mem_is.close();
                X.free(data);
            } catch (GLib.IOError e) {
                try { data_is.close(); } catch (Error e) { }
                try { mem_is.close(); } catch (Error e) { }
                X.free(data);
                
                string warn_str = "";
                warn_str += "Error occured while querying X11,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "X11 property stream did something wrong !\n";
                warn_str += "IOError: " +e.message +"\n";
                warn_str += "Can not determine icon theme via X11 ...\n";
                return null;
            }
            
            string warn_str = "";
            warn_str += "Error occured while querying X11,\n";
            warn_str += "in order to determine current icon theme.\n";
            warn_str += "X11 doesnt know about Net/IconThemeName property !\n";
            warn_str += "Can not determine icon theme via X11 ...\n";
            print_warning(warn_str);
            return null;
        }
        
        private static string? guess_current_theme_gnome() {
            string[] argv = new string[3];
            argv[0] = "gconftool-2";
            argv[1] = "-g";
            argv[2] = "/desktop/gnome/interface/icon_theme";
            
            string cmd_stdout = "";
            string cmd_stderr = "";
            int exit_status = 0;
            
            try {
                GLib.Process.spawn_sync(null,
                                        argv,
                                        GLib.Environ.get(),
                                        SpawnFlags.SEARCH_PATH,
                                        null,
                                        out cmd_stdout,
                                        out cmd_stderr,
                                        out exit_status);
                
            } catch (SpawnError e) {
                string warn_str = "";
                warn_str += "Error occured while querying gconftool-2,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "SpawnError: " +e.message +"\n";
                warn_str += "Can not determine icon theme via gconf (Gnome) ...\n";
                print_warning(warn_str);
                return null;
            }
            
            // If the printed value of gconftool-2 is not valid
            // we cannot determine the icon theme via gconf (Gnome)
            if (cmd_stdout == "" || cmd_stdout == null) {
                string warn_str = "";
                warn_str += "Error occured while querying gconftool-2,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Standard output of gconftool-2 is not valid!\n";
                warn_str += "Can not determine icon theme via gconf (Gnome) ...\n";
                print_warning(warn_str);
                return null;
            }
            
            // We remove newline control characters from stdout
            // and return it
            cmd_stdout = cmd_stdout.replace("\n", "");
            
            return cmd_stdout;
        }
        
        private static string? guess_current_theme_lxde() {
            // Look for location of desktop.conf file
            string? file_path = null;
            
            string session = GLib.Environment.get_variable("DESKTOP_SESSION");
            if (session == null) {
                session = "LXDE";
            }
            
            // Look for desktop.conf file
            // in $XDG_CONFIG_HOME/lxsession/$DESKTOP_SESSION/desktop.conf
            string? xdg_config_home = GLib.Environment.get_variable("XDG_CONFIG_HOME");
            if (xdg_config_home != null) {
                if (xdg_config_home.to_utf8()[xdg_config_home.length-1] != '/') {
                    file_path = string.join("", xdg_config_home, "/lxsession/", session, "/desktop.conf");
                } else {
                    file_path = string.join("", xdg_config_home, "lxsession/", session, "/desktop.conf");
                }
                
                // If desktop.conf file doesnt exists, we continue
                // searching for it.
                GLib.File file = GLib.File.new_for_path(file_path);
                if (file.query_exists() == false) {
                    file_path = null;
                }
            }
            
            // Look for desktop.conf file in all directories
            // in $XDG_CONFIG_DIRS
            if (file_path == null) {
                string[] environment_variables = GLib.Environment.get_variable("XDG_CONFIG_DIRS").split(":");
                foreach (string env in environment_variables) {
                    string? env_variable = GLib.Environment.get_variable(env);
                    
                    if (env_variable != null) {
                        if (env_variable.to_utf8()[env_variable.length-1] != '/') {
                            file_path = string.join("", env_variable, "lxsession/", session, "/desktop.conf");
                        } else {
                            file_path = string.join("", env_variable, "lxsession/", session, "/desktop.conf");
                        }
                        
                        // If desktop.conf file doesnt exists, we continue
                        // searching for it.
                        GLib.File file = GLib.File.new_for_path(file_path);
                        if (file.query_exists() == false) {
                            file_path = null;
                            continue;
                        } else {
                            break;
                        }
                    }
                }
            }
            
            // Lastly we look for desktop.conf file
            // in /etc/xdg/lxsession/$DESKTOP_SESSION/
            if (file_path == null) {
                file_path = "";
                file_path += "/etc/xdg/lxsession/";
                file_path += session;
                file_path += "/desktop.conf";
                
                GLib.File fallback_file = GLib.File.new_for_path(file_path);
                if (fallback_file.query_exists() == false) {
                    file_path = null;
                }
            }
            
            // If we did not find a file path for desktop.conf file
            // we cannot determine the icon theme via the LXDE
            // desktop.conf file.
            if (file_path == null) {
                string warn_str = "";
                warn_str += "Error occured while looking for desktop.conf file of LXDE.\n";
                warn_str += "Could not determine location of desktop.conf file!\n";
                warn_str += "Can not determine icon theme via LXDE ...\n";
                print_warning(warn_str);
                return null;
            }
            
            // Open desktop.conf file as a KeyFile
            GLib.KeyFile file = new GLib.KeyFile();
            try {
                file.load_from_file(file_path, GLib.KeyFileFlags.NONE);
            } catch (KeyFileError e) {
                string warn_str = "";
                warn_str += "Error occured while scanning desktop.conf file of LXDE,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "KeyFileError: \"" +e.message +"\"\n";
                warn_str += "Can not determine icon theme via LXDE ...\n";
                print_warning(warn_str);
                return null;
            } catch (FileError e) {
                string warn_str = "";
                warn_str += "Error occured while scanning desktop.conf file of LXDE,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "FileError: \"" +e.message +"\"\n";
                warn_str += "Can not determine icon theme via LXDE ...\n";
                print_warning(warn_str);
                return null;
            }
            
            // If file does not contain a group [GTK] we cannot use it
            // to determine icon theme
            if (!file.has_group("GTK")) {
                string warn_str = "";
                warn_str += "Error occured while scanning desktop.conf file of LXDE,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "File does not contain a [GTK] group!\n";
                warn_str += "Can not determine icon theme via LXDE ...\n";
                print_warning(warn_str);
                return null;
            }
            
            // If file does not have the 'sNet/IconThemeName' key inside
            // the '[GTK]' group we cannot use it to determine the
            // current icon theme.
            try {
                if (!file.has_key("GTK", "sNet/IconThemeName")) {
                    string warn_str = "";
                    warn_str += "Error occured while scanning desktop.conf file of LXDE,\n";
                    warn_str += "in order to determine current icon theme.\n";
                    warn_str += "Path: \"" +file_path +"\"\n";
                    warn_str += "KeyValue Group [GTK] does not contain a \"sNet/IconThemeName\" key!\n";
                    warn_str += "Can not determine icon theme via LXDE ...\n";
                    print_warning(warn_str);
                    return null;
                }
                
                // Return the set icon theme
                string icon_theme_name = file.get_string("GTK", "sNet/IconThemeName");
                return icon_theme_name;
            } catch (KeyFileError e) {
                string warn_str = "";
                warn_str += "Error occured while scanning desktop.conf file of LXDE,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "Could not access KeyValue File!\n";
                warn_str += "KeyFileError: \"" +e.message +"\"\n";
                warn_str += "Can not determine icon theme via LXDE ...\n";
                print_warning(warn_str);
                return null;
            }
        }

        private static string? guess_current_theme_gtk3() {
            // Look for location of settings.ini file
            string? file_path = null;
            
            // Look for settings.ini file in $XDG_CONFIG_HOME
            file_path = GLib.Environment.get_variable("XDG_CONFIG_HOME");
            if (file_path != null) {
                if (file_path.to_utf8()[file_path.length-1] != '/') {
                    file_path = string.join("", file_path, "/gtk-3.0/settings.ini");
                } else {
                    file_path = string.join("", file_path, "gtk-3.0/settings.ini");
                }
                
                // If settings.ini file doesnt exists, we continue
                // searching for it.
                GLib.File file = GLib.File.new_for_path(file_path);
                if (file.query_exists() == false) {
                    file_path = null;
                }
            }
            
            // Look for settings.ini file in $HOME/.config
            if (file_path == null) {
                file_path = GLib.Environment.get_variable("HOME");
                if (file_path != null) {
                    if (file_path.to_utf8()[file_path.length-1] != '/') {
                        file_path = string.join("", file_path, "/.config/gtk-3.0/settings.ini");
                    } else {
                        file_path = string.join("", file_path, ".config/gtk-3.0/settings.ini");
                    }
                    
                    // If settings.ini file doesnt exists, we continue
                    // searching for it.
                    GLib.File file = GLib.File.new_for_path(file_path);
                    if (file.query_exists() == false) {
                        file_path = null;
                    }
                }
            }
            
            // Look for settings.ini file in all directories
            // in $XDG_CONFIG_DIRS
            if (file_path == null) {
                string[] environment_variables = GLib.Environment.get_variable("XDG_CONFIG_DIRS").split(":");
                foreach (string env in environment_variables) {
                    string? env_variable = GLib.Environment.get_variable(env);
                    
                    if (env_variable != null) {
                        if (env_variable.to_utf8()[env_variable.length-1] != '/') {
                            file_path = string.join("", env_variable, "/gtk-3.0/settings.ini");
                        } else {
                            file_path = string.join("", env_variable, "gtk-3.0/settings.ini");
                        }
                        
                        // If settings.ini file doesnt exists, we continue
                        // searching for it.
                        GLib.File file = GLib.File.new_for_path(file_path);
                        if (file.query_exists() == false) {
                            file_path = null;
                            continue;
                        } else {
                            break;
                        }
                    }
                }
            }
            
            // If we did not find a file path for setting.ini file
            // we cannot determine the icon theme via the gtk3
            // settings.ini file.
            if (file_path == null) {
                string warn_str = "";
                warn_str += "Error occured while looking for settings.ini file of GTK+ 3.\n";
                warn_str += "Could not determine location of settings.ini file!\n";
                warn_str += "Can not determine icon theme via GTK+ 3 ...\n";
                print_warning(warn_str);
                return null;
            }
            
            // Parse settings.ini file
            // and look for icon theme
            
            // Open settings.ini file as a KeyFile
            GLib.KeyFile file = new GLib.KeyFile();
            try {
                file.load_from_file(file_path, GLib.KeyFileFlags.NONE);
            } catch (KeyFileError e) {
                string warn_str = "";
                warn_str += "Error occured while scanning settings.ini file of GTK+ 3,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "KeyFileError: \"" +e.message +"\"\n";
                warn_str += "Can not determine icon theme via GTK+ 3 ...\n";
                print_warning(warn_str);
                return null;
            } catch (FileError e) {
                string warn_str = "";
                warn_str += "Error occured while scanning settings.ini file of GTK+ 3,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "FileError: \"" +e.message +"\"\n";
                warn_str += "Can not determine icon theme via GTK+ 3 ...\n";
                print_warning(warn_str);
                return null;
            }
            
            // If file does not contain a group [Settings] it is malformed
            if (!file.has_group("Settings")) {
                string warn_str = "";
                warn_str += "Error occured while scanning settings.ini file of GTK+ 3,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "File is not valid because it does not contain a [Settings] group!\n";
                warn_str += "Can not determine icon theme via GTK+ 3 ...\n";
                print_warning(warn_str);
                return null;
            }
            
            // If file does not have the 'gtk-icon-theme-name' key inside
            // the '[Settings]' group we cannot use it to determine the
            // current icon theme.
            try {
                if (!file.has_key("Settings", "gtk-icon-theme-name")) {
                    string warn_str = "";
                    warn_str += "Error occured while scanning settings.ini file of GTK+ 3,\n";
                    warn_str += "in order to determine current icon theme.\n";
                    warn_str += "Path: \"" +file_path +"\"\n";
                    warn_str += "KeyValue Group [Settings] does not contain a \"gtk-icon-theme-name\" key!\n";
                    warn_str += "Can not determine icon theme via GTK+ 3 ...\n";
                    print_warning(warn_str);
                    return null;
                }
                
                // Return the set icon theme
                string icon_theme_name = file.get_string("Settings", "gtk-icon-theme-name");
                return icon_theme_name;
            } catch (KeyFileError e) {
                string warn_str = "";
                warn_str += "Error occured while scanning settings.ini file of GTK+ 3,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "Could not access KeyValue File!\n";
                warn_str += "KeyFileError: \"" +e.message +"\"\n";
                warn_str += "Can not determine icon theme via GTK+ 3 ...\n";
                print_warning(warn_str);
                return null;
            }
        }
        
        private static string? guess_current_theme_gtk2() {
            // Look for location of .gtkrc-2.0 file
            string? file_path = null;
            
            // Look for .gtkrc-2.0 file in $GTK2_RC_FILE
            file_path = GLib.Environment.get_variable("GTK2_RC_FILE");
            if (file_path != null) {
                // If .gtkrc-2.0 file doesnt exists, we continue
                // searching for it.
                GLib.File file = GLib.File.new_for_path(file_path);
                if (file.query_exists() == false) {
                    file_path = null;
                }
            }
            
            // Look for .gtkrc-2.0 file in $HOME
            if (file_path == null) {
                file_path = GLib.Environment.get_variable("HOME");
                if (file_path != null) {
                    if (file_path.to_utf8()[file_path.length-1] != '/') {
                        file_path = string.join("", file_path, "/.gtkrc-2.0");
                    } else {
                        file_path = string.join("", file_path, ".gtkrc-2.0");
                    }
                    
                    // If .gtkrc-2.0 file doesnt exists, we continue
                    // searching for it.
                    GLib.File file = GLib.File.new_for_path(file_path);
                    if (file.query_exists() == false) {
                        file_path = null;
                    }
                }
            }
            
            // If we did not find a file path for .gtkrc-2.0 file
            // we cannot determine the icon theme via the gtk2
            // .gtkrc-2.0 file.
            if (file_path == null) {
                string warn_str = "";
                warn_str += "Error occured while looking for .gtkrc-2.0 file of GTK+ 2.\n";
                warn_str += "Could not determine location of .gtkrc-2.0 file!\n";
                warn_str += "Can not determine icon theme via GTK+ 2 ...\n";
                print_warning(warn_str);
                return null;
            }
            
            
            // Parse .gtkrc-2.0 file and look for icon theme
            GLib.File file = GLib.File.new_for_path(file_path);
            GLib.FileInputStream file_i_stream;
            GLib.DataInputStream data_i_stream;
            try {
                file_i_stream = file.read();
                data_i_stream = new DataInputStream(file_i_stream);
            } catch (Error e) {
                string warn_str = "";
                warn_str += "Error occured while scanning .gtkrc-2.0 file of GTK+ 2,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "Error: \"" +e.message +"\"\n";
                warn_str += "Can not determine icon theme via GTK+ 2 ...\n";
                print_warning(warn_str);
                return null;
            }
            
            // Identify the correct line which contains
            // gtk-icon-theme-name="theme-name".
            string line;
            bool found = false;
            try {
                while ((line = data_i_stream.read_line(null)) != null) {
                    if (line.contains("gtk-icon-theme-name")) {
                        found = true;
                        break;
                    }
                }
            } catch (IOError e) {
                string warn_str = "";
                warn_str += "Error occured while scanning .gtkrc-2.0 file of GTK+ 2,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "IOError: \"" +e.message +"\"\n";
                warn_str += "Can not determine icon theme via GTK+ 2 ...\n";
                print_warning(warn_str);
                return null;
            }
            
            // If we did not find a line containing "gtk-icon-theme-name"
            // we cannot determine the icon theme via the gtk2
            // .gtkrc-2.0 file.
            if (!found) {
                string warn_str = "";
                warn_str += "Error occured while scanning .gtkrc-2.0 file of GTK+ 2,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "Could not identify value of \"gtk-icon-theme-name\"!\n";
                warn_str += "Can not determine icon theme via GTK+ 2 ...\n";
                print_warning(warn_str);
                return null;
            }
            
            // Extract theme name out of the selected line
            line = line.strip();
            
            // Remove 'gtk-icon-theme-name'
            if (line.length < 19) {
                string warn_str = "";
                warn_str += "Error occured while scanning .gtkrc-2.0 file of GTK+ 2,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "Could not identify value of \"gtk-icon-theme-name\"!\n";
                warn_str += "Can not determine icon theme via GTK+ 2 ...\n";
                print_warning(warn_str);
                return null;
            }
            line = line.substring(19, line.length-19);
            line = line.strip();
            
            // Remove '='
            if (line.length < 1) {
                string warn_str = "";
                warn_str += "Error occured while scanning .gtkrc-2.0 file of GTK+ 2,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "Could not identify value of \"gtk-icon-theme-name\"!\n";
                warn_str += "Can not determine icon theme via GTK+ 2 ...\n";
                print_warning(warn_str);
                return null;
            }
            line = line.substring(1, line.length-1);
            line = line.strip();
            
            // Remove first '"'
            if (line.length < 1) {
                string warn_str = "";
                warn_str += "Error occured while scanning .gtkrc-2.0 file of GTK+ 2,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "Could not identify value of \"gtk-icon-theme-name\"!\n";
                warn_str += "Can not determine icon theme via GTK+ 2 ...\n";
                print_warning(warn_str);
                return null;
            }
            line = line.substring(1, line.length-1);
            line = line.strip();
            
            // Remove last '"'
            if (line.length < 1) {
                string warn_str = "";
                warn_str += "Error occured while scanning .gtkrc-2.0 file of GTK+ 2,\n";
                warn_str += "in order to determine current icon theme.\n";
                warn_str += "Path: \"" +file_path +"\"\n";
                warn_str += "Could not identify value of \"gtk-icon-theme-name\"!\n";
                warn_str += "Can not determine icon theme via GTK+ 2 ...\n";
                print_warning(warn_str);
                return null;
            }
            line = line.splice(line.length-1, line.length, "");
            line = line.strip();
            
            return line;
        }
        
        public string get_icon(string name, bool ignore_svg = false) {
            string? icon_str = null;

            // We first try to get the icon from the current theme
            icon_str = get_current_theme().get_icon(name, ignore_svg);
            if (icon_str != null) {
                return icon_str;
            }

            // Then we try to get the icon from the fallback theme
            icon_str = fallback_theme.get_icon(name, ignore_svg);
            if (icon_str != null) {
                return icon_str;
            }

            // If neither the current theme (or themes it inherits from)
            // nor the fallback theme contains the icon we need we try
            // to guess the correct icon.

            // We first test if the given icon is an actual absolute path
            GLib.File icon_file = GLib.File.new_for_path(name);
            if (icon_file.query_exists()) {
                return name;
            }

            // We also search in '/usr/share/pixmaps'
            string icon_file_path = "/usr/share/pixmaps/"+name;
            icon_file = GLib.File.new_for_path(icon_file_path);
            if (icon_file.query_exists()) {
                return icon_file_path;
            }

            // If icon is not null but we still cant find it
            // we use an fallback icon
            icon_str = get_current_theme().get_icon("application-x-executable", ignore_svg);
            return icon_str;
        }
    }
}
