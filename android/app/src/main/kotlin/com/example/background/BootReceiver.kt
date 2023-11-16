package com.example.background

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import androidx.core.content.ContextCompat


class BootReceiver:BroadcastReceiver() {
  override fun onReceive(context:Context, intent:Intent) {
    val h = Handler()
    h.post(object:Runnable {
      public override fun run() {
        val intent = Intent(context, BackgroundService::class.java)
        ContextCompat.startForegroundService(context, intent)
      }
    })
  }
}
