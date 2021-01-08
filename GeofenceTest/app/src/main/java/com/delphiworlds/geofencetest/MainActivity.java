package com.delphiworlds.geofencetest;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;

import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import com.delphiworlds.kastri.GeofenceManager;
import com.delphiworlds.kastri.GeofenceManagerDelegate;
import com.delphiworlds.kastri.GeofenceRegions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class MainActivity extends AppCompatActivity {

    private TextView logTextView;
    private ListView geofenceListView;
    private GeofenceManager mManager;

    private static final int GEOFENCE_PERMISSION_REQUEST_CODE = 100;
    private static final String PERMISSION_ACCESS_BACKGROUND_LOCATION = "android.permission.ACCESS_BACKGROUND_LOCATION";
    private static final String PERMISSION_ACCESS_FINE_LOCATION = "android.permission.ACCESS_FINE_LOCATION";

    private void logMessage(String msg) {
        logTextView.setText(logTextView.getText() + "\n" + msg);
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    private void requestGeofencePermissions() {
        String[] permissions = {PERMISSION_ACCESS_FINE_LOCATION, PERMISSION_ACCESS_BACKGROUND_LOCATION};
        requestPermissions(permissions, GEOFENCE_PERMISSION_REQUEST_CODE);
    }

    private void startGeofences() {
        if (!mManager.getIsMonitoring())
            mManager.start();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Button startButton = findViewById(R.id.startButton);
        Button stopButton = findViewById(R.id.stopButton);
        Button clearButton = findViewById(R.id.clearButton);
        Button mockButton = findViewById(R.id.mockButton);
        logTextView = findViewById(R.id.logTextView);
        geofenceListView = findViewById(R.id.geofenceListView);

        mManager = new GeofenceManager(this,
                new GeofenceManagerDelegate() {
                    @Override
                    public void onGeofenceActionComplete(int action, int result, String errorMessage) {
                        logMessage("Action: " + Integer.toString(action) + ", Result: " + Integer.toString(result) + ", Message: " + errorMessage);
                    }
                }
        );
        mManager.getRegions().load();
        if (mManager.getRegions().getItems().size() == 0) {
            mManager.getRegions().add("Home", 34.8878, 138.5853, 100);
            mManager.getRegions().add("Google", 37.4216204, -122.0835415, 2000);
            mManager.getRegions().add("EMBT", 30.397595, -97.7329564, 100);
            mManager.getRegions().add("Apple", 37.3318662, -122.0324451, 100);
        }

        ArrayList<String> items = new ArrayList<String>();
        for (Map.Entry<String, GeofenceRegions.Region> entry : mManager.getRegions().getItems().entrySet()) {
            GeofenceRegions.Region region = entry.getValue();
            items.add("ID: " + region.getId() + ", Lat: " + Double.toString(region.getCoords().latitude) + ", Long: " + Double.toString(region.getCoords().longitude));
        }
        ArrayAdapter arrayAdapter = new ArrayAdapter(this, android.R.layout.simple_list_item_1, items);
        geofenceListView.setAdapter(arrayAdapter);

        startButton.setOnClickListener(
                new View.OnClickListener() {
                    @RequiresApi(api = Build.VERSION_CODES.M)
                    @Override
                    public void onClick(View v) {
                        requestGeofencePermissions();
                    }
                }
        );

        stopButton.setOnClickListener(
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mManager.stop();
                    }
                }
        );
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        switch (requestCode) {
            case GEOFENCE_PERMISSION_REQUEST_CODE:
                if (grantResults.length > 1 && grantResults[0] == PackageManager.PERMISSION_GRANTED && grantResults[1] == PackageManager.PERMISSION_GRANTED) {
                    startGeofences();
                }  else {
                    // Explain to the user that the feature is unavailable because
                    // the features requires a permission that the user has denied.
                    // At the same time, respect the user's decision. Don't link to
                    // system settings in an effort to convince the user to change
                    // their decision.
                }
                return;
        }
    }
}