project('com.github.sammarxz.pomerode', ['c', 'vala'],
    version: '0.1.0',
)

app_id = 'com.github.sammarxz.pomerode'

i18n = import('i18n')
gnome = import('gnome')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

subdir('data')
subdir('po')
subdir('src')

# Compile schemas
meson.add_install_script('build-aux/meson/postinstall.py')
