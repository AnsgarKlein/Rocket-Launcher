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


using Gtk;

class AppIcon : Gtk.Box {
	private App app;
	private int icon_size = 100;
	
	public AppIcon(App app) {
		Object(orientation: Gtk.Orientation.VERTICAL);
		
		this.app = app;
		
		build_gui();
	}
	
	public void build_gui() {
		// ---> Basic
		base.homogeneous = false;
		
		// ---> Load Icon
		Gdk.Pixbuf scaled_image = null;
		
		//If icon is not set, we'll use some default icon
		if (app.get_icon() == null) {
			try {
				Gtk.IconTheme theme = Gtk.IconTheme.get_default();
				scaled_image = theme.load_icon("application-x-executable", icon_size, Gtk.IconLookupFlags.FORCE_SIZE);
			} catch (GLib.Error e) {
				scaled_image = null;
			}
		}
		//First try is to set the icon from the current theme
		else {
			try {
				Gtk.IconTheme theme = Gtk.IconTheme.get_default();
				scaled_image = theme.load_icon(app.get_icon(), icon_size, Gtk.IconLookupFlags.FORCE_SIZE);
			} catch (GLib.Error e) {
				scaled_image = null;
			}
		}
		
		//If that didn't work
		if (scaled_image == null) {
			//If absolut path is given we can just grab the icon
			GLib.File icon_file1 = GLib.File.new_for_path(app.get_icon());
			GLib.File icon_file2 = GLib.File.new_for_path("/usr/share/pixmaps/"+app.get_icon());
			if (icon_file1.query_exists()) {
				try {
					Gdk.Pixbuf raw_image = new Gdk.Pixbuf.from_file(app.get_icon());
					scaled_image = raw_image.scale_simple(icon_size, icon_size, Gdk.InterpType.HYPER);
				} catch  (GLib.Error e) {
					scaled_image = null;
				}
			}
			
			//(also try to search in /usr/share/pixmaps)
			else if (icon_file2.query_exists()) {
				try {
					Gdk.Pixbuf raw_image = new Gdk.Pixbuf.from_file("/usr/share/pixmaps/"+app.get_icon());
					scaled_image = raw_image.scale_simple(icon_size, icon_size, Gdk.InterpType.HYPER);
				} catch  (GLib.Error e) {
					scaled_image = null;
				}
			}
			//If Gtk.IconTheme could not set an icon or the icon is not set
			//because of another reason we'll set some default icon
			else {
				try {
					Gtk.IconTheme theme = Gtk.IconTheme.get_default();
					scaled_image = theme.load_icon("application-x-executable", icon_size, Gtk.IconLookupFlags.FORCE_SIZE);
				} catch (GLib.Error e) {
					scaled_image = null;
				}
			}
			

		}
		

		
		
		
		// ---> Setup Button
		Gtk.Button button = new Gtk.Button();
		button.clicked.connect(app.start);
		this.pack_start(button);
		
		
		
		// ---> Setup Image
		//if image is not set we won't set the button image 
		if (scaled_image != null) {
			button.set_image(new Gtk.Image.from_pixbuf(scaled_image));
		} else {
			button.set_label("no image");
		}
		
		// ---> Setup Label1
		string label1_str = app.get_name();
		if (label1_str.char_count() > 17) {
			label1_str = label1_str.slice(0, 14);
			label1_str = label1_str +"...";
		}
		
		Gtk.Label label1 = new Gtk.Label(label1_str);
		this.pack_start(label1);
		
		// ---> Setup Label2
		string label2_str = "";
		if (app.get_generic() != null) {
			label2_str = app.get_generic();
			if (label2_str.char_count() > 15) {
				label2_str = label2_str.slice(0, 12);
				label2_str = label2_str +"...";
			}
			label2_str = "(" +label2_str +")";
		}
		
		Gtk.Label label2 = new Gtk.Label(label2_str);
		this.pack_start(label2);
		

		// ---> Setup Tooltip
		string tooltip;
		if (app.get_generic() != null) {
			tooltip = app.get_name()+"\n"+app.get_generic()+"\n"+app.get_comment();
		} else {
			tooltip = app.get_name()+"\n"+app.get_comment();
		}
		button.set_tooltip_text(tooltip);

	}
}
