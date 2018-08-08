# FCM Revisited

The project in this folder is a work in progress of an update to the Kastri Free Firebase Cloud Messaging support.

So far, it is implemented (partially) for the Android platform only, and at present is not working, which is why it is here.


# Compiling

I have included all required files, so it should not be necessary to check out or download any of the Kastri Free library; you should be able to just load up the FCMRevisited demo in the Demos\FCMRevisited folder, and compile. Note that the first compile will take a couple of minutes while Delphi "dexes" the .jars associated with the project. subsequent compiles should not take as long.


# Firebase Messaging SDK

*** NOTE: This project uses the latest Firebase Messaging SDK (v17.1.0), which is different to that being used in the Alcinoe implementation ***

One major difference is that the FirebaseInstanceIdService has been DEPRECATED


# Seeking help

I am seeking help with making it work. The application compiles, starts, and according to messages in LogCat it successfully initializes Firebase, however it does not work as expected, i.e. no token is generated.

The button on the main form executes Java code in the dw-firebase.jar that corresponds to the code here (the part after the // Get token comment):

  https://github.com/firebase/quickstart-android/blob/master/messaging/app/src/main/java/com/google/firebase/quickstart/fcm/MainActivity.java#L99

Except that the call to FirebaseInstanceId.getInstance() returns null, and I'm unable to determine why (Note: FirebaseInstanceId.getInstance().getInstanceId() obviously fails since FirebaseInstanceId.getInstance() is null)


# Possible reasons why it does not work

I expect that the issue may be something I missed in AndroidManifest.template.xml, or perhaps a .jar that should have been included that has been missed, or perhaps there's something else I need to do to make it work on Android 8.1 (which is what my device has)


# Feedback

Please direct feedback preferably via my Slack team (you can invite yourself via: http://slack.freedelphicode.com:8080/), or via email to: davidn@radsoft.com.au

  