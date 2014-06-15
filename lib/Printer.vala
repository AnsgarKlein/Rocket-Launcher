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
    public class Printer : GLib.Object {
        public static GLib.Object print_lock;
        
        static construct {
            Printer.print_lock = new GLib.Object();
        }
        
        public static void print_info(string str) {         
            string[] arr = str.split("\n");
            
            for (int i = 0; i < arr.length; i++) {
                if (arr[i] == "") {
                    // Don't print
                } else {
                    stdout.printf("\033[0;44;30m[INFO]\033[0;49;39m " +arr[i] +"\n");
                }
            }
            stdout.printf("\n");
        }
        
        public static void print_warning(string str) {
            string[] arr = str.split("\n");
            
            for (int i = 0; i < arr.length; i++) {
                if (arr[i] == "") {
                    // Don't print
                } else {
                    stdout.printf("\033[0;43;30m[WARN]\033[0;49;39m " +arr[i] +"\n");
                }
            }
            stdout.printf("\n");
        }
        
        public static void print_error(string str) {
            string[] arr = str.split("\n");
            
            for (int i = 0; i < arr.length; i++) {
                if (arr[i] == "") {
                    // Don't print
                } else {
                    stderr.printf("\033[0;41;30m[ERRO]\033[0;49;39m " +arr[i] +"\n");
                }
            }
            stdout.printf("\n");
        }
    }
    
    public static void print_info(string str) {
        Printer.print_info(str);
    }
    
    public static void print_warning(string str) {
        Printer.print_warning(str);
    }
    
    public static void print_error(string str) {
        Printer.print_error(str);
    }
}
