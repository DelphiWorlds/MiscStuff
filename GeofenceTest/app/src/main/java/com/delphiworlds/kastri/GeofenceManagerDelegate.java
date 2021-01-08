package com.delphiworlds.kastri;

public interface GeofenceManagerDelegate {

  void onGeofenceActionComplete(int action, int result, String errorMessage);
    
}