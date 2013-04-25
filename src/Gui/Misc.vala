private static bool draw_transparent(Cairo.Context ctx) {
	//This function is bound to several 'draw' events of different
	//Gtk.Widgets.
	//It receives a Cairo.Context and paints it all transparent
	
	ctx.set_source_rgba(0.811, 0.811, 0.811, 0.7);
	ctx.set_operator(Cairo.Operator.SOURCE);
	ctx.paint();
	
	//Return false so that other callbacks for the 'draw' event
	//will be invoked. (Other callbacks are responsible for the actual
	//drawing of the Gtk.Widget)
	return false;
}
