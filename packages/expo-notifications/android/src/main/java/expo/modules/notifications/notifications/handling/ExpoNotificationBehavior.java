package expo.modules.notifications.notifications.handling;

import org.unimodules.core.Promise;
import org.unimodules.core.arguments.ReadableArguments;

import expo.modules.notifications.notifications.interfaces.NotificationBehavior;

/**
 * An implementation of {@link NotificationBehavior} capable of
 * "deserialization" of behavior objects with which the app responds.
 * <p>
 * Used in {@link NotificationsHandler#handleNotificationAsync(String, ReadableArguments, Promise)}
 * to pass the behavior to {@link SingleNotificationHandlerTask}.
 */
public class ExpoNotificationBehavior extends NotificationBehavior {
  private static final String SHOULD_SHOW_ALERT_KEY = "shouldShowAlert";
  private static final String SHOULD_PLAY_SOUND_KEY = "shouldPlaySound";
  private static final String SHOULD_SET_BADGE_KEY = "shouldSetBadge";
  private static final String PRIORITY_KEY = "priority";

  ExpoNotificationBehavior(ReadableArguments arguments) {
    super(
        arguments.getBoolean(SHOULD_SHOW_ALERT_KEY),
        arguments.getBoolean(SHOULD_PLAY_SOUND_KEY),
        arguments.getBoolean(SHOULD_SET_BADGE_KEY),
        arguments.getString(PRIORITY_KEY)
    );
  }
}
