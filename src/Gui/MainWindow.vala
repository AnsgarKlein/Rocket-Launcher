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

class MainWindow : Gtk.Window {
	private AppGrid app_grid;
	private Gtk.ScrolledWindow scrolled;
	private Gtk.Entry search_entry;
	
	private List<AppIcon> app_icon_list;
	private ApplicationHandler application_handler;
	
	private const int border_size = 25;
	
	public MainWindow() {
		Object(type: Gtk.WindowType.TOPLEVEL);
		
		//Set Application Icon
		try {
			base.set_icon(Gtk.IconTheme.get_default().load_icon(GlobalSettings.application_icon, 256, 0));
		} catch (Error e) {
			stderr.printf("Error: %s\n", e.message);
			stderr.printf("Setting application icon failed, using fallback icon...\n");
			try {
				base.set_icon(Gtk.IconTheme.get_default().load_icon(GlobalSettings.fallback_icon, 256, 0));
			} catch (Error e) {
				stderr.printf("Error: %s\n", e.message);
				stderr.printf("Setting application icon failed...\n");
			}
		}
		base.style_set.connect( () => {
			try {
				base.set_icon(Gtk.IconTheme.get_default().load_icon(GlobalSettings.application_icon, 256, 0));
			} catch (Error e) {
				stderr.printf("Error: %s\n", e.message);
				stderr.printf("Setting application icon failed, using fallback icon...\n");
				try {
					base.set_icon(Gtk.IconTheme.get_default().load_icon(GlobalSettings.fallback_icon, 256, 0));
				} catch (Error e) {
					stderr.printf("Error: %s\n", e.message);
					stderr.printf("Setting application icon failed...\n");
				}
			}
		} );
		
		
		//Setup Basic
		application_handler = new ApplicationHandler();
		foreach (App app in application_handler.get_apps()) {
			AppIcon app_icon = new AppIcon(app);
			app_icon.started.connect(this.hide_Window);
			app_icon_list.append(app_icon);
		}
		
		
		//Setup Gui
		build_gui();
		
		
		//Setup Signals
		
		//  -  Refresh app grid if selection changed
		//  -  (remove all and add appropriate)
		application_handler.selection_changed.connect( () => {
			app_grid.clear();
			
			foreach (int integer in application_handler.get_current_apps()) {
				app_grid.add(app_icon_list.nth_data(integer));
			}
		});
		
		
		//  -  Only hide window on delete_event
		this.delete_event.connect( () => {
			hide_Window();
			return true;
		} );
		
		
		//  -  Hide window if you press escape
		base.key_press_event.connect( (k) => {
			if (Gdk.Key.Escape == k.keyval) {
				hide_Window();
				return true;
			} else {
				return false;
			}
		} );
		
		
		//  -  Hide window if it loses focus
		base.focus_out_event.connect( () => {
			hide_Window();
			return true;
		} );
	}
	
	public void build_gui() {
		base.set_title("Rocket-Launcher");
		base.set_position(Gtk.WindowPosition.CENTER);
		base.set_decorated(false);
		base.set_keep_above(true);
		base.set_deletable(false);
		base.set_default_size(750, 600);
		base.set_border_width(border_size);
		
		//Prerequesites for transparency and cairo drawing in general
		base.set_app_paintable(true);
		base.set_visual(screen.get_rgba_visual());
		
		//On draw event: draw window semi transparent
		base.draw.connect( (ctx) => {
			const double PI = 3.1415926535897932384626433832795028841971693993751058;
			int height = this.get_window().get_height();
			int width = this.get_window().get_width();
			
			//Draw everywhere on window
			ctx.set_source_rgba(Gui.bg_color[0], Gui.bg_color[1],
								Gui.bg_color[2], Gui.bg_color[3]);
			ctx.set_operator(Cairo.Operator.SOURCE);
			ctx.paint();
			
			//Make corners transparent
			ctx.set_source_rgba(0.0, 0.0, 0.0, 0.0);
			ctx.rectangle(0, 0, border_size, border_size);
			ctx.rectangle(0, height - border_size, border_size, border_size);
			ctx.rectangle(width - border_size, 0, border_size, border_size);
			ctx.rectangle(width - border_size, height - border_size, border_size, border_size);
			ctx.fill();
			
			//Paint gradient in top left corner
			Cairo.Pattern grad_tl = new Cairo.Pattern.radial(
						border_size, border_size, 0,
						border_size, border_size, border_size);
			grad_tl.add_color_stop_rgba(0.3, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], Gui.bg_color[3]);
			grad_tl.add_color_stop_rgba(1.0, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], 0.0);
			ctx.move_to(border_size, border_size);
			ctx.arc(border_size, border_size, border_size, 1.0 * PI,
						1.5 * PI);
			ctx.set_source(grad_tl);
			ctx.fill();
			
			//Paint gradient in top right corner
			Cairo.Pattern grad_tr = new Cairo.Pattern.radial(
						width - border_size, border_size, 0,
						width - border_size, border_size, border_size);
			grad_tr.add_color_stop_rgba(0.3, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], Gui.bg_color[3]);
			grad_tr.add_color_stop_rgba(1.0, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], 0.0);
			ctx.move_to(width - border_size, border_size);
			ctx.arc(width - border_size, border_size, border_size,
						1.5 * PI, 2.0 * PI);
			ctx.set_source(grad_tr);
			ctx.fill();
			
			//Paint gradient in bottom left corner
			Cairo.Pattern grad_bl = new Cairo.Pattern.radial(
						border_size, height - border_size, 0,
						border_size, height - border_size, border_size);
			grad_bl.add_color_stop_rgba(0.3, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], Gui.bg_color[3]);
			grad_bl.add_color_stop_rgba(1.0, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], 0.0);
			ctx.move_to(border_size, height - border_size);
			ctx.arc(border_size, height - border_size, border_size,
						0.5 * PI, 1.0 * PI);
			ctx.set_source(grad_bl);
			ctx.fill();
			
			//Paint gradient in bottom right corner
			Cairo.Pattern grad_br = new Cairo.Pattern.radial(
						width - border_size, height - border_size, 0,
						width - border_size, height - border_size, border_size);
			grad_br.add_color_stop_rgba(0.3, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], Gui.bg_color[3]);
			grad_br.add_color_stop_rgba(1.0, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], 0.0);
			ctx.move_to(width - border_size, border_size);
			ctx.arc(width - border_size, height - border_size, border_size,
						0, 0.5 * PI);
			ctx.set_source(grad_br);
			ctx.fill();
			
			//Paint top gradient
			Cairo.Pattern grad_t = new Cairo.Pattern.linear(0,
						border_size, 0, 0);
			grad_t.add_color_stop_rgba(0.3, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], Gui.bg_color[3]);
			grad_t.add_color_stop_rgba(1.0, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], 0.0);
			ctx.rectangle(border_size, 0, width - (2 * border_size),
						border_size);
			ctx.set_source(grad_t);
			ctx.fill();
			
			//Paint bottom gradient
			Cairo.Pattern grad_b = new Cairo.Pattern.linear(0,
						height - border_size, 0, height);
			grad_b.add_color_stop_rgba(0.3, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], Gui.bg_color[3]);
			grad_b.add_color_stop_rgba(1.0, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], 0.0);
			ctx.rectangle(border_size, height - border_size,
						width - (2 * border_size), border_size);
			ctx.set_source(grad_b);
			ctx.fill();
			
			//Paint left gradient
			Cairo.Pattern grad_l = new Cairo.Pattern.linear(border_size,
							0, 0, 0);
			grad_l.add_color_stop_rgba(0.3, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], Gui.bg_color[3]);
			grad_l.add_color_stop_rgba(1.0, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], 0.0);
			ctx.rectangle(0, border_size, border_size,
						height - (2 * border_size));
			ctx.set_source(grad_l);
			ctx.fill();
			
			//Paint right gradient
			Cairo.Pattern grad_r = new Cairo.Pattern.linear(
						width - border_size, 0, width, 0);
			grad_r.add_color_stop_rgba(0.3, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], Gui.bg_color[3]);
			grad_r.add_color_stop_rgba(1.0, Gui.bg_color[0],
						Gui.bg_color[1], Gui.bg_color[2], 0.0);
			ctx.rectangle(width - border_size,
						border_size, border_size,
						height - (2 * border_size));
			ctx.set_source(grad_r);
			ctx.fill();
			
			return false;
		});
		
		
		//create main grid
		Gtk.Grid outer_grid = new Gtk.Grid();
		outer_grid.set_column_homogeneous(false);
		outer_grid.set_row_homogeneous(false);
		
		//Scrolled Area
		scrolled = new Gtk.ScrolledWindow(null, null);
		scrolled.set_policy(PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		outer_grid.attach(scrolled, 0, 0, 1, 2);
		
		//AppGrid
		app_grid = new AppGrid();
		foreach (AppIcon app_icon in app_icon_list) {
			app_grid.add(app_icon);
		}
		app_grid.set_hexpand(true);
		scrolled.add_with_viewport(app_grid);
		
		//SearchEntry
		search_entry = new Gtk.Entry();
		search_entry.activate.connect( () => {
			application_handler.filter_apps(Filter_by.SEARCH, search_entry.get_text());
		} );
		search_entry.changed.connect( () => {
			string text;
			if ((text = search_entry.get_text()) == "") {
				application_handler.filter_apps(Filter_by.ALL, null);
			} else {
				application_handler.filter_apps(Filter_by.SEARCH, search_entry.get_text());
			}
		} );
		outer_grid.attach(search_entry, 1, 0, 1, 1);
		
		//CategoryButtons
		Gtk.Box button_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		button_box.set_spacing(1);
		button_box.set_vexpand(true);
		outer_grid.attach(button_box, 1, 1, 1, 1);
		
		string[] categorie_button_strings = {"All", "AudioVideo", "Audio", "Video", "Development", "Education", "Game", "Graphics", "Network", "Office", "Science", "Settings", "System", "Utility"};
		Gtk.Button[] categorie_buttons = new Gtk.Button[categorie_button_strings.length];
		
		for (int i = 0; i < 14; i++) {
			categorie_buttons[i] = new Gtk.Button.with_label(categorie_button_strings[i]);
			categorie_buttons[i].set_relief(Gtk.ReliefStyle.NONE);
			button_box.add(categorie_buttons[i]);
		}
		
		categorie_buttons[0].button_press_event.connect( () => {
			application_handler.filter_apps(Filter_by.ALL, null);
			search_entry.set_text("");
			return true; } );
		categorie_buttons[1].button_press_event.connect( () => {
			application_handler.filter_apps(Filter_by.CATEGORIES, "AudioVideo");
			search_entry.set_text("");
			return true; } );
		categorie_buttons[2].button_press_event.connect( () => {
			application_handler.filter_apps(Filter_by.CATEGORIES, "Audio");
			search_entry.set_text("");
			return true; } );
		categorie_buttons[3].button_press_event.connect( () => {
			application_handler.filter_apps(Filter_by.CATEGORIES, "Video");
			search_entry.set_text("");
			return true; } );
		categorie_buttons[4].button_press_event.connect( () => {
			application_handler.filter_apps(Filter_by.CATEGORIES, "Development");
			search_entry.set_text("");
			return true; } );
		categorie_buttons[5].button_press_event.connect( () => {
			application_handler.filter_apps(Filter_by.CATEGORIES, "Education");
			search_entry.set_text("");
			return true; } );
		categorie_buttons[6].button_press_event.connect( () => {
			application_handler.filter_apps(Filter_by.CATEGORIES, "Game");
			search_entry.set_text("");
			return true; } );
		categorie_buttons[7].button_press_event.connect( () => {
			application_handler.filter_apps(Filter_by.CATEGORIES, "Graphics");
			search_entry.set_text("");
			return true; } );
		categorie_buttons[8].button_press_event.connect( () => {
			application_handler.filter_apps(Filter_by.CATEGORIES, "Network");
			search_entry.set_text("");
			return true; } );
		categorie_buttons[9].button_press_event.connect( () => {
			application_handler.filter_apps(Filter_by.CATEGORIES, "Office");
			search_entry.set_text("");
			return true; } );
		categorie_buttons[10].button_press_event.connect( () => {
			application_handler.filter_apps(Filter_by.CATEGORIES, "Science");
			search_entry.set_text("");
			return true; } );
		categorie_buttons[11].button_press_event.connect( () => {
			application_handler.filter_apps(Filter_by.CATEGORIES, "Settings");
			search_entry.set_text("");
			return true; } );
		categorie_buttons[12].button_press_event.connect( () => {
			application_handler.filter_apps(Filter_by.CATEGORIES, "System");
			search_entry.set_text("");
			return true; } );
		categorie_buttons[13].button_press_event.connect( () => {
			application_handler.filter_apps(Filter_by.CATEGORIES, "Utility");
			search_entry.set_text("");
			return true; } );
		
		//
		this.add(outer_grid);
	}
	
	//The following methods will be called from outside this class
	//(dbus, application-indicator, etc.)
	
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
		//Hide the application window
		
		//Make sure the window looks exactly as if the application
		//had just started.
		//We do all this before we hide the window and not before we
		//show it again! (To reduce time to show window)
		application_handler.filter_apps(Filter_by.ALL, null);
		scrolled.get_vadjustment().set_value(0);
		search_entry.set_text("");
		search_entry.grab_focus();
		
		this.hide();
	}
	
	public void exit_program() {
		//Kill the Gtk loop which is the main loop of the
		//application at the same time
		//( ==> we quit the application )
		Gtk.main_quit();
	}
}
