package com.nammaflutter.nammawallet

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import android.util.Log
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

class TicketListWidgetFactory(private val context: Context) :
    RemoteViewsService.RemoteViewsFactory {

    private var tickets = JSONArray()

    companion object {
        private const val TAG = "TicketListFactory"
    }

    override fun onDataSetChanged() {
        Log.d(TAG, "onDataSetChanged called")

        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val ticketListJson = prefs.getString("ticket_list", "[]") ?: "[]"

        Log.d(TAG, "Raw ticket_list JSON: $ticketListJson")

        tickets = try {
            val arr = JSONArray(ticketListJson)
            Log.d(TAG, "Loaded ${arr.length()} tickets")
            arr
        } catch (e: JSONException) {
            Log.e(TAG, "Failed to parse ticket_list JSON. Malformed data: $ticketListJson", e)
            // Reset stored preference to valid empty array
            prefs.edit().putString("ticket_list", "[]").apply()
            // Fall back to empty array
            JSONArray()
        }
    }

    override fun getCount(): Int {
        val count = tickets.length()
        Log.d(TAG, "getCount: $count")
        return count
    }

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

    override fun getViewTypeCount(): Int = 1
    override fun hasStableIds(): Boolean = true
    override fun getLoadingView(): RemoteViews? = null
    override fun getItemId(position: Int): Long {
        return try {
            tickets.getJSONObject(position).optLong("ticket_id", position.toLong())
        } catch (e: Exception) {
            position.toLong()
        }
    }

    override fun onCreate() {
        Log.d(TAG, "onCreate")
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy")
    }
}

