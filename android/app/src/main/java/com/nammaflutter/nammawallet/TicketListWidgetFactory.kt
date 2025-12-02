package com.nammaflutter.nammawallet

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

class TicketListWidgetFactory(private val context: Context) :
    RemoteViewsService.RemoteViewsFactory {

    private var tickets = JSONArray()
    
    companion object {
        private const val TAG = "TicketListFactory"
    }

    /**
     * Refreshes the factory's internal ticket list from shared preferences.
     *
     * Reads the "ticket_list" JSON string from the "HomeWidgetPreferences" SharedPreferences,
     * parses it into the `tickets` JSONArray, and resets `tickets` to an empty JSONArray if parsing fails.
     */
    override fun onDataSetChanged() {
        Log.d(TAG, "onDataSetChanged called")
        
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val ticketListJson = prefs.getString("ticket_list", "[]") ?: "[]"
        
        Log.d(TAG, "Raw ticket_list JSON: $ticketListJson")
        
        try {
            tickets = JSONArray(ticketListJson)
            Log.d(TAG, "Loaded ${tickets.length()} tickets")
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing ticket list", e)
            tickets = JSONArray()
        }
    }

    /**
     * Provides the number of tickets currently loaded into the factory.
     *
     * @return The number of tickets available for the widget list.
     */
    override fun getCount(): Int {
        val count = tickets.length()
        Log.d(TAG, "getCount: $count")
        return count
    }

    /**
     * Creates RemoteViews for the ticket at the given list position to display in the widget.
     *
     * Populates primary text, location (with fallbacks), start time, provider (from `secondary_text` or `extras`),
     * selects an icon by ticket `type`, and attaches a fill-in intent carrying the ticket index for item actions.
     *
     * @param position Index of the ticket in the current ticket list.
     * @return A RemoteViews configured to represent the ticket at `position`. If an error occurs, returns a view that shows an error message.
     */
    override fun getViewAt(position: Int): RemoteViews {
        Log.d(TAG, "getViewAt position: $position")
        
        val views = RemoteViews(context.packageName, R.layout.ticket_list_item)
        
        try {
            val ticket = tickets.getJSONObject(position)
            Log.d(TAG, "Ticket at $position: $ticket")
            
            // PRIMARY TEXT - Use primary_text field (snake_case from Flutter)
            val primaryText = ticket.optString("primary_text", "Unknown Ticket")
            views.setTextViewText(R.id.primaryText, primaryText)
            
            // LOCATION - Use location field
            val location = ticket.optString("location", "")
            val secondaryText = ticket.optString("secondary_text", "")
            val locationText = when {
                location.isNotEmpty() -> location
                secondaryText.isNotEmpty() -> secondaryText
                else -> "Location not available"
            }
            views.setTextViewText(R.id.locationText, locationText)
            
            // START TIME - Use formatted start_time
            val startTime = ticket.optString("start_time", "Time not available")
            views.setTextViewText(R.id.startTimeText, startTime)
            
            // PROVIDER - Use secondary_text or extras
            var providerText = ticket.optString("secondary_text", "")
            if (providerText.isEmpty()) {
                val extras = ticket.optJSONArray("extras")
                if (extras != null && extras.length() > 0) {
                    providerText = extras.getJSONObject(0).optString("value", "Provider")
                } else {
                    providerText = "Provider"
                }
            }
            views.setTextViewText(R.id.providerText, providerText)
            
            // ICON - Set based on ticket type
            val type = ticket.optString("type", "GENERAL").uppercase()
            Log.d(TAG, "Ticket type: $type")
            
            when (type) {
                "TRAIN" -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_train)
                "BUS" -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_bus)
                "FLIGHT" -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_flight)
                "EVENT" -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_event)
                else -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_ticket)
            }
            
            // UNPIN ACTION - Use FillInIntent for ListView items
            val fillInIntent = Intent().apply {
                putExtra(TicketListWidgetProvider.EXTRA_TICKET_INDEX, position)
            }
            views.setOnClickFillInIntent(R.id.pinIcon, fillInIntent)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error creating view at position $position", e)
            views.setTextViewText(R.id.primaryText, "Error loading ticket")
        }
        
        return views
    }

    /**
 * Declares how many distinct item view types this factory provides.
 *
 * @return The number of distinct view types; always 1 for a single item layout.
 */
override fun getViewTypeCount(): Int = 1
    /**
 * Indicates that the factory provides stable item IDs across dataset changes.
 *
 * @return `true` because item IDs are stable and derived from item positions.
 */
override fun hasStableIds(): Boolean = true
    /**
 * Supplies an optional RemoteViews to display while a list item is being loaded or refreshed.
 *
 * @return A `RemoteViews` to use as a loading placeholder, or `null` to use the system default loading view.
 */
override fun getLoadingView(): RemoteViews? = null
    /**
 * Provides a stable item ID for the given list position.
 *
 * @return The item ID as a `Long` equal to the provided `position`.
 */
override fun getItemId(position: Int): Long = position.toLong()
    /**
     * Called when the factory is created to perform any initial setup.
     */
    override fun onCreate() {
        Log.d(TAG, "onCreate")
    }
    /**
     * Invoked when the RemoteViewsFactory is being destroyed and should release any held resources.
     *
     * This method is called as part of the factory lifecycle when the widget no longer needs item views.
     */
    override fun onDestroy() {
        Log.d(TAG, "onDestroy")
    }
}
