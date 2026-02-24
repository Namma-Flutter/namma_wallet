package com.nammaflutter.nammawallet

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

class MainTicketWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "MainTicketWidget"
        const val ACTION_UNPIN_MAIN = "com.nammaflutter.nammawallet.UNPIN_MAIN_TICKET"

        fun updateWidget(
            context: Context,
            manager: AppWidgetManager,
            widgetId: Int
        ) {
            Log.d(TAG, "Updating widget $widgetId")

            try {
                val views = RemoteViews(context.packageName, R.layout.main_ticket_widget)

                // Fetch data
                val prefs =
                    context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
                val json = prefs.getString("ticket_list", "[]") ?: "[]"

                // Log the raw JSON to debug
                Log.d(TAG, "Reading JSON from prefs: $json")

                val arr = try {
                    JSONArray(json)
                } catch (e: JSONException) {
                    Log.e(TAG, "Failed to parse ticket_list JSON. Malformed data: $json", e)
                    // Reset stored preference to valid empty array
                    prefs.edit().putString("ticket_list", "[]").apply()
                    // Fall back to empty array
                    JSONArray()
                }

                if (arr.length() > 0) {
                    // Get LAST ticket
                    val ticket = arr.getJSONObject(arr.length() - 1)
                    Log.d(TAG, "Binding ticket: $ticket")

                    bindTicketData(context, views, ticket)

                    // Show content, hide empty
                    views.setViewVisibility(R.id.contentView, View.VISIBLE)
                    views.setViewVisibility(R.id.emptyView, View.GONE)

                    // Setup Unpin Intent
                    val unpinIntent = Intent(context, MainTicketWidgetProvider::class.java).apply {
                        action = ACTION_UNPIN_MAIN
                    }
                    val pendingIntent = PendingIntent.getBroadcast(
                        context,
                        0,
                        unpinIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                    )
                    views.setOnClickPendingIntent(R.id.unpinButton, pendingIntent)

                } else {
                    Log.d(TAG, "Ticket list is empty")
                    // Empty state
                    views.setViewVisibility(R.id.contentView, View.GONE)
                    views.setViewVisibility(R.id.emptyView, View.VISIBLE)
                }

                manager.updateAppWidget(widgetId, views)
            } catch (e: Exception) {
                Log.e(TAG, "Critical error updating widget", e)
            }
        }

        private fun bindTicketData(context: Context, views: RemoteViews, ticket: JSONObject) {
            // Primary Text
            val primaryText = ticket.optString("primary_text", "Ticket")
            views.setTextViewText(R.id.primaryText, primaryText)

            // Secondary Text
            val secondaryText = ticket.optString("secondary_text", "")
            views.setTextViewText(R.id.secondaryText, secondaryText)

            // Location
            val location = ticket.optString("location", "Unknown Location")
            views.setTextViewText(R.id.locationText, location)

            // Time
            val startTime = ticket.optString("start_time", "Time N/A")
            views.setTextViewText(R.id.dateTimeText, startTime)

            // Icon
            val type = ticket.optString("type", "GENERAL").uppercase()
            when (type) {
                "TRAIN" -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_train)
                "BUS" -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_bus)
                "FLIGHT" -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_flight)
                "EVENT" -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_event)
                else -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_ticket)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        Log.d(TAG, "onReceive: ${intent.action}")

        if (intent.action == ACTION_UNPIN_MAIN) {
            unpinLastTicket(context)
        } else if (intent.action == "com.nammaflutter.nammawallet.UPDATE_TICKET_LIST") {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(
                    context,
                    MainTicketWidgetProvider::class.java
                )
            )
            for (id in ids) {
                updateWidget(context, manager, id)
            }
        }
    }

    private fun unpinLastTicket(context: Context) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val json = prefs.getString("ticket_list", "[]") ?: "[]"

        val arr = try {
            JSONArray(json)
        } catch (e: JSONException) {
            Log.e(TAG, "Failed to parse ticket_list JSON. Malformed data: $json", e)
            // Reset stored preference to valid empty array
            prefs.edit().putString("ticket_list", "[]").apply()
            // Fall back to empty array so widget doesn't crash
            JSONArray()
        }

        if (arr.length() > 0) {
            // Remove LAST element
            arr.remove(arr.length() - 1)
            prefs.edit().putString("ticket_list", arr.toString()).apply()

            // Update Main Widget
            val manager = AppWidgetManager.getInstance(context)
            val mainIds = manager.getAppWidgetIds(
                ComponentName(
                    context,
                    MainTicketWidgetProvider::class.java
                )
            )
            for (id in mainIds) {
                updateWidget(context, manager, id)
            }

            // Update List Widget too!
            val listIds = manager.getAppWidgetIds(
                ComponentName(
                    context,
                    TicketListWidgetProvider::class.java
                )
            )
            for (id in listIds) {
                TicketListWidgetProvider.updateWidget(context, manager, id)
            }
        }
    }
}
