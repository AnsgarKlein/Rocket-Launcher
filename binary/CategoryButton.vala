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
    private class CategoryButton : Gtk.Button {
        private string filter_value;
        
        public CategoryButton(string label, string filter_value) {
            Object(label: label);
            
            this.filter_value = filter_value;
            
            this.button_press_event.connect( () => {
                category_button_press_event(filter_value);
                return false;
            } );
        }
        
        public signal void category_button_press_event(string filter_value);
    }
}
