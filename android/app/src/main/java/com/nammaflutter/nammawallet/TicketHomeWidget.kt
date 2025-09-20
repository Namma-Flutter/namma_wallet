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
 * Implementation of App Widget functionality.
 * Displays ticket information in a layout matching the app's ticket card design.
 */
class TicketHomeWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val widgetData = HomeWidgetPlugin.getData(context)
    val views = RemoteViews(context.packageName, R.layout.ticket_home_widget)

    // Debug: Log what data we're getting
    android.util.Log.d("TicketHomeWidget", "Widget data keys: ${widgetData.all?.keys}")

    // Try to get the data and handle different possible formats
    val ticketData = widgetData.all?.get("ticket_data")
    android.util.Log.d("TicketHomeWidget", "Ticket data is null: ${ticketData == null}")
    android.util.Log.d("TicketHomeWidget", "Ticket data type: ${ticketData?.javaClass?.simpleName}")
    android.util.Log.d("TicketHomeWidget", "Ticket data value: $ticketData")

    if (ticketData != null) {
        try {
            // Convert the data to JSON string if needed
            val jsonString = when (ticketData) {
                is String -> ticketData
                else -> ticketData.toString()
            }

            android.util.Log.d("TicketHomeWidget", "JSON string to parse: $jsonString")

            // Try multiple approaches to parse the JSON
            val json = try {
                // First attempt: direct parsing
                JSONObject(jsonString)
            } catch (e1: Exception) {
                android.util.Log.w("TicketHomeWidget", "Direct JSON parsing failed, trying cleanup", e1)
                try {
                    // Second attempt: clean up the string and try again
                    val cleanedString = jsonString.trim().replace("\\\"", "\"")
                    JSONObject(cleanedString)
                } catch (e2: Exception) {
                    android.util.Log.w("TicketHomeWidget", "Cleaned JSON parsing failed, trying raw approach", e2)
                    try {
                        // Third attempt: treat as escaped JSON string
                        val unescapedString = jsonString.replace("\\", "")
                        JSONObject(unescapedString)
                    } catch (e3: Exception) {
                        android.util.Log.e("TicketHomeWidget", "All JSON parsing attempts failed, trying manual parsing", e3)
                        // Final fallback: manually extract values using regex
                        return parseTicketDataManually(jsonString, views, appWidgetManager, appWidgetId)
                    }
                }
            }

            // Extract ticket data (camelCase field names from Dart mappable)
            val primaryText = json.optString("primaryText", "No Route Info")
            val secondaryText = json.optString("secondaryText", "Service")
            val ticketType = json.optString("type", "bus")
            val location = json.optString("location", "Unknown")
            val startTime = json.optString("startTime", "")

            // Debug: Log extracted values
            android.util.Log.d("TicketHomeWidget", "Primary: $primaryText, Secondary: $secondaryText, Type: $ticketType, Location: $location, StartTime: $startTime")

            // Parse and format date/time
            val (journeyDate, journeyTime) = parseDateTime(startTime)

            // Set service icon based on ticket type
            val serviceIcon = when (ticketType.lowercase()) {
                "busticket", "bus" -> R.drawable.ic_bus
                "trainticket", "train" -> R.drawable.ic_train
                "event" -> R.drawable.ic_event
                else -> R.drawable.ic_event
            }

            // Update views with ticket data
            views.setImageViewResource(R.id.service_icon, serviceIcon)
            views.setTextViewText(R.id.service_type, secondaryText)
            views.setTextViewText(R.id.primary_text, primaryText)
            views.setTextViewText(R.id.journey_date, journeyDate)
            views.setTextViewText(R.id.journey_time, journeyTime)
            views.setTextViewText(R.id.location, location)

            // Handle tags if present (tags can be null, so check for that)
            val tagsArray = if (json.isNull("tags")) null else json.optJSONArray("tags")
            if (tagsArray != null && tagsArray.length() > 0) {
                views.setViewVisibility(R.id.tags_container, View.VISIBLE)

                // First tag
                if (tagsArray.length() > 0) {
                    val firstTag = tagsArray.getJSONObject(0)
                    val firstTagValue = firstTag.optString("value", "")
                    views.setTextViewText(R.id.tag1, firstTagValue)
                    views.setViewVisibility(R.id.tag1, View.VISIBLE)
                }

                // Second tag
                if (tagsArray.length() > 1) {
                    val secondTag = tagsArray.getJSONObject(1)
                    val secondTagValue = secondTag.optString("value", "")
                    views.setTextViewText(R.id.tag2, secondTagValue)
                    views.setViewVisibility(R.id.tag2, View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.tag2, View.GONE)
                }
            } else {
                // Handle case where tags is null or empty - could use extras instead
                val extrasArray = json.optJSONArray("extras")
                if (extrasArray != null && extrasArray.length() > 0) {
                    views.setViewVisibility(R.id.tags_container, View.VISIBLE)

                    // Use first two extras as tags
                    if (extrasArray.length() > 0) {
                        val firstExtra = extrasArray.getJSONObject(0)
                        val firstExtraValue = firstExtra.optString("value", "")
                        views.setTextViewText(R.id.tag1, firstExtraValue)
                        views.setViewVisibility(R.id.tag1, View.VISIBLE)
                    }

                    if (extrasArray.length() > 1) {
                        val secondExtra = extrasArray.getJSONObject(1)
                        val secondExtraValue = secondExtra.optString("value", "")
                        views.setTextViewText(R.id.tag2, secondExtraValue)
                        views.setViewVisibility(R.id.tag2, View.VISIBLE)
                    } else {
                        views.setViewVisibility(R.id.tag2, View.GONE)
                    }
                } else {
                    views.setViewVisibility(R.id.tags_container, View.GONE)
                }
            }

        } catch (e: Exception) {
            // Debug: Log the exception
            android.util.Log.e("TicketHomeWidget", "Error parsing ticket data", e)
            // Show error state
            setErrorState(views, "Error parsing ticket data")
        }
    } else {
        // Show empty state
        setEmptyState(views)
    }

    // Update the widget
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

private fun setErrorState(views: RemoteViews, message: String) {
    views.setImageViewResource(R.id.service_icon, R.drawable.ic_info)
    views.setTextViewText(R.id.service_type, "Error")
    views.setTextViewText(R.id.primary_text, message)
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

private fun parseTicketDataManually(
    jsonString: String,
    views: RemoteViews,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    try {
        android.util.Log.d("TicketHomeWidget", "Attempting manual parsing of: $jsonString")

        // Extract values using regex patterns
        val primaryText = extractValue(jsonString, "primaryText") ?: "No Route Info"
        val secondaryText = extractValue(jsonString, "secondaryText") ?: "Service"
        val ticketType = extractValue(jsonString, "type") ?: "event"
        val location = extractValue(jsonString, "location") ?: "Unknown"
        val startTime = extractValue(jsonString, "startTime") ?: ""

        android.util.Log.d("TicketHomeWidget", "Manual parsing - Primary: $primaryText, Secondary: $secondaryText, Type: $ticketType")

        // Parse and format date/time
        val (journeyDate, journeyTime) = parseDateTime(startTime)

        // Set service icon based on ticket type
        val serviceIcon = when (ticketType.lowercase()) {
            "busticket", "bus" -> R.drawable.ic_bus
            "trainticket", "train" -> R.drawable.ic_train
            "event" -> R.drawable.ic_event
            else -> R.drawable.ic_event
        }

        // Update views with ticket data
        views.setImageViewResource(R.id.service_icon, serviceIcon)
        views.setTextViewText(R.id.service_type, secondaryText)
        views.setTextViewText(R.id.primary_text, primaryText)
        views.setTextViewText(R.id.journey_date, journeyDate)
        views.setTextViewText(R.id.journey_time, journeyTime)
        views.setTextViewText(R.id.location, location)

        // For manual parsing, hide tags to avoid complexity
        views.setViewVisibility(R.id.tags_container, View.GONE)

        android.util.Log.d("TicketHomeWidget", "Manual parsing successful")
    } catch (e: Exception) {
        android.util.Log.e("TicketHomeWidget", "Manual parsing also failed", e)
        setErrorState(views, "Unable to parse ticket")
    }

    // Update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}

private fun extractValue(jsonString: String, key: String): String? {
    return try {
        val pattern = "\"$key\"\\s*:\\s*\"([^\"]*)\""
        val regex = Regex(pattern)
        val match = regex.find(jsonString)
        match?.groupValues?.get(1)
    } catch (e: Exception) {
        android.util.Log.w("TicketHomeWidget", "Failed to extract $key", e)
        null
    }
}