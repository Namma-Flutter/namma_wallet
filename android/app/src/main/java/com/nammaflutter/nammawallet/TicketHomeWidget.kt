package com.nammaflutter.nammawallet

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import org.json.JSONObject

class TicketHomeWidget : AppWidgetProvider() {

    override fun onUpdate(context: Context, manager: AppWidgetManager, widgetIds: IntArray) {
        widgetIds.forEach { updateWidget(context, manager, it) }
    }

    companion object {

        fun updateWidget(context: Context, manager: AppWidgetManager, widgetId: Int) {

            val views = RemoteViews(context.packageName, R.layout.ticket_home_widget)

            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            val json = prefs.getString("ticket_data", null)

            if (json != null) {
                try {
                    val data = JSONObject(json)

                    // TITLE
                    views.setTextViewText(R.id.primaryText, data.optString("primary_text"))

                    // TYPE ICON
                    when (data.optString("type")) {
                        "TRAIN" -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_train)
                        "BUS" -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_bus)
                        "FLIGHT" -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_flight)
                        else -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_ticket)
                    }

                    // LOCATION
                    views.setTextViewText(R.id.locationText, data.optString("location"))

                    // START TIME
                    views.setTextViewText(R.id.startTimeText, data.optString("start_time"))

                    // PROVIDER (from extras[0])
                    val extras = data.optJSONArray("extras")
                    if (extras != null && extras.length() > 0) {
                        val provider = extras.getJSONObject(0).optString("value")
                        views.setTextViewText(R.id.providerText, provider)
                    }

                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }

            manager.updateAppWidget(widgetId, views)
        }
    }
}
