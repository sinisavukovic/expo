package expo.modules.notifications.notifications.interfaces;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.Nullable;

/**
 * Class representing behavior which should be applied
 * to a notification.
 */
public class NotificationBehavior implements Parcelable {
  private boolean mShouldShowAlert;
  private boolean mShouldPlaySound;
  private boolean mShouldSetBadge;

  @Nullable
  private String mPriorityOverride;

  public NotificationBehavior(boolean shouldShowAlert, boolean shouldPlaySound, boolean shouldSetBadge, @Nullable String priorityOverride) {
    mShouldShowAlert = shouldShowAlert;
    mShouldPlaySound = shouldPlaySound;
    mShouldSetBadge = shouldSetBadge;
    mPriorityOverride = priorityOverride;
  }

  private NotificationBehavior(Parcel in) {
    mShouldShowAlert = in.readByte() != 0;
    mShouldPlaySound = in.readByte() != 0;
    mShouldSetBadge = in.readByte() != 0;
    mPriorityOverride = in.readString();
  }

  @Override
  public void writeToParcel(Parcel dest, int flags) {
    dest.writeByte((byte) (mShouldShowAlert ? 1 : 0));
    dest.writeByte((byte) (mShouldPlaySound ? 1 : 0));
    dest.writeByte((byte) (mShouldSetBadge ? 1 : 0));
    dest.writeString(mPriorityOverride);
  }

  @Override
  public int describeContents() {
    return 0;
  }

  public static final Creator<NotificationBehavior> CREATOR = new Creator<NotificationBehavior>() {
    @Override
    public NotificationBehavior createFromParcel(Parcel in) {
      return new NotificationBehavior(in);
    }

    @Override
    public NotificationBehavior[] newArray(int size) {
      return new NotificationBehavior[size];
    }
  };

  /**
   * @return Priority which should be assigned to the notification.
   */
  @Nullable
  public String getPriorityOverride() {
    return mPriorityOverride;
  }

  /**
   * @return Whether to show a heads-up alert.
   */
  public boolean shouldShowAlert() {
    return mShouldShowAlert;
  }

  /**
   * @return Whether the notification should be accompanied by a sound.
   */
  public boolean shouldPlaySound() {
    return mShouldPlaySound;
  }

  /**
   * @return Whether badge count that may be contained in the notification should be applied.
   */
  public boolean shouldSetBadge() {
    return mShouldSetBadge;
  }

  /**
   * @return Whether the notification may have any user-facing effect.
   */
  public boolean hasAnyEffect() {
    return shouldShowAlert() || shouldPlaySound() || shouldSetBadge();
  }
}
