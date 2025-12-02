package com.nammaflutter.nammawallet

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.util.Log
import org.json.JSONArray

class TicketListWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "TicketListWidget"
        const val ACTION_UNPIN = "com.nammaflutter.nammawallet.UNPIN_TICKET"
        const val EXTRA_TICKET_INDEX = "ticket_index"
        
        /**
         * Configure and refresh the ticket list widget for the specified app widget ID.
         *
         * Sets the RemoteViews adapter and empty view for the list, attaches a PendingIntent
         * template for unpin actions on list items, and requests the AppWidgetManager to
         * update and refresh the widget's list data.
         *
         * @param widgetId The app widget ID to configure and refresh.
         */
        fun updateWidget(
            context: Context,
            manager: AppWidgetManager,
            widgetId: Int
        ) {
            Log.d(TAG, "Updating widget $widgetId")
            
            val views = RemoteViews(context.packageName, R.layout.ticket_list_widget)

            // Set RemoteViews adapter for ListView
            val serviceIntent = Intent(context, TicketListWidgetService::class.java)
            serviceIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)

            views.setRemoteAdapter(R.id.ticketListView, serviceIntent)
            views.setEmptyView(R.id.ticketListView, R.id.ticketEmptyView)

            // Set PendingIntentTemplate for the ListView (required for item clicks)
            val unpinIntent = Intent(context, TicketListWidgetProvider::class.java).apply {
                action = ACTION_UNPIN
            }
            val unpinPendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                unpinIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            views.setPendingIntentTemplate(R.id.ticketListView, unpinPendingIntent)

            manager.updateAppWidget(widgetId, views)
            manager.notifyAppWidgetViewDataChanged(widgetId, R.id.ticketListView)
        }
    }

    /**
     * Receives broadcasts for the widget and handles widget-specific actions.
     *
     * Handles two actions:
     * - ACTION_UNPIN: reads `EXTRA_TICKET_INDEX` from the intent and unpins the ticket at that index.
     * - "com.nammaflutter.nammawallet.UPDATE_TICKET_LIST": refreshes all instances of this widget.
     *
     * @param context Context used to access system services and resources.
     * @param intent Broadcast intent containing the action and any extras (for example `EXTRA_TICKET_INDEX` for unpin).
     */
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        Log.d(TAG, "onReceive: ${intent.action}")
        
        // Handle UNPIN action
        if (intent.action == ACTION_UNPIN) {
            val index = intent.getIntExtra(EXTRA_TICKET_INDEX, -1)
            if (index != -1) {
                unpinTicket(context, index)
            }
            return
        }
        
        // Handle custom UPDATE_TICKET_LIST action from Flutter
        if (intent.action == "com.nammaflutter.nammawallet.UPDATE_TICKET_LIST") {
            val manager = AppWidgetManager.getInstance(context)
            val widgetIds = manager.getAppWidgetIds(
                ComponentName(context, TicketListWidgetProvider::class.java)
            )
            
            Log.d(TAG, "Updating ${widgetIds.size} widget instances")
            
            // Update all widget instances
            for (widgetId in widgetIds) {
                updateWidget(context, manager, widgetId)
            }
        }
    }

    /**
     * Removes the ticket at the specified index from the persisted widget ticket list and refreshes related widgets.
     *
     * If the index is within bounds, the entry is removed from the JSON array stored under key "ticket_list"
     * in the "HomeWidgetPreferences" SharedPreferences and the updated array is persisted. Afterward, all
     * instances of TicketListWidgetProvider and MainTicketWidgetProvider are updated.
     *
     * @param index The zero-based position of the ticket to remove from the stored ticket list.
     */
    private fun unpinTicket(context: Context, index: Int) {
        Log.d(TAG, "Unpinning ticket at index: $index")
        
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val json = prefs.getString("ticket_list", "[]") ?: "[]"
        val arr = JSONArray(json)

        if (index < arr.length()) {
            arr.remove(index)
            prefs.edit().putString("ticket_list", arr.toString()).apply()
            Log.d(TAG, "Ticket unpinned. Remaining tickets: ${arr.length()}")
        }

        // Update all widgets
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(
            ComponentName(context, TicketListWidgetProvider::class.java)
        )
        for (widgetId in ids) {
            updateWidget(context, manager, widgetId)
        }

        // Update Main Widget as well
        val mainIds = manager.getAppWidgetIds(
            ComponentName(context, MainTicketWidgetProvider::class.java)
        )
        for (widgetId in mainIds) {
            MainTicketWidgetProvider.updateWidget(context, manager, widgetId)
        }
    }

    /**
     * Refreshes each widget instance specified in [appWidgetIds].
     *
     * Iterates over the provided widget IDs and triggers a per-widget update so the widget UI and data are refreshed.
     *
     * @param context Context used to access resources and system services.
     * @param appWidgetManager Manager used to apply updates to app widgets.
     * @param appWidgetIds Array of app widget IDs that should be updated.
     */
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "onUpdate called for ${appWidgetIds.size} widgets")
        
        // Update each widget instance
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }
}
