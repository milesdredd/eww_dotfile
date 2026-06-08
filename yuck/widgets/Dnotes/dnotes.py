import gi
gi.require_version("Gtk", "4.0")

from gi.repository import Gtk, GLib, Gdk
from pathlib import Path
from datetime import date, timedelta
import subprocess
import sys

NOTES_DIR = Path.home() / "dailyNotes"
NOTES_DIR.mkdir(exist_ok=True)
NOTE_FILE = NOTES_DIR / f"{date.today():%Y-%m-%d}.md"
NOTE_FILE.touch(exist_ok=True)

PREV_NOTE_FILE = NOTES_DIR / f"{(date.today() - timedelta(days=1)):%Y-%m-%d}.md"

class NotesWindow(Gtk.ApplicationWindow):
    def __init__(self, app, tab="today"):
        super().__init__(application=app)

        self.set_title("Daily Notes")
        self.set_default_size(500, 400)

        notebook = Gtk.Notebook()

        # Tab 1: Today's notes (editable)
        tab1_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        tab1_box.set_margin_start(10)
        tab1_box.set_margin_end(10)
        tab1_box.set_margin_top(10)

        header_label = Gtk.Label(label="today's Notes : \n try writing \"good part\", \"bad part\" ,\"what bad part repeated \" , \" what for next day\"")
        header_label.set_halign(Gtk.Align.START)
        tab1_box.append(header_label)

        scrolled = Gtk.ScrolledWindow()
        scrolled.set_min_content_height(550)

        self.textview = Gtk.TextView()
        self.textview.set_wrap_mode(Gtk.WrapMode.WORD)
        self.textview.add_css_class("notes-textview")

        self.buffer = self.textview.get_buffer()

        try:
            self.buffer.set_text(NOTE_FILE.read_text())
        except Exception:
            pass

        self.buffer.connect("changed", self.on_changed)

        scrolled.set_child(self.textview)
        tab1_box.append(scrolled)

        btn_box = Gtk.Box()
        exec_btn = Gtk.Button(label="Execute")
        exec_btn.connect("clicked", self.on_exec_button_clicked)
        exec_btn.add_css_class("red-btn")
        btn_box.append(exec_btn)
        btn_box.set_halign(Gtk.Align.END)
        tab1_box.append(btn_box)

        notebook.append_page(tab1_box, Gtk.Label(label="Today"))

        # Tab 2: Previous day's notes (read-only)
        tab2_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        tab2_box.set_margin_start(10)
        tab2_box.set_margin_end(10)
        tab2_box.set_margin_top(10)

        prev_label = Gtk.Label(label="Previous Day Notes : ")
        prev_label.set_halign(Gtk.Align.START)
        tab2_box.append(prev_label)

        scrolled_prev = Gtk.ScrolledWindow()
        scrolled_prev.set_min_content_height(550)

        prev_textview = Gtk.TextView()
        prev_textview.set_wrap_mode(Gtk.WrapMode.WORD)
        prev_textview.set_editable(False)
        prev_textview.add_css_class("notes-textview")

        prev_buffer = prev_textview.get_buffer()

        try:
            prev_buffer.set_text(PREV_NOTE_FILE.read_text())
        except Exception:
            prev_buffer.set_text("No previous notes available")

        scrolled_prev.set_child(prev_textview)
        tab2_box.append(scrolled_prev)

        notebook.append_page(tab2_box, Gtk.Label(label="Previous Day"))

        self.set_child(notebook)

        if tab == "prev":
            notebook.set_current_page(1)
        else:
            notebook.set_current_page(0)

        self.save_source = None

    def on_changed(self, *_):
        if self.save_source:
            GLib.source_remove(self.save_source)

        self.save_source = GLib.timeout_add(
            1000,
            self.save_file
        )

    def on_exec_button_clicked(self, button):
        try:
            subprocess.run(["sudo", "systemctl", "poweroff"], check=True)
        except Exception as e:
            print(f"Error executing script: {e}")

    def save_file(self):
        start = self.buffer.get_start_iter()
        end = self.buffer.get_end_iter()

        text = self.buffer.get_text(start, end, True)

        NOTE_FILE.write_text(text)

        self.save_source = None
        return False


class App(Gtk.Application):
    def do_activate(self):
        tab_param = "today"
        if len(sys.argv) > 1:
            tab_param = sys.argv[1].lower()

        css_provider = Gtk.CssProvider()
        css_file = Path(__file__).parent / "styles.css"
        css_provider.load_from_path(str(css_file))

        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        win = NotesWindow(self, tab=tab_param)
        win.present()


app = App()
app.run()
