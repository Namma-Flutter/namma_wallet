//package com.nammaflutter.nammawallet
//
//import android.app.PendingIntent
//import android.content.Context
//import android.content.Intent
//import android.widget.RemoteViews
//import android.widget.RemoteViewsService
//import org.json.JSONArray
//
//class TicketListWidgetFactory(private val context: Context) :
//    RemoteViewsService.RemoteViewsFactory {
//
//    private var tickets = JSONArray()
//
//    override fun onDataSetChanged() {
//        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
//        tickets = JSONArray(prefs.getString("ticket_list", "[]"))
//    }
//
//    override fun getCount(): Int = tickets.length()
//
//    override fun getViewAt(position: Int): RemoteViews {
//        val obj = tickets.getJSONObject(position)
//        val views = RemoteViews(context.packageName, R.layout.ticket_list_item)
//
//        // TEXTS
//        views.setTextViewText(R.id.primaryText, obj.optString("primary_text"))
//        views.setTextViewText(R.id.locationText, obj.optString("location"))
//        views.setTextViewText(R.id.startTimeText, obj.optString("start_time"))
//
//        val extras = obj.optJSONArray("extras")
//        if (extras != null && extras.length() > 0) {
//            views.setTextViewText(R.id.providerText, extras.getJSONObject(0).optString("value"))
//        }
//
//        // ICON
//        when (obj.optString("type")) {
//            "TRAIN" -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_train)
//            "BUS" -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_bus)
//            "FLIGHT" -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_flight)
//            else -> views.setImageViewResource(R.id.typeIcon, R.drawable.ic_ticket)
//        }
//
//        // UNPIN action
//        val intent = Intent(context, TicketHomeWidget::class.java).apply {
//            action = TicketHomeWidget.ACTION_UNPIN
//            putExtra(TicketHomeWidget.EXTRA_TICKET_INDEX, position)
//        }
//
//        val pending = PendingIntent.getBroadcast(
//            context,
//            position,
//            intent,
//            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
//        )
//
//        views.setOnClickPendingIntent(R.id.pinIcon, pending)
//
//        return views
//    }
//
//    override fun getViewTypeCount(): Int = 1
//    override fun hasStableIds(): Boolean = true
//    override fun getLoadingView(): RemoteViews? = null
//    override fun getItemId(position: Int): Long = position.toLong()
//    override fun onCreate() {}
//    override fun onDestroy() {}
//}
