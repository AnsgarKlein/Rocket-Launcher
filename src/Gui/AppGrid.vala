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

class AppGrid : Gtk.Grid {
	private const int row_length = 6;
	
	public AppGrid() {
		this.set_column_spacing(15);
		this.set_row_spacing(15);
		
		if (Gdk.Screen.get_default().is_composited()) {
			//Draw background transparent
			base.draw.connect( (context) => {
				context.set_source_rgba(Gui.bg_color[0], Gui.bg_color[1],
				Gui.bg_color[2], Gui.bg_color[3]);
				context.set_operator(Cairo.Operator.SOURCE);
				context.paint();
				
				//Return false so that other callbacks for the 'draw' event
				//will be invoked. (Other callbacks are responsible for the actual
				//drawing of the widgets)
				return false;
			});
		}
	}
	
	private int get_number_of_children() {
		int num = 0;
		foreach (Gtk.Widget wdg in base.get_children()) {
			num++;
		}
		return num;
		
		//TODO: Test the following (->speed)
		//different approach:
		//int num = (int)base.get_children().length();
	}
	
	public new void add(AppIcon app) {
		int num = get_number_of_children();
		this.attach(app, num%row_length, num/row_length+1, 1, 1);
	}
	
	public void clear() {
		//Removes all AppIcon from this AppGrid
		foreach (Gtk.Widget wdg in base.get_children()) {
			base.remove(wdg);
		}
	}
}
