package com.delphiworlds.kastri;

/*******************************************************
 *                                                     *
 *                     Kastri                          *
 *                                                     *
 *        Delphi Worlds Cross-Platform Library         *
 *                                                     *
 *   Copyright 2020 Dave Nottage under MIT license     *
 * which is located in the root folder of this library *
 *                                                     *
 *******************************************************/

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
// import androidx.
import android.util.Log;

/**
 * Receiver for geofence transition INTENTS. Registered as the receiver in the constructor of GeofenceManager 
 *   NOTE: This is not the receiver that you modify for your own purposes. Please use GeofenceBroadcastReceiver for that
 * <p>
 * Receives geofence transition events from Location Services in the form of an Intent containing
 * the transition type and geofence id(s) that triggered the transition. Creates a JobIntentService descendant
 * that will handle the intent in the background.
 */
public class GeofenceIntentReceiver extends BroadcastReceiver {

    private static final String TAG = "GeofenceIntentReceiver";
    public static final String ACTION_RECEIVE_GEOFENCE = "com.delphiworlds.kastri.GeofenceIntentReceiver.ACTION_RECEIVE_GEOFENCE";

    /**
     * Receives incoming intents.
     *
     * @param context the application context.
     * @param intent  sent by Location Services. This Intent is provided to Location
     *                Services (inside a PendingIntent) when addGeofences() is called.
     */
    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d(TAG, "onReceive");
        // Debugging - send a broadcast so the app can receive it
        Intent local = new Intent(intent);
        local.setAction("DEBUG");
        local.putExtra("INFO", TAG);
        LocalBroadcastManager.getInstance(context).sendBroadcast(local);
        // Enqueues a JobIntentService descendant passing the context and intent as parameters
        GeofenceTransitionsService.enqueueWork(context, intent);
    }
}