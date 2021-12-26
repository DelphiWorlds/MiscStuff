# Custom Notification test project

## Purpose

To display notifications with a custom layout

## Description

[Creating custom notifications](https://developer.android.com/training/notify-user/custom-notification) is possible with Delphi by creating a layout resource (either by hand, or with Android Studio), deploying it with the application and using API calls to obtain the resource ids for the layout and its elements.

## The problem

According to the documentation (in the link above), a TextView can have a `style` attribute that is specified as per their example:

```
<TextView
    android:layout_width="wrap_content"
    android:layout_height="match_parent"
    android:layout_weight="1"
    android:text="@string/notification_title"
    android:id="@+id/notification_title"
    style="@style/TextAppearance.Compat.Notification.Title" />
```

Unfortunately, in Delphi this results in an error during packaging in the deployment process:

```
[PAClient Error] Error: E2312 Z:\Public\MiscStuff\CustomNotification\Android\Debug\CustomNotificationTest\res\layout\notification_big.xml:9: error: Error: No resource found that matches the given name (at 'style' with value '@style/TextAppearance.Compat.Notification.Title').
```

I'm assuming I need to find the appropriate file(s) containing the required styles, but don't know where exactly to find them

