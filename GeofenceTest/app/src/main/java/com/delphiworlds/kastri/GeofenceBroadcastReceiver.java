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
import android.text.TextUtils;

/**
 * Abstract receiver for geofence transition change BROADCASTS.
 * <p>
 * Receives geofence transition changes from GeofenceTransitionsService in the form of an Intent containing
 * the transition type and geofence id(s) that triggered the transition
 */
public abstract class GeofenceBroadcastReceiver extends BroadcastReceiver {

    /**
     * Receives incoming LOCAL BROADCASTS.
     *
     * @param context the application context.
     * @param intent  sent by GeofenceTransitionsService.
     */
    @Override
    public void onReceive(Context context, Intent intent) {
        //!!!! check intent action
        handleTransition(context, intent.getIntExtra("TRANSITION", 0), TextUtils.split(intent.getStringExtra("IDS"), ","));
    }

    public abstract void handleTransition(Context context, int transition, String[] ids);

}

/*
* Example concrete class:
*/

/*
public class iFireGeofenceBroadcastReceiver extends BroadcastReceiver {

    public void handleTransition(Context context, int transition, String[] ids) {
        // transition: 1 = Enter, 2 = Exit
        // Create an http client and send a request wherever
        for (String id: ids) {           
            // Do your stuff here
            System.out.println(id); 
        }
    }
}
*/