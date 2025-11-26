package com.nammaflutter.nammawallet

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

/**
 * Home screen widget for displaying ticket information.
 * Integrates with home_widget package for Flutter communication.
 */
class TicketHomeWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Update all widget instances
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
}

/**
 * Updates the widget with data from Flutter via home_widget package
 */
internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val widgetData = HomeWidgetPlugin.getData(context)
    val views = RemoteViews(context.packageName, R.layout.ticket_home_widget)

    var ticketData = widgetData.getString("ticket_data", null)

    if (ticketData != null) {
        try {
            // Check if the string is double-encoded (starts and ends with quotes)
            if (ticketData.startsWith("\"") && ticketData.endsWith("\"")) {
                // Remove outer quotes and unescape inner quotes
                ticketData = ticketData.substring(1, ticketData.length - 1)
                    .replace("\\\"", "\"")
                    .replace("\\\\", "\\")
            }

            // Create JSON object
            val json = JSONObject(ticketData)

            // Extract ticket data (using snake_case keys from Dart mappable)
            val primaryText = json.optString("primary_text", "No Route Info")
            val secondaryText = json.optString("secondary_text", "Service")
            val ticketType = json.optString("type", "bus")
            val location = json.optString("location", "Unknown")
            val startTime = json.optString("start_time", "")

            // Parse and format date/time
            val (journeyDate, journeyTime) = parseDateTime(startTime)

            // Set service icon based on ticket type
            val serviceIcon = when (ticketType.lowercase()) {
                "busticket", "bus" -> R.drawable.ic_bus
                "trainticket", "train" -> R.drawable.ic_train
                "event" -> R.drawable.ic_event
                else -> R.drawable.ic_bus
            }

            // Update views
            views.setImageViewResource(R.id.service_icon, serviceIcon)
            views.setTextViewText(R.id.service_type, secondaryText)
            views.setTextViewText(R.id.primary_text, primaryText)
            views.setTextViewText(R.id.journey_date, journeyDate)
            views.setTextViewText(R.id.journey_time, journeyTime)
            views.setTextViewText(R.id.location, location)

            // Hide tags by default (can be extended later if needed)
            views.setViewVisibility(R.id.tags_container, View.GONE)

        } catch (e: Exception) {
            android.util.Log.e("TicketHomeWidget", "Error parsing ticket data", e)
            setErrorState(views)
        }
    } else {
        setEmptyState(views)
    }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

private fun parseDateTime(dateTimeString: String): Pair<String, String> {
    if (dateTimeString.isEmpty()) {
        return Pair("--", "--")
    }

    try {
        // Try to parse ISO format with milliseconds (Dart DateTime.toJson() format)
        val isoFormatWithMillis = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.getDefault())
        isoFormatWithMillis.timeZone = java.util.TimeZone.getTimeZone("UTC")
        val date = isoFormatWithMillis.parse(dateTimeString)

        if (date != null) {
            val dateFormat = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())
            val timeFormat = SimpleDateFormat("hh:mm a", Locale.getDefault())

            return Pair(dateFormat.format(date), timeFormat.format(date))
        }
    } catch (e: Exception) {
        try {
            // Try ISO format without milliseconds
            val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault())
            isoFormat.timeZone = java.util.TimeZone.getTimeZone("UTC")
            val date = isoFormat.parse(dateTimeString)

            if (date != null) {
                val dateFormat = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())
                val timeFormat = SimpleDateFormat("hh:mm a", Locale.getDefault())

                return Pair(dateFormat.format(date), timeFormat.format(date))
            }
        } catch (e2: Exception) {
            try {
                // Try basic ISO format
                val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                val date = isoFormat.parse(dateTimeString)

                if (date != null) {
                    val dateFormat = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())
                    val timeFormat = SimpleDateFormat("hh:mm a", Locale.getDefault())

                    return Pair(dateFormat.format(date), timeFormat.format(date))
                }
            } catch (e3: Exception) {
                try {
                    // Try dd/MM/yyyy format
                    val altFormat = SimpleDateFormat("dd/MM/yyyy", Locale.getDefault())
                    val date = altFormat.parse(dateTimeString)

                    if (date != null) {
                        val dateFormat = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())
                        return Pair(dateFormat.format(date), "--")
                    }
                } catch (e4: Exception) {
                    // Return raw string as fallback
                    return Pair(dateTimeString, "--")
                }
            }
        }
    }

    return Pair("--", "--")
}

private fun setErrorState(views: RemoteViews) {
    views.setImageViewResource(R.id.service_icon, R.drawable.ic_info)
    views.setTextViewText(R.id.service_type, "Error")
    views.setTextViewText(R.id.primary_text, "Unable to load ticket")
    views.setTextViewText(R.id.journey_date, "--")
    views.setTextViewText(R.id.journey_time, "--")
    views.setTextViewText(R.id.location, "Please check app")
    views.setViewVisibility(R.id.tags_container, View.GONE)
}

private fun setEmptyState(views: RemoteViews) {
    views.setImageViewResource(R.id.service_icon, R.drawable.ic_event)
    views.setTextViewText(R.id.service_type, "Namma Wallet")
    views.setTextViewText(R.id.primary_text, "No tickets available")
    views.setTextViewText(R.id.journey_date, "--")
    views.setTextViewText(R.id.journey_time, "--")
    views.setTextViewText(R.id.location, "Add tickets in app")
    views.setViewVisibility(R.id.tags_container, View.GONE)
}