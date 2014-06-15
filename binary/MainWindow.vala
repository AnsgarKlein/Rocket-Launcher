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
    class MainWindow : Gtk.Window {
        private AppGrid app_grid;
        private Gtk.ScrolledWindow scrolled;
        private Gtk.Entry search_entry;
        
        private AppIcon[] app_icons;
        private ApplicationHandler application_handler;
        
        private const int border_size = 25;
        
        public MainWindow() {
            Object(type: Gtk.WindowType.TOPLEVEL);
            
            // Set application icon
            set_application_icon();
            
            // Refresh application icon if style changes
            base.style_set.connect(set_application_icon);
            
            // Create ApplicationHandler
            application_handler = new ApplicationHandler();
            
            App[] apps = application_handler.get_apps();
            
            this.app_icons = new AppIcon[apps.length];
            for (int i = 0; i < apps.length; i++) {
                app_icons[i] = new AppIcon(apps[i]);
            }
            
            // Setup Gui
            build_gui();
            
            //Setup Signals
            
            // Refresh AppGrid if selection of apps to show changed
            application_handler.selection_changed.connect( () => {
                // Receive indices for apps to add
                int[] selection = application_handler.get_selected_apps();
                
                // Remove all elements from AppGrid
                app_grid.clear();
                
                // Add selected apps back to AppGrid
                for (int i = 0; i < selection.length; i++) {
                    app_grid.add(app_icons[selection[i]]);
                }
            } );
            
            
            // Hide window on delete_event (don't delete it)
            this.delete_event.connect( () => {
                hide_Window();
                return true;
            } );
            
            // Hide window if escape is pressed
            base.key_press_event.connect( (k) => {
                if (Gdk.Key.Escape == k.keyval) {
                    hide_Window();
                    return true;
                } else {
                    return false;
                }
            } );
            
            // Hide window if it loses focus
            base.focus_out_event.connect( () => {
                hide_Window();
                return true;
            } );
        }
        
        private void set_application_icon() {
            try {
                base.set_icon(Gtk.IconTheme.get_default().load_icon(Constants.application_icon, 256, 0));
            } catch (Error e) {
                string warn_str = "";
                warn_str += "Error occured while trying to set the application icon.\n";
                warn_str += "Error: " +e.message +"\n";
                warn_str += "Icon: " +Constants.application_icon +"\n";
                warn_str += "Using fallback icon ...\n";
                print_warning(warn_str);
                try {
                    base.set_icon(Gtk.IconTheme.get_default().load_icon(Constants.fallback_icon, 256, 0));
                } catch (Error e) {
                    string err_str = "";
                    err_str += "Error occured while trying to set the application icon.\n";
                    err_str += "Error: " +e.message +"\n";
                    err_str += "Icon: " +Constants.fallback_icon +"\n";
                    err_str += "Can not set application icon ...\n";
                    print_error(err_str);
                }
            }
        }
        
        private void build_gui() {
            base.set_title(Constants.application_name);
            base.set_position(Gtk.WindowPosition.CENTER);
            base.set_decorated(false);
            base.set_keep_above(true);
            base.set_deletable(false);
            base.set_default_size(750, 600);
            base.set_border_width(border_size);
            
            // Prerequesites for transparency and cairo drawing in general
            base.set_app_paintable(true);
            base.set_visual(screen.get_rgba_visual());
            
            // On draw event: draw window semi transparent
            base.draw.connect(on_draw);
            
            // Create main grid
            Gtk.Grid outer_grid = new Gtk.Grid();
            outer_grid.set_column_homogeneous(false);
            outer_grid.set_row_homogeneous(false);
            
            // Create scrolled area
            scrolled = new Gtk.ScrolledWindow(null, null);
            scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
            outer_grid.attach(scrolled, 0, 0, 1, 2);
            
            // Create AppGrid
            app_grid = new AppGrid();
            foreach (AppIcon app_icon in app_icons) {
                app_grid.add(app_icon);
            }
            app_grid.set_hexpand(true);
            scrolled.add_with_viewport(app_grid);
            
            // Create search entry
            search_entry = new Gtk.Entry();
            search_entry.activate.connect( () => {
                application_handler.filter_string(search_entry.get_text());
            } );
            search_entry.changed.connect( () => {
                string text;
                if ((text = search_entry.get_text()) == "") {
                    application_handler.filter_all();
                } else {
                    application_handler.filter_string(search_entry.get_text());
                }
            } );
            outer_grid.attach(search_entry, 1, 0, 1, 1);
            
            // Create category buttons
            Gtk.Box button_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            button_box.set_spacing(1);
            button_box.set_vexpand(true);
            outer_grid.attach(button_box, 1, 1, 1, 1);
            
            for (int i = 0; i < 14; i++) {
                CategoryButton category_button;
                category_button = new CategoryButton(Constants.category_button_names[i],
                                                     Constants.category_button_values[i]);
                
                category_button.set_relief(Gtk.ReliefStyle.NONE);
                category_button.category_button_press_event.connect( (category) => {
                    search_entry.set_text("");
                    application_handler.filter_categorie(category);
                } );
                
                button_box.add(category_button);
            }
            
            
            this.add(outer_grid);
        }
        
        public void toggle_visibiliy() {
            if (this.get_visible()) {
                hide_Window();
            } else {
                show_Window();
            }
        }
        
        public void show_Window() {
            //Show the application window
            this.show_all();
        }
        
        public void hide_Window() {
            // Hide the application window
            
            // Make sure the window looks exactly as if the application
            // had just started.
            // We do all this before we hide the window and not before we
            // show it again! (To reduce time to show window)
            application_handler.filter_all();
            scrolled.get_vadjustment().set_value(0);
            search_entry.set_text("");
            search_entry.grab_focus();
            
            this.hide();
        }
        
        public void exit_program() {
            // Kill the Gtk loop which is the main loop of the
            // application at the same time
            // ==> we quit the application
            Gtk.main_quit();
        }
        
        private bool on_draw(Cairo.Context ctx) {
            // Draw everywhere on window
            ctx.set_source_rgba(Constants.bg_color[0], Constants.bg_color[1],
                                Constants.bg_color[2], Constants.bg_color[3]);
            ctx.set_operator(Cairo.Operator.SOURCE);
            ctx.paint();
            
            if (Gdk.Screen.get_default().is_composited()) {
                const double PI = 3.1415926535897932384626433832795028841971693993751058;
                int height = this.get_window().get_height();
                int width = this.get_window().get_width();
                
                // Make corners transparent
                ctx.set_source_rgba(0.0, 0.0, 0.0, 0.0);
                ctx.rectangle(0, 0, border_size, border_size);
                ctx.rectangle(0, height - border_size, border_size, border_size);
                ctx.rectangle(width - border_size, 0, border_size, border_size);
                ctx.rectangle(width - border_size, height - border_size, border_size, border_size);
                ctx.fill();
                
                // Paint gradient over sides
                {
                    int[, ] linear = new int[4, 4];
                    linear[0, 0] = 0;
                    linear[0, 1] = border_size;
                    linear[0, 2] = 0;
                    linear[0, 3] = 0;
                    
                    linear[1, 0] = 0;
                    linear[1, 1] = height - border_size;
                    linear[1, 2] = 0;
                    linear[1, 3] = height;
                    
                    linear[2, 0] = border_size;
                    linear[2, 1] = 0;
                    linear[2, 2] = 0;
                    linear[2, 3] = 0;
                    
                    linear[3, 0] = width - border_size;
                    linear[3, 1] = 0;
                    linear[3, 2] = width;
                    linear[3, 3] = 0;
                    
                    int[, ] rect = new int[4, 4];
                    rect[0, 0] = border_size;
                    rect[0, 1] = 0;
                    rect[0, 2] = width - (2 * border_size);
                    rect[0, 3] = border_size;
                    
                    rect[1, 0] = border_size;
                    rect[1, 1] = height - border_size;
                    rect[1, 2] = width - (2 * border_size);
                    rect[1, 3] = border_size;
                    
                    rect[2, 0] = 0;
                    rect[2, 1] = border_size;
                    rect[2, 2] = border_size;
                    rect[2, 3] = height - (2 * border_size);
                    
                    rect[3, 0] = width - border_size;
                    rect[3, 1] = border_size;
                    rect[3, 2] = border_size;
                    rect[3, 3] = height - (2 * border_size);
                    
                    for (int i = 0; i < 4; i++) {
                        Cairo.Pattern pattern = new Cairo.Pattern.linear(
                            linear[i, 0],
                            linear[i, 1],
                            linear[i, 2],
                            linear[i, 3]);
                        
                        pattern.add_color_stop_rgba(
                            0.3,
                            Constants.bg_color[0],
                            Constants.bg_color[1],
                            Constants.bg_color[2],
                            Constants.bg_color[3]);
                        
                        pattern.add_color_stop_rgba(
                            1.0,
                            Constants.bg_color[0],
                            Constants.bg_color[1],
                            Constants.bg_color[2],
                            0.0);
                        
                        ctx.rectangle(
                            rect[i, 0],
                            rect[i, 1],
                            rect[i, 2],
                            rect[i, 3]);
                        
                        ctx.set_source(pattern);
                        ctx.fill();
                    }
                }
                
                // Paint gradient over corners
                {
                    int[, ] radial = new int[4, 6];
                    radial[0, 0] = border_size;
                    radial[0, 1] = border_size;
                    radial[0, 2] = 0;
                    radial[0, 3] = border_size;
                    radial[0, 4] = border_size;
                    radial[0, 5] = border_size;
                    
                    radial[1, 0] = width - border_size;
                    radial[1, 1] = border_size;
                    radial[1, 2] = 0;
                    radial[1, 3] = width - border_size;
                    radial[1, 4] = border_size;
                    radial[1, 5] = border_size;
                    
                    radial[2, 0] = border_size;
                    radial[2, 1] = height - border_size;
                    radial[2, 2] = 0;
                    radial[2, 3] = border_size;
                    radial[2, 4] = height - border_size;
                    radial[2, 5] = border_size;
                    
                    radial[3, 0] = width - border_size;
                    radial[3, 1] = height - border_size;
                    radial[3, 2] = 0;
                    radial[3, 3] = width - border_size;
                    radial[3, 4] = height - border_size;
                    radial[3, 5] = border_size;
                    
                    int[, ] position = new int[4, 2];
                    position = {
                        { border_size,          border_size },
                        { width - border_size,  border_size },
                        { border_size,          height - border_size },
                        { width - border_size,  height - border_size }
                    };
                    
                    double[, ] arc = new double[4, 5];
                    arc[0, 0] = border_size;
                    arc[0, 1] = border_size;
                    arc[0, 2] = border_size;
                    arc[0, 3] = 1.0 * PI;
                    arc[0, 4] = 1.5 * PI;
                    
                    arc[1, 0] = width - border_size;
                    arc[1, 1] = border_size;
                    arc[1, 2] = border_size;
                    arc[1, 3] = 1.5 * PI;
                    arc[1, 4] = 2.0 * PI;
                    
                    arc[2, 0] = border_size;
                    arc[2, 1] = height - border_size;
                    arc[2, 2] = border_size;
                    arc[2, 3] = 0.5 * PI;
                    arc[2, 4] = 1.0 * PI;
                    
                    arc[3, 0] = width - border_size;
                    arc[3, 1] = height - border_size;
                    arc[3, 2] = border_size;
                    arc[3, 3] = 0;
                    arc[3, 4] = 0.5 * PI;
                    
                    for (int i = 0; i < 4; i++) {
                        Cairo.Pattern pattern = new Cairo.Pattern.radial(
                            radial[i, 0],
                            radial[i, 1],
                            radial[i, 2],
                            radial[i, 3],
                            radial[i, 4],
                            radial[i, 5]);
                        
                        pattern.add_color_stop_rgba(
                            0.3,
                            Constants.bg_color[0],
                            Constants.bg_color[1],
                            Constants.bg_color[2],
                            Constants.bg_color[3]);
                            
                        pattern.add_color_stop_rgba(
                            1.0,
                            Constants.bg_color[0],
                            Constants.bg_color[1],
                            Constants.bg_color[2],
                            0.0);
                        
                        ctx.move_to(position[i, 0], position[i, 1]);
                        ctx.arc(
                            arc[i, 0],
                            arc[i, 1],
                            arc[i, 2],
                            arc[i, 3],
                            arc[i, 4]);
                        ctx.set_source(pattern);
                        ctx.fill();
                    }
                }
                
            }
            
            return false;
        }
    }
}
