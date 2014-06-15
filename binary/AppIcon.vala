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
    class AppIcon : Gtk.Box {
        private App app;
        
        public AppIcon(App app) {
            Object(orientation: Gtk.Orientation.VERTICAL);
            
            this.app = app;
            
            build_gui();
        }
        
        public void build_gui() {
            // Basic setup
            base.homogeneous = false;
            
            // Setup button
            Gtk.Button button = new Gtk.Button();
            button.set_relief(Gtk.ReliefStyle.NONE);
            button.clicked.connect( () => {
                app.start();
                started();
            });
            this.pack_start(button);
            
            // Setup button image
            Gtk.Image image = null;
            
            string icon_path = app.get_icon_path();
            if (icon_path != null) {
                try {
                    Gdk.Pixbuf raw_image = null;
                    
                    raw_image = new Gdk.Pixbuf.from_file(icon_path);
                    
                    raw_image = raw_image.scale_simple(Constants.app_icon_size,
                                                       Constants.app_icon_size,
                                                       Gdk.InterpType.HYPER);
                    
                    image = new Gtk.Image.from_pixbuf(raw_image);
                } catch  (GLib.Error e) {
                    image = null;
                }
            }
            
            // If we have an image we set it
            if (image != null) {
                button.set_image(image);
            } else {
                button.set_label("no image");
            }
            
            // Setup app name label
            string label1_str = app.get_name();
            if (label1_str.char_count() > 17) {
                label1_str = label1_str.slice(0, 14);
                label1_str = label1_str +"...";
            }
            
            Gtk.Label label1 = new Gtk.Label(label1_str);
            this.pack_start(label1);

            // Setup tooltip
            string tooltip;
            if (app.get_generic() != null) {
                tooltip = app.get_name()+"\n"+app.get_generic()+"\n"+app.get_comment();
            } else {
                tooltip = app.get_name()+"\n"+app.get_comment();
            }
            button.set_tooltip_text(tooltip);

        }
        
        public signal void started();
    }
}
