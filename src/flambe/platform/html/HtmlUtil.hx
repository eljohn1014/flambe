//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.html;

import js.Lib;

import flambe.display.Orientation;

class HtmlUtil
{
    public static var VENDOR_PREFIXES = [ "webkit", "moz", "ms", "o", "khtml" ];

    /**
     * Whether the annoying scrolling address bar in some iOS and Android browsers may be hidden.
     */
    public static var SHOULD_HIDE_MOBILE_BROWSER =
        Lib.window.top == Lib.window &&
        ~/Mobile(\/.*)? Safari/.match(Lib.window.navigator.userAgent);

    public static function callLater (func :Void -> Void, delay :Int = 0)
    {
        (untyped Lib.window).setTimeout(func, delay);
    }

    public static function hideMobileBrowser ()
    {
        Lib.window.scrollTo(1, 0);
    }

    // Load a prefixed vendor extension
    public static function loadExtension (
        name :String, ?obj :Dynamic) :{ prefix :String, field :String, value :Dynamic }
    {
        if (obj == null) {
            obj = Lib.window;
        }

        // Try to load it as is
        var extension = Reflect.field(obj, name);
        if (extension != null) {
            return {prefix: null, field: name, value: extension};
        }

        // Look through common vendor prefixes
        var capitalized = name.charAt(0).toUpperCase() + name.substr(1);
        for (prefix in VENDOR_PREFIXES) {
            var field = prefix + capitalized;
            var extension = Reflect.field(obj, field);
            if (extension != null) {
                return {prefix: prefix, field: field, value: extension};
            }
        }

        // Not found
        return {prefix: null, field: null, value: null};
    }

    // Loads a vendor extension and jams it into the supplied object
    public static function polyfill (name :String, ?obj :Dynamic) :Bool
    {
        if (obj == null) {
            obj = Lib.window;
        }

        var value = loadExtension(name, obj).value;
        if (value == null) {
            return false;
        }
        Reflect.setField(obj, name, value);
        return true;
    }

    public static function setVendorStyle (element :Dynamic, name :String, value :String)
    {
        var style = element.style;
        for (prefix in VENDOR_PREFIXES) {
            style.setProperty("-" + prefix + "-" + name, value);
        }
        style.setProperty(name, value);
    }

    /**
     * Get a Flambe orientation from a window.orientation angle.
     */
    public static function orientation (angle :Int) :Orientation
    {
        switch (angle) {
            case -90, 90: return Landscape;
            default: return Portrait;
        }
    }
}
