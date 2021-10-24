/*  This file is part of Cawbird, a Gtk+ linux Twitter client forked from Corebird.
 *  Copyright (C) 2013 Timm Bäder (Corebird)
 *
 *  Cawbird is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Cawbird is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with cawbird.  If not, see <http://www.gnu.org/licenses/>.
 */

public enum MediaVisibility{
  SHOW                = 1,
  HIDE                = 2,
  HIDE_IN_TIMELINES   = 3
}

public enum TranslationService {
  GOOGLE = 0,
  BING = 1,
  DEEPL = 2,
  CUSTOM = 3
}

public enum ShortcutKey {
  ALT = 0,
  CTRL = 1,
  SHIFT = 2,
  SUPER = 3,
  PRIMARY = 4
}

public class Settings : GLib.Object {
  private static GLib.Settings settings;

  public static void init(){
    settings = new GLib.Settings("uk.co.ibboard.cawbird");
    if (settings.get_value("window-geometry").iterator().n_children() == 0) {
      info("Transferring old GSchema settings");
      var old_settings = new GLib.Settings.with_path("uk.co.ibboard.cawbird.core", "/uk.co.ibboard.cawbird/");
      foreach (string key in old_settings.settings_schema.list_keys()) {
        var old_value = old_settings.get_value(key);
        var default_value = old_settings.get_default_value(key);
        if (!old_value.equal(default_value)) {
          debug("Transferring value for %s", key);
          settings.set_value(key, old_settings.get_value(key));
          old_settings.reset(key);
        }
      }
    }
  }

  public static new GLib.Settings get () {
    return settings;
  }

  /**
   * Returns how many tweets should be stacked before a
   * notification should be created.
   */
  public static int get_tweet_stack_count() {
    int setting_val = settings.get_enum("new-tweets-notify");
    return setting_val;
  }

  /**
  * Check whether the user wants Cawbird to always use the dark gtk theme variant.
  */
  public static bool use_dark_theme(){
    return settings.get_boolean("use-dark-theme");
  }

  public static bool notify_new_mentions(){
    return settings.get_boolean("new-mentions-notify");
  }

  public static bool notify_new_dms(){
    return settings.get_boolean("new-dms-notify");
  }

  public static bool auto_scroll_on_new_tweets () {
    return settings.get_boolean ("auto-scroll-on-new-tweets");
  }

  public static string get_accel (string accel_name) {
    return settings.get_string ("accel-" + accel_name);
  }

  public static double get_tweet_scale() {
    int scale_idx = settings.get_enum ("tweet-scale");
    switch (scale_idx) {
      case 3: return Pango.Scale.XX_LARGE;
      case 2: return Pango.Scale.X_LARGE;
      case 1: return Pango.Scale.LARGE;
      default: return Pango.Scale.MEDIUM;
    }
  }

  public static void toggle_topbar_visible () {
    settings.set_boolean ("sidebar-visible", !settings.get_boolean ("sidebar-visible"));
  }

  public static string get_consumer_key (string default_key = Cawbird.consumer_k) {
    var override_key = settings.get_string ("consumer-key");
    return override_key != "" ? override_key : default_key;
  }

  public static string get_consumer_secret (string default_secret = Cawbird.consumer_s) {
    var override_secret = settings.get_string ("consumer-secret");
    return override_secret != "" ? override_secret : default_secret;
  }

  public static void add_text_transform_flag (Cb.TransformFlags flag) {
    settings.set_uint ("text-transform-flags",
                       settings.get_uint ("text-transform-flags") | flag);
  }

  public static void remove_text_transform_flag (Cb.TransformFlags flag) {
    settings.set_uint ("text-transform-flags",
                       settings.get_uint ("text-transform-flags") & ~flag);
  }

  public static Cb.TransformFlags get_text_transform_flags () {
    return (Cb.TransformFlags) settings.get_uint ("text-transform-flags");
  }

  public static bool hide_nsfw_content () {
    return settings.get_boolean ("hide-nsfw-content");
  }

  public static MediaVisibility get_media_visiblity () {
    return (MediaVisibility)settings.get_enum ("media-visibility");
  }

  public static TranslationService get_translation_service() {
    return (TranslationService)settings.get_enum("translation-service");
  }

  public static string get_custom_translation_service() {
    return settings.get_string("custom-translation-service");
  }

  public static void set_custom_translation_service(string new_url) {
    // The custom translation service gets a setter because we can't do normal binding because we want to validate the input
    settings.set_string("custom-translation-service", new_url);
  }

  public static string get_translation_service_url() {
    var translation_service = get_translation_service();
    switch (translation_service) {
      case TranslationService.GOOGLE:
        return "https://translate.google.com/?op=translate&sl={SOURCE_LANG}&tl={TARGET_LANG}&text={CONTENT}";
      case TranslationService.BING:
        return "https://www.bing.com/translator/?from={SOURCE_LANG}&to={TARGET_LANG}&text={CONTENT}";
      case TranslationService.DEEPL:
        return "https://www.deepl.com/translator#{SOURCE_LANG}/{TARGET_LANG}/{CONTENT}";
      default:
        return get_custom_translation_service();
    }
  }

  public static ShortcutKey get_shortcut_key() {
    return (ShortcutKey)settings.get_enum("shortcut-key");
  }

  public static string get_shortcut_key_string() {
    var shortcut_key = get_shortcut_key();
    switch (shortcut_key) {
      case ShortcutKey.ALT:
        return "<ALT>";
      case ShortcutKey.CTRL:
        return "<CTRL>";
      case ShortcutKey.SHIFT:
        return "<SHIFT>";
      case ShortcutKey.SUPER:
        return "<SUPER>";
      case ShortcutKey.PRIMARY:
        return "<PRIMARY>";
      default:
        return "<ALT>";
    }
  }
}
