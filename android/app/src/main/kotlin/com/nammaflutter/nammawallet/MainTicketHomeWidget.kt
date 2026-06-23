// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This is a placeholder Glance (Jetpack Compose) widget.
package com.nammaflutter.nammawallet

import androidx.compose.runtime.Composable
import android.content.Context
import androidx.compose.ui.graphics.Color
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Box
import androidx.glance.layout.fillMaxSize
import androidx.glance.text.Text
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import androidx.glance.layout.Column
import androidx.glance.layout.Alignment
import androidx.glance.text.TextStyle
import androidx.glance.color.ColorProvider
import androidx.glance.GlanceTheme
import androidx.compose.ui.unit.sp
import androidx.glance.text.FontWeight
import androidx.glance.layout.Spacer
import androidx.compose.ui.unit.dp
import androidx.glance.layout.padding

class MainTicketHomeWidget : GlanceAppWidget() {
  override val stateDefinition = HomeWidgetGlanceStateDefinition()

  override suspend fun provideGlance(context: Context, id: GlanceId) {
    provideContent { WidgetContent(context, currentState()) }
  }

  @Composable
  private fun WidgetContent(context: Context, currentState: HomeWidgetGlanceState) {
    val prefs = currentState.preferences
    val widgetData = MainTicketData.fromPreferences(prefs)
    GlanceTheme {
            Box(modifier = GlanceModifier.background(GlanceTheme.colors.widgetBackground).padding(16.dp).fillMaxSize(), contentAlignment = Alignment.Center) {
                if (widgetData.ticketId != null) {
                    Column(modifier = GlanceModifier.fillMaxSize().padding(start = 16.0.dp, top = 16.0.dp, end = 16.0.dp, bottom = 16.0.dp), horizontalAlignment = Alignment.Start) {
                        Text(text = widgetData.type ?: "", style = TextStyle(color = GlanceTheme.colors.primaryContainer, fontSize = 14.sp, fontWeight = FontWeight.Bold))
                        Text(text = widgetData.primaryText ?: "", modifier = GlanceModifier.padding(top = 4.dp), style = TextStyle(color = GlanceTheme.colors.onSurface, fontSize = 22.sp, fontWeight = FontWeight.Bold))
                        Text(text = widgetData.secondaryText ?: "", modifier = GlanceModifier.padding(top = 2.dp), style = TextStyle(color = GlanceTheme.colors.onSurfaceVariant, fontSize = 14.sp))
                        Text(text = widgetData.startTime ?: "", modifier = GlanceModifier.padding(top = 12.dp), style = TextStyle(color = GlanceTheme.colors.onSurface, fontSize = 14.sp, fontWeight = FontWeight.Bold))
                        Text(text = widgetData.location ?: "", modifier = GlanceModifier.padding(top = 2.dp), style = TextStyle(color = GlanceTheme.colors.onSurfaceVariant, fontSize = 13.sp))
                    }
                } else {
                    Column(modifier = GlanceModifier.fillMaxSize().padding(start = 16.0.dp, top = 16.0.dp, end = 16.0.dp, bottom = 16.0.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                        Spacer(modifier = GlanceModifier.defaultWeight())
                        Text(text = "No Ticket Pinned", style = TextStyle(color = GlanceTheme.colors.onSurfaceVariant, fontSize = 16.sp, fontWeight = FontWeight.Bold))
                        Text(text = "Pin a ticket from the app", style = TextStyle(color = GlanceTheme.colors.outline, fontSize = 12.sp))
                        Spacer(modifier = GlanceModifier.defaultWeight())
                    }
                }
            }
    }

  }
}

data class MainTicketData(
    val ticketId: String? = null,
    val type: String? = null,
    val primaryText: String? = null,
    val secondaryText: String? = null,
    val startTime: String? = null,
    val location: String? = null,
) {
    companion object {
        private const val PREFERENCES_PREFIX = "home_widget.MainTicket"

        fun fromPreferences(prefs: android.content.SharedPreferences): MainTicketData {
            return MainTicketData(
                ticketId = prefs.getString("${PREFERENCES_PREFIX}.ticketId", null),
                type = prefs.getString("${PREFERENCES_PREFIX}.type", ""),
                primaryText = prefs.getString("${PREFERENCES_PREFIX}.primaryText", ""),
                secondaryText = prefs.getString("${PREFERENCES_PREFIX}.secondaryText", ""),
                startTime = prefs.getString("${PREFERENCES_PREFIX}.startTime", ""),
                location = prefs.getString("${PREFERENCES_PREFIX}.location", ""),
            )
        }
    }
}

