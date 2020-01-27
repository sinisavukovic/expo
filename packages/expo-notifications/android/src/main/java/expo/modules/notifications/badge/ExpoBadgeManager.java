package expo.modules.notifications.badge;

import android.content.Context;

import org.unimodules.core.errors.CodedRuntimeException;
import org.unimodules.core.interfaces.SingletonModule;

import expo.modules.notifications.badge.interfaces.BadgeManager;
import me.leolin.shortcutbadger.ShortcutBadgeException;
import me.leolin.shortcutbadger.ShortcutBadger;

public class ExpoBadgeManager implements SingletonModule, BadgeManager {
  private static final String SINGLETON_NAME = "BadgeManager";

  private int mBadgeCount = 0;
  private Context mContext;

  public ExpoBadgeManager(Context context) {
    mContext = context;
  }

  @Override
  public String getName() {
    return SINGLETON_NAME;
  }

  @Override
  public int getBadgeCount() {
    return mBadgeCount;
  }

  @Override
  public void setBadgeCount(int badgeCount) throws RuntimeException {
    try {
      ShortcutBadger.applyCountOrThrow(mContext.getApplicationContext(), badgeCount);
      mBadgeCount = badgeCount;
    } catch (ShortcutBadgeException e) {
      throw new SetBadgeException(e.getMessage() + ": " + e.getCause().getMessage(), e);
    }
  }

  public static class SetBadgeException extends CodedRuntimeException {
    private static final String CODE = "ERR_NOTIFICATION_BADGE";

    public SetBadgeException(String message, Throwable cause) {
      super("Unable to set badge count: " + message, cause);
    }

    @Override
    public String getCode() {
      return CODE;
    }
  }
}
