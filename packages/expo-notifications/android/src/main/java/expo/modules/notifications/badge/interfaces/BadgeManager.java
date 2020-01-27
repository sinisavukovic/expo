package expo.modules.notifications.badge.interfaces;

import org.unimodules.core.errors.CodedRuntimeException;

public interface BadgeManager {
  int getBadgeCount();

  void setBadgeCount(int badgeCount) throws CodedRuntimeException;
}
