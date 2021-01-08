package com.delphiworlds.kastri;

// Based on: https://github.com/android/location-samples/blob/master/Geofencing/app/src/main/java/com/google/android/gms/location/sample/geofencing/GeofenceTransitionsJobIntentService.java

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;

// android.support.v4
import androidx.core.app.JobIntentService;
import androidx.core.app.NotificationCompat;
import androidx.core.app.TaskStackBuilder;

// play-services-location.jar  (17.0.0 may be compatible with 10.4.1)
import com.google.android.gms.location.Geofence;
import com.google.android.gms.location.GeofencingEvent;
import com.google.android.gms.location.GeofenceStatusCodes;

import java.util.ArrayList;
import java.util.List;

/**
 * Listener for geofence transition changes.
 *
 * Receives geofence transition events from Location Services in the form of an Intent containing
 * the transition type and geofence id(s) that triggered the transition. Creates a notification
 * as the output.
 */
public class GeofenceTransitionsService extends JobIntentService {

    private static final int JOB_ID = 535;  // Just a random number
    private static final String TAG = "TransitionsService";
    private static final String CHANNEL_ID = "GeofenceTransitionsServiceChannel";

    public static String getErrorString(int errorCode) {
        switch (errorCode) {
            case GeofenceStatusCodes.GEOFENCE_NOT_AVAILABLE:
                return "Geofence not available";  // mResources.getString(R.string.geofence_not_available);
            case GeofenceStatusCodes.GEOFENCE_TOO_MANY_GEOFENCES:
                return "Too many geofences"; // mResources.getString(R.string.geofence_too_many_geofences);
            case GeofenceStatusCodes.GEOFENCE_TOO_MANY_PENDING_INTENTS:
                return "Too many pending intents"; // mResources.getString(R.string.geofence_too_many_pending_intents);
            default:
                return "Unknown geofence error"; // mResources.getString(R.string.unknown_geofence_error);
        }
    }
    
    //!!!!! Possibly move this out into a utils class
    private String getApplicationLabel(Context context) {
        PackageManager packageManager = context.getPackageManager();
        ApplicationInfo info = null;
        try {
            info = packageManager.getApplicationInfo(context.getApplicationInfo().packageName, 0);
        } catch (final PackageManager.NameNotFoundException e) {
            // Do nothing
        }
        return (String) (info != null ? packageManager.getApplicationLabel(info) : "Unknown");
    }

    private int getIntProperty(String name) {
        SharedPreferences pref = getSharedPreferences("Geofence", Context.MODE_PRIVATE);
        return pref.getInt(name, 0);
    }

    private boolean getUsesTransition(String name, int transitionType) {
        return (getIntProperty(name) & transitionType) > 0;
    }

    /**
     * Posts a notification in the notification bar when a transition is detected.
     * If the user clicks the notification, control goes to the MainActivity.
     */
    private void sendNotification(String title, String body) throws ClassNotFoundException {
        // Get an instance of the Notification manager
        NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        // Android O requires a Notification Channel.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = getApplicationLabel(this);
            // Create the channel for the notification
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, name, NotificationManager.IMPORTANCE_DEFAULT);
            channel.enableLights(true);
            channel.enableVibration(true);
            channel.setLightColor(Color.GREEN);
            channel.setLockscreenVisibility(NotificationCompat.VISIBILITY_PRIVATE);
            channel.setImportance(NotificationManager.IMPORTANCE_HIGH);
            // Set the Notification Channel for the Notification Manager.
            manager.createNotificationChannel(channel);
        }
        // Create an explicit content Intent that starts the main Activity.
        Class activityClass = Class.forName("com.embarcadero.firemonkey.FMXNativeActivity");
        Intent notificationIntent = new Intent(getApplicationContext(), activityClass);
        // notificationIntent.setClassName(getApplicationContext(), "com.embarcadero.firemonkey.FMXNativeActivity");
        // Construct a task stack.
        TaskStackBuilder stackBuilder = TaskStackBuilder.create(this);
        // Add the main Activity to the task stack as the parent.
        stackBuilder.addParentStack(activityClass);
        // Push the content Intent onto the stack.
        stackBuilder.addNextIntent(notificationIntent);
        // Get a PendingIntent containing the entire back stack.
        PendingIntent notificationPendingIntent = stackBuilder.getPendingIntent(0, PendingIntent.FLAG_UPDATE_CURRENT);
        // Get a notification builder that's compatible with platform versions >= 4
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this);
        // Define the notification settings.
        builder.setSmallIcon(getApplicationInfo().icon)
            // In a real app, you may want to use a library like Volley
            // to decode the Bitmap.
            // .setLargeIcon(BitmapFactory.decodeResource(getResources(), smallIcon))
            .setColor(Color.RED) // Perhaps allow the user to choose the color, using GeofenceManager
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(notificationPendingIntent);
        // Set the Channel ID for Android O.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            builder.setChannelId(CHANNEL_ID); // Channel ID
        }
        // Dismiss notification once the user touches it.
        builder.setAutoCancel(true);
        // Issue the notification
        manager.notify(0, builder.build());
    }

    /**
     * Handles incoming intents.
     * @param intent sent by Location Services. This Intent is provided to Location
     *               Services (inside a PendingIntent) when addGeofences() is called.
     */
    @Override
    protected void onHandleWork(Intent intent) {
        Log.d(TAG, "onHandleWork");
        GeofencingEvent geofencingEvent = GeofencingEvent.fromIntent(intent);
        if (geofencingEvent.hasError()) {
            String errorMessage = getErrorString(geofencingEvent.getErrorCode());
            Log.e(TAG, errorMessage);
            return;
        }
        // Get the transition type.
        int geofenceTransition = geofencingEvent.getGeofenceTransition();
        Log.d(TAG, "geofenceTransition type: " + Integer.toString(geofenceTransition));
        // Test that the reported transition was of interest.
        if ((geofenceTransition == Geofence.GEOFENCE_TRANSITION_ENTER) || (geofenceTransition == Geofence.GEOFENCE_TRANSITION_EXIT)) {
            // Get the geofences that were triggered. A single event can trigger multiple geofences.
            List<Geofence> geofences = geofencingEvent.getTriggeringGeofences();
            // Get the transition details as a String.
            // Nope ****** String geofenceTransitionDetails = getGeofenceTransitionDetails(geofenceTransition, triggeringGeofences);
            // ******* This is the point where the service needs to interact with the data produced by Delphi ******
            // Either have a separate store for Android for memos/locations, or work out a "Java" way of accessing the data
            // Which is stored in: ?????
            ArrayList<String> idsList = new ArrayList<>();
            for (Geofence geofence : geofences) {
                idsList.add(geofence.getRequestId()); // same as id in regions
            }
            String ids = TextUtils.join(", ", idsList);
            if (getUsesTransition("BroadcastTransitionTypes", geofenceTransition)) {
                // Send a local broadcast with the ids
            }
            if (getUsesTransition("NotificationTransitionTypes", geofenceTransition)) {
                Log.d(TAG, "Preparing notification");
                SharedPreferences pref = getSharedPreferences("Geofence", Context.MODE_PRIVATE);
                String body = pref.getString("NotificationBody", "");
                String title = "Arrival at: ";
                title = title.concat(ids);
                // Send notification
                try {
                    sendNotification(title, body);
                } catch (ClassNotFoundException e) {
                    Log.e(TAG, "sendNotification threw an exception: " + e.getMessage());
                }
            }
            Log.i(TAG, "Transition type: " + Integer.toString(geofenceTransition) + " for: " + ids);
        } else {
            // Log the error.
            Log.e(TAG, "Unknown geofence transition type");
        }
    }

    /**
     * Convenience method for enqueuing work in to this service.
     */
    public static void enqueueWork(Context context, Intent intent) {
        Log.d(TAG, "enqueueWork");
        enqueueWork(context, GeofenceTransitionsService.class, JOB_ID, intent);
    }

}