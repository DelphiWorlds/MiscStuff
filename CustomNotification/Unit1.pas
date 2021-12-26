unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, System.Notification, FMX.Objects;

type
  TForm1 = class(TForm)
    NotificationCenter: TNotificationCenter;
    Button1: TButton;
    Image: TImage;
    procedure Button1Click(Sender: TObject);
  private
    procedure CreateChannel;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  Androidapi.Helpers, Androidapi.JNI.JavaTypes, Androidapi.JNI.Widget, Androidapi.JNI.GraphicsContentViewText,
  // DW.Androidapi.JNI.SupportV4,  <--- 10.4
  DW.Androidapi.JNI.AndroidX.App, Androidapi.JNI.App,
  DW.Android.Helpers, DW.Graphics.Helpers.Android;

constructor TForm1.Create(AOwner: TComponent);
begin
  inherited;
  CreateChannel;
end;

procedure TForm1.CreateChannel;
var
  LChannel: TChannel;
begin
  LChannel := NotificationCenter.CreateChannel;
  try
    LChannel.Id := 'CNTest';
    LChannel.Title := LChannel.Id;
    LChannel.Importance := TImportance.High;
    NotificationCenter.CreateOrUpdateChannel(LChannel);
  finally
    LChannel.Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  LBuilder: JNotificationCompat_Builder;
  LCustomContent: JRemoteViews;
  LTitle, LBody: string;
  LIconId, LResId: Integer;
begin
  LTitle := 'Testing';
  LBody := 'A whole buncho text'; // or will be, later

  LCustomContent := TJRemoteViews.JavaClass.init(TAndroidHelper.Context.getPackageName, TAndroidHelper.GetResourceID('layout/notification_big'));
  LResId := TAndroidHelper.GetResourceID('id/notification_big_title');
  Log.d('ResId: %d', [LResId]);
  LCustomContent.setTextViewText(LResId, StrToJCharSequence(LTitle));
  LCustomContent.setTextViewText(TAndroidHelper.GetResourceID('id/notification_big_body'), StrToJCharSequence(LBody));
  LCustomContent.setImageViewBitmap(TAndroidHelper.GetResourceID('id/notification_big_image'), Image.Bitmap.ToJBitmap);

  LIconId := TAndroidHelper.GetResourceID('drawable/ic_notification');
  LBuilder := TJNotificationCompat_Builder.JavaClass.init(TAndroidHelper.Context)
    .setChannelId(StringToJString('CNTest'))
    .setSmallIcon(LIconId)
    .setCustomContentView(LCustomContent)
    .setStyle(TJNotificationCompat_DecoratedCustomViewStyle.JavaClass.init)
    .setContentTitle(StrToJCharSequence(LTitle))
    .setContentText(StrToJCharSequence('A whole buncho text'));
  TAndroidHelperEx.NotificationManager.notify(1234, LBuilder.build);
end;

end.
