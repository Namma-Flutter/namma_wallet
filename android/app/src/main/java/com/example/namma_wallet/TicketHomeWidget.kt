package com.example.namma_wallet

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject

/**
 * Implementation of App Widget functionality.
 */
class TicketHomeWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            // get data from the flutter app

            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.ticket_home_widget)
                val ticketJson = widgetData.getString("text_from_flutter_app", null)
            if(ticketJson !=null){


              try  {
                    val json = JSONObject(ticketJson);

                    val ticketId = json.optString("ticket_id", "N/A")
                    val userName = json.optString("user_full_name", "Unknown")

                  views.setTextViewText(R.id.ticket_id, "Ticket: $ticketId")
                  views.setTextViewText(R.id.user_name, "User: $userName")                }  catch (e: Exception){
                    views.setTextViewText(R.id.ticket_id, "Error parsing data")


                }          }else{

                views.setTextViewText(R.id.ticket_id, "No ticket data")

            }





// app update widget
            appWidgetManager.updateAppWidget(appWidgetId, views)


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
    val widgetText = context.getString(R.string.appwidget_text)
    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, R.layout.ticket_home_widget)
    views.setTextViewText(R.id.ticket_id, widgetText)

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}