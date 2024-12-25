# vapi_sources = files(
#   'config.vapi',
# )

pomerode_vala_args = [
  '--target-glib', '2.72',
  '--vapidir', meson.current_source_dir(),
  # '--enable-experimental-non-null',
]

config_data = configuration_data()
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_data.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))

config_file = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: config_data
)

pomerode_vala_sources = files(
    'main.vala',
    'application.vala',
    'preferences.vala',
    'window.vala'
)

pomerode_sources = [
    config_file,
    pomerode_vala_sources,
    # vapi_sources,
    resources
]

pomerode_dependencies = [
    dependency('gtk4'),
    dependency('libadwaita-1'),
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gio-2.0'),

]

executable(
    'pomerode',
    pomerode_sources,
    vala_args: pomerode_vala_args,
    dependencies: pomerode_dependencies,
    install: true,
)
