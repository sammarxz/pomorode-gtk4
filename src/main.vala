int main (string[] args) {
  Intl.setlocale (LocaleCategory.ALL, "");
  Intl.bindtextdomain (Build.GETTEXT_PACKAGE, Build.LOCALEDIR);
  Intl.bind_textdomain_codeset (Build.GETTEXT_PACKAGE, "UTF-8");
  Intl.textdomain (Build.GETTEXT_PACKAGE);

  var app = new Pomerode.Application ();
  return app.run (args);
}