package com.nammaflutter.nammawallet

import android.content.Intent
import android.widget.RemoteViewsService

class TicketListWidgetService : RemoteViewsService() {
    /**
     * Provides a RemoteViewsFactory that supplies the widget's collection item views.
     *
     * @param intent The intent provided by the app widget framework when creating the factory.
     * @return A `RemoteViewsFactory` responsible for creating list item views for the widget.
     */
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TicketListWidgetFactory(applicationContext)
    }
}