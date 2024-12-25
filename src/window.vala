[GtkTemplate (ui = "/com/github/sammarxz/pomerode/ui/window.ui")]
public class Pomerode.Window : Adw.ApplicationWindow {
    private enum SessionType {
        FOCUS,
        SHORT_BREAK,
        LONG_BREAK
    }

    [GtkChild]
    private unowned Gtk.Label time_label;
    [GtkChild]
    private unowned Gtk.Button start_button;
    [GtkChild]
    private unowned Gtk.Label session_label;
    [GtkChild]
    private unowned Gtk.Box session_indicators;

    private uint timer_id;
    private int remaining_time;
    private bool is_running;
    private Settings settings;
    private int work_duration;
    private int break_duration;
    private int long_break_duration;
    private int intervals_until_long_break;
    private bool autostart_intervals;
    private int completed_focus_sessions;
    private SessionType current_session;
    private Gtk.Widget[] indicator_dots;

    public Window (Gtk.Application app) {
        Object (application: app);
        initialize ();
    }

    private void initialize () {
        setup_settings ();
        setup_signals ();
        current_session = SessionType.FOCUS;
        completed_focus_sessions = 0;
        is_running = false;
        reset_timer ();
        setup_session_indicators ();
    }

    private void setup_settings () {
        settings = new Settings ("com.github.sammarxz.pomerode");
        settings.changed.connect (on_settings_changed);
        load_settings ();
    }

    private void load_settings () {
        work_duration = settings.get_int ("work-duration");
        break_duration = settings.get_int ("break-duration");
        long_break_duration = settings.get_int ("long-break-duration");
        intervals_until_long_break = settings.get_int ("intervals-until-long-break");
        autostart_intervals = settings.get_boolean ("autostart-intervals");
    }

    private void setup_signals () {
        start_button.clicked.connect (toggle_timer);
    }

    private void on_settings_changed (string key) {
        load_settings ();
        if (!is_running) {
            reset_timer ();
        }

        if (key == "intervals-until-long-break") {
            // Limpar os indicadores existentes
            while (session_indicators.get_first_child () != null) {
                session_indicators.remove (session_indicators.get_first_child ());
            }
            // Recriar os indicadores com o novo valor
            setup_session_indicators ();
        }
    }

    private void toggle_timer () {
        is_running = !is_running;
        if (is_running) {
            start_timer ();
            start_button.label = _("Pause");
            start_button.remove_css_class("play-button");
            start_button.add_css_class("pause-button");
        } else {
            stop_timer ();
            start_button.label = _("Start");
            start_button.remove_css_class("pause-button");
            start_button.add_css_class("play-button");
        }
    }

    private void start_timer () {
        timer_id = Timeout.add_seconds (1, () => {
            remaining_time--;
            update_label ();

            if (remaining_time <= 0) {
                handle_session_complete ();
                return false;
            }
            return true;
        });
    }

    private void stop_timer () {
        if (timer_id != 0) {
            Source.remove (timer_id);
            timer_id = 0;
        }
    }

    private void handle_session_complete () {
        string message = get_completion_message ();
        send_notification (message);
    
        if (current_session == SessionType.FOCUS) {
            completed_focus_sessions++;
            update_indicators ();
        }
    
        advance_session ();
        reset_timer ();
    
        if (autostart_intervals) {
            start_timer ();
            start_button.label = _("Pause");
            start_button.remove_css_class ("play-button");
            start_button.add_css_class ("pause-button");
            is_running = true;
        }
    }

    private string get_completion_message () {
        switch (current_session) {
        case SessionType.FOCUS:
            return _("Focus session complete. Time for a break!");
        case SessionType.SHORT_BREAK:
            return _("Break complete. Back to focus!");
        case SessionType.LONG_BREAK:
            return _("Long break complete. Ready for a new cycle?");
        default:
            return _("Session complete!");
        }
    }

    private void advance_session () {
        if (current_session == SessionType.FOCUS) {
            if (completed_focus_sessions % intervals_until_long_break == 0) {
                current_session = SessionType.LONG_BREAK;
            } else {
                current_session = SessionType.SHORT_BREAK;
            }
        } else {
            current_session = SessionType.FOCUS;
        }
        update_session_label ();
    }

    private void reset_timer () {
        stop_timer ();

        switch (current_session) {
        case SessionType.FOCUS:
            remaining_time = work_duration * 60;
            break;
        case SessionType.SHORT_BREAK:
            remaining_time = break_duration * 60;
            break;
        case SessionType.LONG_BREAK:
            remaining_time = long_break_duration * 60;
            break;
        }

        update_label ();
        update_session_label ();
        start_button.label = _("Start");
        start_button.remove_css_class("pause-button");
        start_button.add_css_class("play-button");
        is_running = false;
    }

    private void update_label () {
        int minutes = remaining_time / 60;
        int seconds = remaining_time % 60;
        time_label.label = "%02d:%02d".printf (minutes, seconds);
    }

    private void update_session_label () {
        switch (current_session) {
        case SessionType.FOCUS:
            session_label.label = _("Focus Time");
            break;
        case SessionType.SHORT_BREAK:
            session_label.label = _("Short Break");
            break;
        case SessionType.LONG_BREAK:
            session_label.label = _("Long Break");
            break;
        }
    }

    private void send_notification (string message) {
        var notification = new Notification ("Pomerode");
        notification.set_body (message);
        application.send_notification ("com.github.sammarxz", notification);
    }

    private void setup_session_indicators () {
        indicator_dots = new Gtk.Widget[intervals_until_long_break];

        for (int i = 0; i < intervals_until_long_break; i++) {
            var indicator = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            indicator.add_css_class ("session-indicator");
            session_indicators.append (indicator);
            indicator_dots[i] = indicator;
        }

        update_indicators ();
    }

    private void update_indicators () {
        for (int i = 0; i < intervals_until_long_break; i++) {
            if (i < completed_focus_sessions % intervals_until_long_break) {
                indicator_dots[i].add_css_class ("active");
            } else {
                indicator_dots[i].remove_css_class ("active");
            }
        }
    }
}